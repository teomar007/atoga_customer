-- ===================================================================
--  ATOGA MARKET 1.1.0 — مخطط قاعدة البيانات
--  نفّذ هذا الملف كاملاً في: Supabase Dashboard > SQL Editor > New query
--  (لا يمكن إنشاؤه عبر مفتاح anon، بل عبر اللوحة فقط)
-- ===================================================================

-- ---------- 1) ملف المستخدم ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  phone text,
  language_code text,
  theme_mode text,
  notifications_enabled boolean not null default true,
  wallet_balance numeric not null default 0,
  onesignal_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- 2) التصنيفات والمنتجات ----------
-- التصنيفات تُدار بالكامل من تطبيق الأدمن: ترجمة، إظهار/إخفاء، ترتيب.
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name_ar text not null default '',
  name_fr text,
  icon_name text,
  icon_url text,
  is_active boolean not null default true,
  display_order int not null default 0,
  -- مرآة مولّدة من name_ar: مصدر الحقيقة واحد، ويبقى عمود name مقروءاً
  -- لتطبيقات تقرأه مباشرة (لا يمكن الإدراج فيه).
  name text generated always as (name_ar) stored
);

create table if not exists public.products (
  id text primary key,
  name text not null,
  name_fr text,
  price numeric not null check (price >= 0),
  category_id uuid references public.categories (id) on delete set null,
  image_url text,
  unit text not null default '',
  stock int,
  is_promo boolean not null default false,
  old_price numeric,
  created_at timestamptz not null default now()
);

-- ---------- 3) بانرات العروض ----------
create table if not exists public.promo_banners (
  id text primary key,
  title text not null,
  title_fr text,
  subtitle text,
  subtitle_fr text,
  image_url text,
  discount_label text,
  target_category_id uuid references public.categories (id) on delete set null,
  sort_order int not null default 0,
  is_active boolean not null default true
);

-- ---------- 4) الكوبونات (تُعرض للمستخدم وتُدار لاحقاً من تطبيق الإدارة) ----------
create table if not exists public.coupons (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text,
  is_active boolean not null default true,
  user_id uuid references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz
);

-- ---------- 4b) كوبونات المستخدم (مخصّصة أو مستهلكة) ----------
create table if not exists public.user_coupons (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  coupon_id uuid not null references public.coupons (id) on delete cascade,
  is_used boolean not null default false,
  claimed_at timestamptz not null default now(),
  unique (user_id, coupon_id)
);

-- ---------- 4c) سلة التسوق السحابية ----------
-- تُخزَّن نسخة العرض (name/price/unit) وقت الإضافة — نفس سلوك السلة
-- المحلية — فتبقى السلة مقروءة حتى لو حُذف المنتج من الكتالوج لاحقاً.
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  product_id text not null,
  quantity int not null check (quantity > 0),
  name text not null,
  name_fr text,
  price numeric not null,
  image_url text,
  unit text,
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);

-- ---------- 4d) قائمة المفضلة ----------
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  product_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);

-- ---------- 4e) روابط التواصل الاجتماعي (Key-Value) ----------
-- تُدار من لوحة تحكم الإدارة لاحقاً: تغيير الرابط هنا ينعكس على التطبيق
-- دون تحديث جديد. القراءة عامة لأنها بيانات عامة لا تخص مستخدماً بعينه.
create table if not exists public.social_links (
  key text primary key,
  url text not null,
  updated_at timestamptz not null default now()
);

-- ---------- 5) العناوين ----------
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  label text not null default 'home',
  street text not null default '',
  building text not null default '',
  apartment text not null default '',
  notes text not null default '',
  phone text not null default '',
  latitude double precision,
  longitude double precision,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------- 5b) مناطق التوصيل ----------
-- تُدار من لوحة الإدارة: الاسم + سعر التوصيل الخاص بالحي. التطبيق يعرض
-- القائمة بجانب الخريطة بدل الحقول التفصيلية (شارع/عمارة/طابق).
create table if not exists public.delivery_zones (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  delivery_fee numeric not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- حقل يربط العنوان بمنطقة التوصيل (NULL = عنوان قديم قبل هذه الترقية).
alter table public.addresses add column if not exists delivery_zone_id uuid references public.delivery_zones (id);

-- ---------- 6) الطلبات ----------
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  subtotal numeric not null default 0,
  discount numeric not null default 0,
  delivery_fee numeric not null default 200,
  total numeric not null default 0,
  coupon_code text,
  payment_method text not null default 'cod',
  status text not null default 'received'
    check (status in ('received', 'preparing', 'on_the_way', 'delivered', 'cancelled')),
  street text not null default '',
  building text not null default '',
  apartment text not null default '',
  notes text not null default '',
  phone text not null default '',
  latitude double precision,
  longitude double precision,
  courier_name text,
  courier_phone text,
  estimated_delivery_at timestamptz,
  delivered_at timestamptz
);

