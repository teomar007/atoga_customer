-- ============================================================
-- ATOGA MANAGER — Step 1: RBAC + safe schema extensions
-- قابل لإعادة التنفيذ (idempotent). لا يُنشئ/يحذف أي جدول قائم.
-- يُنفَّذ عبر Migration أو SQL Editor.
-- ============================================================

-- ---------- 1) أنواع وأدوار الموظفين ----------
do $$ begin
  create type public.staff_role as enum ('super_admin','manager','marketer','driver','packager');
exception when duplicate_object then null; end $$;

create table if not exists public.staff_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role public.staff_role not null,
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.staff_roles enable row level security;
grant select, insert, update, delete on public.staff_roles to authenticated;
grant all on public.staff_roles to service_role;

-- ---------- 2) دوال المساعدة (SECURITY DEFINER) ----------
create or replace function public.current_staff_role()
returns public.staff_role
language sql stable security definer set search_path = public
as $$
  select role from public.staff_roles
   where user_id = auth.uid() and is_active
   limit 1
$$;

create or replace function public.get_my_staff_role()
returns text
language sql stable security definer set search_path = public
as $$
  select role::text from public.staff_roles
   where user_id = auth.uid() and is_active
   limit 1
$$;

create or replace function public.is_super_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_staff_role() = 'super_admin', false) $$;

create or replace function public.is_staff_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_staff_role() in ('super_admin','manager','marketer'), false) $$;

create or replace function public.can_manage_catalog()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_staff_role() in ('super_admin','manager'), false) $$;

create or replace function public.can_manage_marketing()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(public.current_staff_role() in ('super_admin','marketer'), false) $$;

revoke execute on function public.current_staff_role() from public, anon;
revoke execute on function public.get_my_staff_role() from public, anon;
revoke execute on function public.is_super_admin() from public, anon;
revoke execute on function public.is_staff_admin() from public, anon;
revoke execute on function public.can_manage_catalog() from public, anon;
revoke execute on function public.can_manage_marketing() from public, anon;

grant execute on function public.current_staff_role() to authenticated, service_role;
grant execute on function public.get_my_staff_role() to authenticated, service_role;
grant execute on function public.is_super_admin() to authenticated, service_role;
grant execute on function public.is_staff_admin() to authenticated, service_role;
grant execute on function public.can_manage_catalog() to authenticated, service_role;
grant execute on function public.can_manage_marketing() to authenticated, service_role;

-- ---------- 3) سياسات staff_roles ----------
drop policy if exists "Staff read own role" on public.staff_roles;
create policy "Staff read own role" on public.staff_roles
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "Super admin manage staff roles" on public.staff_roles;
create policy "Super admin manage staff roles" on public.staff_roles
  for all to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin());

-- ---------- 4) سياسات الكتابة على الجداول القائمة (RLS) ----------
drop policy if exists "Catalog manage products" on public.products;
create policy "Catalog manage products" on public.products
  for all to authenticated
  using (public.can_manage_catalog())
  with check (public.can_manage_catalog());

drop policy if exists "Catalog manage categories" on public.categories;
create policy "Catalog manage categories" on public.categories
  for all to authenticated
  using (public.can_manage_catalog())
  with check (public.can_manage_catalog());

drop policy if exists "Marketing manage banners" on public.promo_banners;
create policy "Marketing manage banners" on public.promo_banners
  for all to authenticated
  using (public.can_manage_marketing())
  with check (public.can_manage_marketing());

drop policy if exists "Marketing manage coupons" on public.coupons;
create policy "Marketing manage coupons" on public.coupons
  for all to authenticated
  using (public.can_manage_marketing())
  with check (public.can_manage_marketing());

drop policy if exists "Admin manage delivery zones" on public.delivery_zones;
create policy "Admin manage delivery zones" on public.delivery_zones
  for all to authenticated
  using (public.is_staff_admin())
  with check (public.is_staff_admin());

drop policy if exists "Admin manage social links" on public.social_links;
create policy "Admin manage social links" on public.social_links
  for all to authenticated
  using (public.is_staff_admin())
  with check (public.is_staff_admin());

drop policy if exists "Admin manage store hours" on public.store_hours;
create policy "Admin manage store hours" on public.store_hours
  for all to authenticated
  using (public.is_staff_admin())
  with check (public.is_staff_admin());

drop policy if exists "Admins read profiles" on public.profiles;
create policy "Admins read profiles" on public.profiles
  for select to authenticated using (public.is_staff_admin());

-- ---------- 5) أعمدة آمنة (ADD COLUMN IF NOT EXISTS فقط) ----------
alter table public.profiles add column if not exists avatar_url text;
alter table public.products add column if not exists is_active boolean not null default true;

alter table public.orders add column if not exists preparing_at timestamptz;
alter table public.orders add column if not exists picked_at timestamptz;
alter table public.orders add column if not exists driver_id uuid references auth.users(id) on delete set null;
alter table public.orders add column if not exists packager_id uuid references auth.users(id) on delete set null;

-- افتراضيّات المعرّفات النصية للكتالوج (لا تمسّ الصفوف القائمة)
alter table public.products alter column id set default gen_random_uuid()::text;
alter table public.promo_banners alter column id set default gen_random_uuid()::text;

-- حقول الكوبونات المتقدمة
alter table public.coupons add column if not exists starts_at timestamptz;
alter table public.coupons add column if not exists discount_type text;
alter table public.coupons add column if not exists discount_value numeric not null default 0;
alter table public.coupons add column if not exists min_order numeric not null default 0;
alter table public.coupons add column if not exists max_discount numeric;
alter table public.coupons add column if not exists free_shipping boolean not null default false;
alter table public.coupons add column if not exists usage_limit_per_user integer;
alter table public.coupons add column if not exists is_welcome boolean not null default false;

do $$ begin
  alter table public.coupons add constraint coupons_discount_type_chk
    check (discount_type is null or discount_type in ('percent','fixed','free_shipping'));
exception when duplicate_object then null; end $$;

-- يسمح للمستخدم بتحديث صورته الرمزية في صفّه (السياسة القائمة تحكم الصف)
grant update (avatar_url) on public.profiles to authenticated;

-- ---------- 6) جداول جديدة ----------
create table if not exists public.notification_campaigns (
  id uuid primary key default gen_random_uuid(),
  title text not null default '',
  body text not null default '',
  image_url text,
  mode text not null default 'topic',
  topic text,
  target_user_id uuid references auth.users(id) on delete set null,
  status text not null default 'sent',
  response jsonb,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.notification_campaigns enable row level security;
grant select, insert, update, delete on public.notification_campaigns to authenticated;
grant all on public.notification_campaigns to service_role;

drop policy if exists "Marketing read campaigns" on public.notification_campaigns;
create policy "Marketing read campaigns" on public.notification_campaigns
  for select to authenticated using (public.can_manage_marketing());

drop policy if exists "Marketing write campaigns" on public.notification_campaigns;
create policy "Marketing write campaigns" on public.notification_campaigns
  for insert to authenticated with check (public.can_manage_marketing());

create table if not exists public.coupon_redemptions (
  id uuid primary key default gen_random_uuid(),
  coupon_id uuid not null references public.coupons(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  order_id uuid references public.orders(id) on delete set null,
  redeemed_at timestamptz not null default now()
);
create index if not exists coupon_redemptions_coupon_user_idx
  on public.coupon_redemptions(coupon_id, user_id);
alter table public.coupon_redemptions enable row level security;
grant select, insert on public.coupon_redemptions to authenticated;
grant all on public.coupon_redemptions to service_role;

drop policy if exists "Users read own redemptions" on public.coupon_redemptions;
create policy "Users read own redemptions" on public.coupon_redemptions
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "Marketing read redemptions" on public.coupon_redemptions;
create policy "Marketing read redemptions" on public.coupon_redemptions
  for select to authenticated using (public.can_manage_marketing());

-- ---------- 7) تمكين أول Super Admin (service_role فقط، يعمل مرة واحدة) ----------
create or replace function public.bootstrap_super_admin(p_email text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare v_id uuid;
begin
  if exists (select 1 from public.staff_roles where role = 'super_admin') then
    raise exception 'super_admin_already_exists';
  end if;
  select id into v_id from auth.users where lower(email) = lower(p_email) limit 1;
  if v_id is null then
    raise exception 'user_not_found';
  end if;
  insert into public.staff_roles (user_id, role) values (v_id, 'super_admin')
    on conflict (user_id) do update set role = 'super_admin', updated_at = now();
  update public.profiles set is_admin = true where id = v_id;
  return v_id;
end $$;

revoke all on function public.bootstrap_super_admin(text) from public, anon, authenticated;
grant execute on function public.bootstrap_super_admin(text) to service_role;

-- ---------- 8) مخازن الصور + سياساتها ----------
insert into storage.buckets (id, name, public) values
  ('product-images','product-images', true),
  ('category-icons','category-icons', true),
  ('banners','banners', true),
  ('staff-avatars','staff-avatars', true)
on conflict (id) do nothing;

drop policy if exists "Public read media buckets" on storage.objects;
create policy "Public read media buckets" on storage.objects
  for select to anon, authenticated
  using (bucket_id in ('product-images','category-icons','banners','staff-avatars'));

drop policy if exists "Catalog upload media" on storage.objects;
create policy "Catalog upload media" on storage.objects
  for insert to authenticated
  with check (bucket_id in ('product-images','category-icons') and public.can_manage_catalog());

drop policy if exists "Catalog update media" on storage.objects;
create policy "Catalog update media" on storage.objects
  for update to authenticated
  using (bucket_id in ('product-images','category-icons') and public.can_manage_catalog())
  with check (bucket_id in ('product-images','category-icons') and public.can_manage_catalog());

drop policy if exists "Catalog delete media" on storage.objects;
create policy "Catalog delete media" on storage.objects
  for delete to authenticated
  using (bucket_id in ('product-images','category-icons') and public.can_manage_catalog());

drop policy if exists "Marketing upload media" on storage.objects;
create policy "Marketing upload media" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'banners' and public.can_manage_marketing());