create table if not exists public.order_items (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders (id) on delete cascade,
  product_id text not null,
  name text not null,
  name_fr text,
  price numeric not null,
  quantity int not null check (quantity > 0),
  image_url text,
  unit text
);

-- ---------- 7) الفهارس ----------
create index if not exists orders_user_created_idx on public.orders (user_id, created_at desc);
create index if not exists order_items_order_idx on public.order_items (order_id);
create index if not exists products_category_idx on public.products (category_id);
create index if not exists products_created_idx on public.products (created_at desc);
create index if not exists addresses_user_idx on public.addresses (user_id);

-- ---------- 8) تفعيل التتبع الحي (Realtime) ----------
alter publication supabase_realtime add table public.orders;

-- ---------- 9) Row Level Security ----------
alter table public.profiles     enable row level security;
alter table public.categories   enable row level security;
alter table public.products     enable row level security;
alter table public.promo_banners enable row level security;
alter table public.coupons      enable row level security;
alter table public.user_coupons enable row level security;
alter table public.cart_items   enable row level security;
alter table public.favorites    enable row level security;
alter table public.social_links enable row level security;
alter table public.addresses    enable row level security;
alter table public.delivery_zones enable row level security;
alter table public.orders       enable row level security;
alter table public.order_items  enable row level security;

-- قراءة عامة (حتى للزائر): الكتالوج — التصنيفات الفعّالة فقط، فالـ
-- المخفية (is_active = false) تبقى في القاعدة للأدمن ولا تظهر للزبون.
-- الأدمن يرى الكل عبر مفتاح service_role (يتجاوز RLS).
drop policy if exists "Public read categories" on public.categories;
drop policy if exists "Read active categories" on public.categories;
create policy "Read active categories" on public.categories for select using (is_active = true);

drop policy if exists "Public read products" on public.products;
create policy "Public read products" on public.products for select to anon, authenticated using (true);

drop policy if exists "Public read banners" on public.promo_banners;
create policy "Public read banners" on public.promo_banners for select to anon, authenticated using (true);

-- الكوبونات: عامة (`user_id is null`) أو خاصة بمالكها فقط — لا يرى أحد
-- كوبونات مستخدم آخر. فلترة `is_active` ومنع انتهاء الصلاحية في الاستعلام.
drop policy if exists "Public read coupons" on public.coupons;
create policy "Public read coupons" on public.coupons for select to anon, authenticated
  using (user_id is null or user_id = auth.uid());

-- بيانات الزبون الشخصية: ملكه وحده (`for all` = قراءة + كتابة + حذف).
drop policy if exists "Users own user_coupons" on public.user_coupons;
create policy "Users own user_coupons" on public.user_coupons for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users own cart_items" on public.cart_items;
create policy "Users own cart_items" on public.cart_items for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users own favorites" on public.favorites;
create policy "Users own favorites" on public.favorites for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- روابط التواصل الاجتماعي: قراءة عامة (بيانات التطبيق لا بيانات مستخدم).
drop policy if exists "Public read social_links" on public.social_links;
create policy "Public read social_links" on public.social_links for select to anon, authenticated using (true);

-- مناطق التوصيل: قراءة عامة — المستخدم يختار حيّه قبل الحفظ.
drop policy if exists "Public read delivery_zones" on public.delivery_zones;
create policy "Public read delivery_zones" on public.delivery_zones for select to anon, authenticated using (true);

-- الملف الشخصي: ملك المستخدم فقط.
drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile" on public.profiles for select to authenticated using (auth.uid() = id);

drop policy if exists "Users insert own profile" on public.profiles;
create policy "Users insert own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);