drop policy if exists "Marketing update media" on storage.objects;
create policy "Marketing update media" on storage.objects
  for update to authenticated
  using (bucket_id = 'banners' and public.can_manage_marketing())
  with check (bucket_id = 'banners' and public.can_manage_marketing());

drop policy if exists "Marketing delete media" on storage.objects;
create policy "Marketing delete media" on storage.objects
  for delete to authenticated
  using (bucket_id = 'banners' and public.can_manage_marketing());

drop policy if exists "Staff avatar upload" on storage.objects;
create policy "Staff avatar upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'staff-avatars' and public.is_staff_admin());

drop policy if exists "Staff avatar update" on storage.objects;
create policy "Staff avatar update" on storage.objects
  for update to authenticated
  using (bucket_id = 'staff-avatars' and public.is_staff_admin())
  with check (bucket_id = 'staff-avatars' and public.is_staff_admin());

drop policy if exists "Staff avatar delete" on storage.objects;
create policy "Staff avatar delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'staff-avatars' and public.is_staff_admin());

-- ---------- 9) طلبات الوصول (Access Requests) ----------
-- طلب معلّق واحد فقط لكل مستخدم؛ القراءة: صاحب الطلب أو موظفو الإدارة،
-- الإدراج: صاحب الطلب فقط وبريده من JWT، والإدارة: المدير العام فقط.
create table if not exists public.admin_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text not null,
  status text not null default 'pending'
    check (status in ('pending','approved','rejected')),
  requested_at timestamptz not null default now()
);

create index if not exists admin_requests_user_status_idx
  on public.admin_requests (user_id, status);

create unique index if not exists admin_requests_one_pending_per_user
  on public.admin_requests (user_id) where status = 'pending';

alter table public.admin_requests enable row level security;
grant select, insert, update on public.admin_requests to authenticated;
grant all on public.admin_requests to service_role;

drop policy if exists "Users read own access requests" on public.admin_requests;
create policy "Users read own access requests" on public.admin_requests
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "Admins read access requests" on public.admin_requests;
create policy "Admins read access requests" on public.admin_requests
  for select to authenticated using (public.is_staff_admin());

drop policy if exists "Users submit own access request" on public.admin_requests;
create policy "Users submit own access request" on public.admin_requests
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and status = 'pending'
    and email = coalesce(auth.jwt()->>'email', '')
  );

drop policy if exists "Super admin manage access requests" on public.admin_requests;
create policy "Super admin manage access requests" on public.admin_requests
  for update to authenticated
  using (public.is_super_admin())
  with check (public.is_super_admin() and status in ('pending','approved','rejected'));