drop policy if exists "Users update own profile" on public.profiles;
create policy "Users update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- العناوين: ملك المستخدم فقط.
drop policy if exists "Users manage own addresses" on public.addresses;
create policy "Users manage own addresses" on public.addresses for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- الطلبات: إنشاء وقراءة طلبات المستخدم فقط.
drop policy if exists "Users insert own orders" on public.orders;
create policy "Users insert own orders" on public.orders for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users read own orders" on public.orders;
create policy "Users read own orders" on public.orders for select to authenticated using (auth.uid() = user_id);

-- المستخدم يلغي طلبه ما دام لم يُجهَّز بعد.
drop policy if exists "Users cancel own pending order" on public.orders;
create policy "Users cancel own pending order" on public.orders for update to authenticated using (auth.uid() = user_id and status = 'received') with check (auth.uid() = user_id and status = 'cancelled');

drop policy if exists "Users read own order items" on public.order_items;
create policy "Users read own order items" on public.order_items for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));

drop policy if exists "Users insert own order items" on public.order_items;
create policy "Users insert own order items" on public.order_items for insert to authenticated with check (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));

-- ---------- 10) دوال ما بعد الإدراج/التحديث ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- `phone_local` هي الصيغة المحلية (05XXXXXXXX) التي يرسلها التطبيق،
  -- ونحوّل `new.phone` (E.164) إلى صيغة محلية إن لم تُرسل metadata.
  insert into public.profiles (id, display_name, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(
      new.raw_user_meta_data ->> 'phone_local',
      nullif(case when new.phone like '+213%' then '0' || substr(new.phone, 5) else new.phone end, '')
    )
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

-- ---------- 10b) ضمان وجود صف الملف الشخصي ----------
-- `SECURITY DEFINER` فتتجاوز RLS: تحلّ مشكلة "تأكيد البريد مطلوب"، حيث لا
-- توجد جلسة بعد التسجيل فلا يستطيع العميل الكتابة على profiles مباشرة.
-- تعيد الصف (id, display_name, phone, language_code) بعد الإنشاء أو التحديث.
-- `drop` أولاً لأن PostgreSQL لا يسمح بتغيير نوع الإرجاع لدالة قائمة.
drop function if exists public.get_or_create_my_profile();
create or replace function public.get_or_create_my_profile()
returns table (id uuid, display_name text, phone text, language_code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_name text;
  v_phone text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;
  select coalesce(u.raw_user_meta_data ->> 'full_name',
                 u.raw_user_meta_data ->> 'display_name',
                 u.raw_user_meta_data ->> 'name',
                 '')
    into v_name
    from auth.users u
   where u.id = v_uid;
  select nullif(u.raw_user_meta_data ->> 'phone_local', '')
    into v_phone
    from auth.users u
   where u.id = v_uid;
  insert into public.profiles (id, display_name, phone)
  values (v_uid, coalesce(v_name, ''), v_phone)
  on conflict (id) do update
    set display_name = coalesce(nullif(public.profiles.display_name, ''), excluded.display_name);
  return query select p.id, p.display_name, p.phone, p.language_code from public.profiles p where p.id = v_uid;
end;
$$;

grant execute on function public.get_or_create_my_profile() to authenticated;

-- ---------- 11) شرط Google Play: حذف بيانات المستخدم ----------
-- تحذف كل ما يخص المستخدم في جداول التطبيق. حذف صف auth.users نفسه يتم
-- عبر Edge Function بصلاحية service role (supabase/functions/delete-account).
create or replace function public.delete_my_data(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is distinct from p_user_id then
    raise exception 'not allowed';
  end if;
  delete from public.order_items
   where order_id in (select id from public.orders where user_id = p_user_id);
  delete from public.orders    where user_id = p_user_id;
  delete from public.addresses  where user_id = p_user_id;
  delete from public.profiles   where id = p_user_id;
end;
$$;

grant execute on function public.delete_my_data(uuid) to authenticated;

-- ---------- 12) بيانات أولية للتجربة ----------
insert into public.categories (id, name_ar, name_fr, icon_name, display_order) values
  ('c0000001-0000-4000-8000-000000000001', 'معلبات',       'Conserves',         'lunch_dining', 1),
  ('c0000002-0000-4000-8000-000000000002', 'مشروبات',      'Boissons',          'local_drink',  2),
  ('c0000003-0000-4000-8000-000000000003', 'أجبان وألبان', 'Fromages & lait',   'egg_alt',      3),
  ('c0000004-0000-4000-8000-000000000004', 'حبوب وعجائن',  'Pâtes & céréales',  'grain',        4),
  ('c0000005-0000-4000-8000-000000000005', 'حلويات',       'Snacks',            'cookie',       5),
  ('c0000006-0000-4000-8000-000000000006', 'مواد التنظيف', 'Produits ménagers', 'cleaning',     6)