drop policy if exists "Super admin delete access requests" on public.admin_requests;
create policy "Super admin delete access requests" on public.admin_requests
  for delete to authenticated using (public.is_super_admin());

-- الموافقة/الرفض الذرّيان (SECURITY DEFINER، حارس: super_admin فقط)
create or replace function public.admin_approve_access_request(
  p_request_id uuid,
  p_role public.staff_role
)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_user_id uuid;
  v_email text;
begin
  if not public.is_super_admin() then
    raise exception 'forbidden';
  end if;
  if p_role not in ('manager', 'marketer') then
    raise exception 'invalid_role';
  end if;

  select user_id, email into v_user_id, v_email
  from public.admin_requests
  where id = p_request_id and status = 'pending'
  for update;

  if v_user_id is null then
    raise exception 'request_not_found';
  end if;

  update public.admin_requests set status = 'approved' where id = p_request_id;

  insert into public.staff_roles (user_id, role, is_active, created_by)
  values (v_user_id, p_role, true, auth.uid())
  on conflict (user_id) do update
    set role = excluded.role, is_active = true, updated_at = now();
end $$;

create or replace function public.admin_reject_access_request(p_request_id uuid)
returns void
language plpgsql security definer set search_path = public
as $$
begin
  if not public.is_super_admin() then
    raise exception 'forbidden';
  end if;

  update public.admin_requests
  set status = 'rejected'
  where id = p_request_id and status = 'pending';

  if not found then
    raise exception 'request_not_found';
  end if;
end $$;

revoke all on function public.admin_approve_access_request(uuid, public.staff_role) from public, anon;
revoke all on function public.admin_reject_access_request(uuid) from public, anon;
grant execute on function public.admin_approve_access_request(uuid, public.staff_role) to authenticated, service_role;
grant execute on function public.admin_reject_access_request(uuid) to authenticated, service_role;

-- ---------- 10) حماية المدير العام الرئيسي (دائم لا يُغيّر ولا يُحذف) ----------
-- الحساب الرئيسي: dirayalab@gmail.com (id 249cac50-5ba4-4bb7-8388-c2dd8a9a7945)
create or replace function public.guard_primary_admin()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  if TG_OP = 'DELETE' then
    if TG_TABLE_SCHEMA = 'auth' and TG_TABLE_NAME = 'users' then
      if OLD.email = 'dirayalab@gmail.com' then
        raise exception 'primary_admin_immutable: cannot delete the primary admin account';
      end if;
    end if;
    if TG_TABLE_SCHEMA = 'public' and TG_TABLE_NAME = 'staff_roles' then
      if OLD.user_id = '249cac50-5ba4-4bb7-8388-c2dd8a9a7945' then
        raise exception 'primary_admin_immutable: cannot delete the primary admin role';
      end if;
    end if;
  end if;

  if TG_OP = 'UPDATE' then
    if TG_TABLE_SCHEMA = 'auth' and TG_TABLE_NAME = 'users' then
      if OLD.email = 'dirayalab@gmail.com' and NEW.email is distinct from OLD.email then
        raise exception 'primary_admin_immutable: cannot change the primary admin email';
      end if;
    end if;
    if TG_TABLE_SCHEMA = 'public' and TG_TABLE_NAME = 'staff_roles' then
      if OLD.user_id = '249cac50-5ba4-4bb7-8388-c2dd8a9a7945'
         and (NEW.role is distinct from OLD.role or NEW.is_active is distinct from OLD.is_active) then
        raise exception 'primary_admin_immutable: cannot change or disable the primary admin role';
      end if;
    end if;
  end if;

  return coalesce(NEW, OLD);
end $$;

revoke all on function public.guard_primary_admin() from public, anon;
grant execute on function public.guard_primary_admin() to authenticated, service_role;

drop trigger if exists guard_primary_admin_email on auth.users;
create trigger guard_primary_admin_email
  before update of email or delete on auth.users
  for each row execute function public.guard_primary_admin();

drop trigger if exists guard_primary_admin_role on public.staff_roles;
create trigger guard_primary_admin_role
  before update or delete on public.staff_roles
  for each row execute function public.guard_primary_admin();