on conflict (id) do nothing;

insert into public.products (id, name, name_fr, price, category_id, unit) values
  ('p1',  'طماطم مصبرة 400غ',        'Tomates concervées 400 g',      120, 'c0000001-0000-4000-8000-000000000001', 'علبة'),
  ('p2',  'تون معبل في زيت',         'Thon en boîte à l''huile',      280, 'c0000001-0000-4000-8000-000000000001', 'علبة'),
  ('p3',  'معجون طماطم 800غ',        'Pâte de tomate 800 g',          240, 'c0000001-0000-4000-8000-000000000001', 'علبة'),
  ('p4',  'عصير برتقال 1 لتر',       'Jus d''orange 1 L',             150, 'c0000002-0000-4000-8000-000000000002', 'قنينة'),
  ('p5',  'مياه معدنية 6 قارورات',   'Eau minérale 6 bouteilles',     180, 'c0000002-0000-4000-8000-000000000002', 'حزمة'),
  ('p6',  'مشروب طاقة 250 مل',       'Boisson énergisante 250 ml',    200, 'c0000002-0000-4000-8000-000000000002', 'علبة'),
  ('p7',  'جبن أبيض 500غ',           'Fromage blanc 500 g',           320, 'c0000003-0000-4000-8000-000000000003', 'عبوة'),
  ('p8',  'حليب طويل الأمد 1 لتر',   'Lait longue conservation 1 L',  210, 'c0000003-0000-4000-8000-000000000003', 'قنينة'),
  ('p9',  'زبدة طبيعية 250غ',        'Beurre nature 250 g',           450, 'c0000003-0000-4000-8000-000000000003', 'عبوة'),
  ('p10', 'زيت زيتون 1 لتر',         'Huile d''olive 1 L',            950, 'c0000003-0000-4000-8000-000000000003', 'زجاجة'),
  ('p11', 'معكرونة إسباجتي 500غ',    'Spaghetti 500 g',               130, 'c0000004-0000-4000-8000-000000000004', 'كيس'),
  ('p12', 'أرز بسمتي 1 كغ',          'Riz basmati 1 kg',              380, 'c0000004-0000-4000-8000-000000000004', 'كيس'),
  ('p13', 'سكر 1 كغ',                'Sucre 1 kg',                    190, 'c0000004-0000-4000-8000-000000000004', 'كيس'),
  ('p14', 'شوكولاتة 100غ',           'Chocolat 100 g',                 90, 'c0000005-0000-4000-8000-000000000005', 'قطعة'),
  ('p15', 'بسكويت محشو 300غ',        'Biscuits fourrés 300 g',        220, 'c0000005-0000-4000-8000-000000000005', 'علبة'),
  ('p16', 'ماء ج الصابون 1 لتر',     'Eau de Javel 1 L',              260, 'c0000006-0000-4000-8000-000000000006', 'قنينة'),
  ('p17', 'مسحوق غسيل 3 كغ',         'Lessive en poudre 3 kg',        780, 'c0000006-0000-4000-8000-000000000006', 'كيس')
on conflict (id) do nothing;

-- بيانات تجريبية للعرض (مطابقة لبذور التطبيق): تُحمَّل الصور الحقيقية
-- والسعر القديم من لوحة الأدمن عبر image_url و old_price لاحقاً؛
-- الحارس `is null` يمنع طمس أي قيمة حقيقية عند إعادة التنفيذ.
update public.products
set image_url = case id
  when 'p1'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Tomates'
  when 'p2'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Thon'
  when 'p3'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Pate%20Tomate'
  when 'p4'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Jus%20Orange'
  when 'p5'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Eau'
  when 'p6'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Energie'
  when 'p7'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Fromage'
  when 'p8'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Lait'
  when 'p9'  then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Beurre'
  when 'p10' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Huile'
  when 'p11' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Spaghetti'
  when 'p12' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Riz'
  when 'p13' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Sucre'
  when 'p14' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Chocolat'
  when 'p15' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Biscuits'
  when 'p16' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Javel'
  when 'p17' then 'https://placehold.co/400x400/FDF6EC/E53935/png?text=Lessive'
end
where id in ('p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17')
  and image_url is null;

update public.products
set old_price = case id
  when 'p1'  then 150
  when 'p3'  then 300
  when 'p4'  then 190
  when 'p9'  then 550
  when 'p12' then 450
  when 'p17' then 950
end
where id in ('p1','p3','p4','p9','p12','p17')
  and old_price is null;

insert into public.promo_banners (id, title, title_fr, subtitle, subtitle_fr, discount_label, image_url, target_category_id, sort_order) values
  ('b1', 'خصم 20%',     'Remise 20%',      'على كل المشروبات',    'Sur toutes les boissons', '-20%', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=900&h=450&fit=crop&q=80', 'c0000002-0000-4000-8000-000000000002', 1),
  ('b2', 'أجبان طازجة', 'Fromages frais',  'طازجة كل صباح',       'Frais chaque matin',      '-10%', 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=900&h=450&fit=crop&q=80', 'c0000003-0000-4000-8000-000000000003', 2),
  -- target_category_id = null عمداً: لا يوجد صف 'all' في جدول التصنيفات
  -- (الشريحة «الكل» تُحقنها الواجهة محلياً)، وقيمة 'all' هنا كانت تخالف FK.
  ('b3', 'توصيل مجاني', 'Livraison gratuite', 'للطلبات فوق 3000 د.ج', 'Pour les commandes +3000 DA', null, 'https://images.unsplash.com/photo-1616401784845-180882ba9ba8?w=900&h=450&fit=crop&q=80', null, 3)
on conflict (id) do nothing;

insert into public.coupons (code, title, is_active) values
  ('WELCOME10', 'خصم 10% على أول طلب',     true),
  ('SAVE200',   'خصم 200 د.ج',             true),
  ('BIG500',    'خصم 500 د.ج فوق 3000 د.ج', true)
on conflict (code) do nothing;

-- روابط افتراضية (placeholders كباقي ثوابت الدعم) — تُستبدل من لوحة الإدارة.
-- العمود اسمه `url` لكنه يخزّن قيمة المفتاح بنمط KV، فالقيم هنا أرقام
-- اتصال لا روابط — التطبيق يبني منها `tel:` و `https://wa.me/`.
insert into public.social_links (key, url) values
  ('facebook',  'https://www.facebook.com/atogamarket'),
  ('instagram', 'https://www.instagram.com/atogamarket'),
  ('tiktok',    'https://www.tiktok.com/@atogamarket'),
  ('contact_phone',   '+213000000000'),
  ('whatsapp_number', '+213000000000')
on conflict (key) do nothing;

-- مناطق توصيل تجريبية. UUID ثابت (لا gen_random_uuid) حتى يعمل
-- `on conflict (id) do nothing` ويصبح الإدراج قابلاً لإعادة التنفيذ.
insert into public.delivery_zones (id, name, delivery_fee, is_active) values
  ('11111111-1111-4111-8111-111111111111', 'حي السلام',   200, true),
  ('22222222-2222-4222-8222-222222222222', 'حي الزهور',    250, true),
  ('33333333-3333-4333-8333-333333333333', 'وسط المدينة',  350, true)
on conflict (id) do nothing;

-- ---------- 13) المحفظة الإلكترونية ----------
-- رصيد لا يُعدَّل من الزبون إطلاقاً (revoke على عمود الـ UPDATE) —
-- الشحن من الإدارة عبر credit_wallet، والدفع عبر create_order_with_wallet
-- في معاملة واحدة (إنشاء الطلب + خصم الرصيد + تسجيل الحركة).

-- قيد عدم السالب (idempotent لإعادة التنفيذ)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_wallet_balance_non_negative'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles
      add constraint profiles_wallet_balance_non_negative check (wallet_balance >= 0);
  end if;
end $$;

revoke update on public.profiles from anon, authenticated;
grant update (display_name, phone, language_code, theme_mode, notifications_enabled, onesignal_id)
  on public.profiles to authenticated;

-- INSERT أيضاً على مستوى الأعمدة المسموحة فقط: الزبون قد يُنشئ صف
-- ملفٍ شخصي ناقصاً (الخلية يرحّلها trigger)، ولا يصح لمس wallet_balance.
revoke insert on public.profiles from anon, authenticated;
grant insert (id, display_name, phone, language_code, theme_mode, notifications_enabled, onesignal_id)
  on public.profiles to authenticated;

create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  amount numeric not null check (amount <> 0),
  type text not null check (type in ('deposit', 'payment')),
  order_id text,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists wallet_transactions_user_created_idx
  on public.wallet_transactions (user_id, created_at desc);

alter table public.wallet_transactions enable row level security;
drop policy if exists "Users read own wallet transactions" on public.wallet_transactions;
create policy "Users read own wallet transactions"
  on public.wallet_transactions
  for select to authenticated
  using (auth.uid() = user_id);

grant select on public.wallet_transactions to authenticated;

-- دفع من المحفظة: إنشاء الطلب بلا خصم (تحقق ناعم فقط) — يُخصم الرصيد
-- لاحقاً عند «قيد التجهيز» عبر prepare_order_wallet_payment بعد تصفية
-- الفاتورة (حذف المنتجات غير المتوفرة وتحديث المبلغ النهائي).
create or replace function public.create_order_with_wallet(
  p_street text,
  p_building text,
  p_apartment text,
  p_notes text,
  p_phone text,
  p_latitude double precision,
  p_longitude double precision,
  p_subtotal numeric,
  p_discount numeric,
  p_delivery_fee numeric,
  p_total numeric,
  p_coupon_code text,
  p_items jsonb
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_order_id uuid;
  v_balance numeric;
  v_item record;
begin
  if v_user_id is null then
    raise exception 'not_authenticated';
  end if;
  if p_total is null or p_total <= 0 then
    raise exception 'invalid_total';
  end if;

  select wallet_balance into v_balance
    from public.profiles
   where id = v_user_id;
  v_balance := coalesce(v_balance, 0);
  if v_balance < p_total then
    raise exception 'insufficient_wallet_balance';
  end if;

  insert into public.orders (
    user_id, street, building, apartment, notes, phone, latitude, longitude,
    subtotal, discount, delivery_fee, total, coupon_code, payment_method, status
  ) values (
    v_user_id,
    coalesce(p_street, ''), coalesce(p_building, ''), coalesce(p_apartment, ''),
    coalesce(p_notes, ''), coalesce(p_phone, ''), p_latitude, p_longitude,
    coalesce(p_subtotal, 0), coalesce(p_discount, 0), coalesce(p_delivery_fee, 0),
    coalesce(p_total, 0), p_coupon_code, 'wallet', 'received'
  ) returning id into v_order_id;

  if jsonb_typeof(p_items) <> 'array' then
    raise exception 'invalid_items';
  end if;
  for v_item in
    select * from jsonb_to_recordset(p_items)
      as x(product_id text, name text, name_fr text, price numeric, quantity int, image_url text, unit text)
  loop
    if v_item.product_id is null or v_item.name is null or v_item.price is null
       or v_item.quantity is null or v_item.quantity <= 0 then
      raise exception 'invalid_item';
    end if;
    insert into public.order_items (order_id, product_id, name, name_fr, price, quantity, image_url, unit)
    values (v_order_id, v_item.product_id, v_item.name, v_item.name_fr, v_item.price, v_item.quantity, v_item.image_url, v_item.unit);
  end loop;

  return v_order_id::text;
end;
$$;

grant execute on function public.create_order_with_wallet(
  text, text, text, text, text, double precision, double precision,
  numeric, numeric, numeric, numeric, text, jsonb
) to authenticated;

-- «قيد التجهيز»: الخصم النهائي في معاملة واحدة — يُستدعى من تطبيق الأدمن
-- (service_role) بعد ضبط العناصر؛ يعيد إجمالي الطلب المخصوم.
create or replace function public.prepare_order_wallet_payment(p_order_id uuid)
returns numeric
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order record;
  v_items_total numeric;
  v_final numeric;
  v_balance numeric;
begin
  if p_order_id is null then
    raise exception 'invalid_order_id';
  end if;

  select o.user_id, o.status, o.payment_method, o.discount, o.delivery_fee
    into v_order
    from public.orders o
   where o.id = p_order_id
   for update;
  if v_order.user_id is null then
    raise exception 'order_not_found';
  end if;
  if v_order.status <> 'received' then
    raise exception 'order_not_pending';
  end if;
  if v_order.payment_method <> 'wallet' then
    raise exception 'order_not_wallet_payment';
  end if;

  -- المبلغ النهائي يُعاد حسابه من الأسطر المتبقية (بعد حذف غير المتوفر)
  -- + الخصم والتوصيل — لا نثق بمبلغ قديم قد يُنسى تحديثه.
  select coalesce(sum(i.price * i.quantity), 0)
    into v_items_total
    from public.order_items i
   where i.order_id = p_order_id;
  v_final := v_items_total - coalesce(v_order.discount, 0) + coalesce(v_order.delivery_fee, 0);
  if v_final <= 0 then
    raise exception 'invalid_final_total';
  end if;

  select wallet_balance into v_balance
    from public.profiles
   where id = v_order.user_id
   for update;
  v_balance := coalesce(v_balance, 0);
  if v_balance < v_final then
    -- نُبقي الطلب received: الأدمن يحلّ (شحن/تحويل COD) ولا نخصم أبداً.
    raise exception 'insufficient_wallet_balance';
  end if;

  update public.orders
     set status = 'preparing',
         total = v_final
   where id = p_order_id;

  update public.profiles
     set wallet_balance = wallet_balance - v_final,
         updated_at = now()
   where id = v_order.user_id;

  insert into public.wallet_transactions (user_id, amount, type, order_id, note)
  values (v_order.user_id, -v_final, 'payment', p_order_id::text, 'order_payment');

  return v_final;
end;
$$;

grant execute on function public.prepare_order_wallet_payment(uuid) to service_role;

-- شحن الرصيد نقداً في المحل — للأدمن فقط (service_role)
create or replace function public.credit_wallet(
  p_user_id uuid,
  p_amount numeric,
  p_note text default null
)
returns numeric
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance numeric;
begin
  if p_user_id is null or p_amount is null or p_amount <= 0 then
    raise exception 'invalid_amount';
  end if;
  update public.profiles
     set wallet_balance = wallet_balance + p_amount,
         updated_at = now()
   where id = p_user_id
   returning wallet_balance into v_balance;
  if v_balance is null then
    raise exception 'user_not_found';
  end if;
  insert into public.wallet_transactions (user_id, amount, type, note)
  values (p_user_id, p_amount, 'deposit', coalesce(p_note, 'deposit_by_admin'));
  return v_balance;
end;
$$;

grant execute on function public.credit_wallet(uuid, numeric, text) to service_role;

-- ---------- 14) أوقات عمل المتجر ----------
-- يديرها تطبيق الأدمن (service_role)؛ الزبون يقرأ فقط ليُظهر حالة
-- «مفتوح/مغلق» ويعطّل الإضافة عند الإغلاق.
create table if not exists public.store_hours (
  id uuid primary key default gen_random_uuid(),
  day_of_week smallint not null check (day_of_week between 1 and 7),
  morning_open time,
  morning_close time,
  evening_open time,
  evening_close time,
  is_active boolean not null default true,
  updated_at timestamptz not null default now()
);

create unique index if not exists store_hours_day_uidx on public.store_hours (day_of_week);

alter table public.store_hours enable row level security;
drop policy if exists "Public read store hours" on public.store_hours;
create policy "Public read store hours"
  on public.store_hours
  for select to anon, authenticated
  using (true);

grant select on public.store_hours to anon, authenticated;

-- حالة المتجر الآن (بتوقيت الجزائر) — مصدر حقيقة واحد للواجهة والخلفية.
create or replace function public.store_is_open_now()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  with a as (
    select (now() at time zone 'Africa/Algiers') as ts
  )
  select coalesce((
    select (
      (h.morning_open is not null and h.morning_close is not null
        and a.ts::time >= h.morning_open and a.ts::time < h.morning_close)
      or
      (h.evening_open is not null and h.evening_close is not null
        and a.ts::time >= h.evening_open and a.ts::time < h.evening_close)
    )
    from public.store_hours h, a
    where h.is_active
      and h.day_of_week = extract(isodow from a.ts)::int
  ), false)
$$;

grant execute on function public.store_is_open_now() to anon, authenticated, service_role;

-- بذرة افتراضية: كل الأيام 08:00-13:00 و16:00-21:00 (قابلة للتحرير من الأدمن)
insert into public.store_hours (day_of_week, morning_open, morning_close, evening_open, evening_close)
select
  d.day_of_week,
  '08:00'::time, '13:00'::time, '16:00'::time, '21:00'::time
from generate_series(1, 7) as d(day_of_week)
on conflict (day_of_week) do nothing;
