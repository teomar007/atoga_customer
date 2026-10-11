-- ============================================================
-- ATOGA MANAGER — Step 2: Analytics RPCs (server-side)
-- جميع الدوال SECURITY DEFINER وتتحقق من دور موظف الإدارة.
-- لا تُنشئ/تحذف أي جدول. قابلة لإعادة التنفيذ.
-- ============================================================

-- 1) مؤشرات لوحة المعلومات اليومية
create or replace function public.admin_dashboard_kpis()
returns jsonb
language plpgsql stable security definer set search_path = public
as $$
declare
  v_tz text := 'Africa/Algiers';
  v_result jsonb;
begin
  if not public.is_staff_admin() then
    raise exception 'forbidden';
  end if;

  select jsonb_build_object(
    'sales_today',    coalesce(round(sum(o.total)::numeric, 2), 0),
    'delivered_today', coalesce(count(*), 0),
    'pending_orders', (select count(*) from public.orders po
                        where po.status not in ('delivered', 'cancelled')),
    'total_orders',   (select count(*) from public.orders),
    'avg_order_value', (select coalesce(round(avg(o2.total)::numeric, 2), 0)
                         from public.orders o2
                        where o2.status = 'delivered')
  )
  into v_result
  from public.orders o
  where o.status = 'delivered'
    and (o.delivered_at at time zone v_tz)::date = (now() at time zone v_tz)::date;

  return coalesce(v_result, '{}'::jsonb);
end $$;

-- 2) سلسلة المبيعات حسب الفترة: today / week / month / year
create or replace function public.admin_sales_series(p_period text default 'today')
returns jsonb
language plpgsql stable security definer set search_path = public
as $$
declare
  v_tz text := 'Africa/Algiers';
  v_unit text;
  v_fmt text;
  v_interval interval;
  v_start timestamp;
  v_end timestamp;
begin
  if not public.is_staff_admin() then
    raise exception 'forbidden';
  end if;

  case p_period
    when 'today' then
      v_unit := 'hour';  v_fmt := 'HH24';       v_interval := interval '1 hour';
      v_start := date_trunc('day', now() at time zone v_tz);
    when 'week' then
      v_unit := 'day';   v_fmt := 'Dy';         v_interval := interval '1 day';
      v_start := date_trunc('week', now() at time zone v_tz);
    when 'month' then
      v_unit := 'day';   v_fmt := 'DD';         v_interval := interval '1 day';
      v_start := date_trunc('month', now() at time zone v_tz);
    when 'year' then
      v_unit := 'month'; v_fmt := 'Mon';        v_interval := interval '1 month';
      v_start := date_trunc('year', now() at time zone v_tz);
    else
      raise exception 'invalid_period';
  end case;

  v_end := now() at time zone v_tz;

  return (
    select coalesce(jsonb_agg(
      jsonb_build_object('label', to_char(bucket.day, v_fmt), 'revenue', coalesce(s.revenue, 0))
      order by bucket.day
    ), '[]'::jsonb)
    from generate_series(v_start, v_end, v_interval) as bucket(day)
    left join (
      select date_trunc(v_unit, o.delivered_at at time zone v_tz) as day,
             sum(o.total) as revenue
      from public.orders o
      where o.status = 'delivered'
        and o.delivered_at is not null
        and o.delivered_at >= v_start
      group by 1
    ) s on s.day = bucket.day
  );
end $$;

-- 3) أداء المنتجات: الأعلى مبيعاً + الأقل مبيعاً (يشمل المنتجات بلا مبيعات)
create or replace function public.admin_product_performance(p_limit int default 5)
returns jsonb
language plpgsql stable security definer set search_path = public
as $$
declare
  v_top jsonb;
  v_least jsonb;
  v_limit int := greatest(p_limit, 1);
begin
  if not public.is_staff_admin() then
    raise exception 'forbidden';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
      'product_id', t.id,
      'name',    t.name,
      'name_fr', t.name_fr,
      'quantity', t.qty,
      'revenue',  t.rev
    )), '[]'::jsonb) into v_top
  from (
    select oi.product_id as id,
           coalesce(oi.name, '') as name,
           coalesce(oi.name_fr, '') as name_fr,
           sum(oi.quantity) as qty,
           round(sum(oi.price * oi.quantity)::numeric, 2) as rev
    from public.order_items oi
    join public.orders o on o.id = oi.order_id and o.status <> 'cancelled'
    group by oi.product_id, oi.name, oi.name_fr
    order by qty desc, rev desc
    limit v_limit
  ) t;

  select coalesce(jsonb_agg(jsonb_build_object(
      'product_id', t.id,
      'name',    t.name,
      'name_fr', t.name_fr,
      'quantity', t.qty,
      'revenue',  t.rev
    )), '[]'::jsonb) into v_least
  from (
    select p.id,
           coalesce(p.name, '') as name,
           coalesce(p.name_fr, '') as name_fr,
           coalesce(sum(case when o.status is not null then oi.quantity else 0 end), 0) as qty,
           coalesce(round(sum(case when o.status is not null then oi.price * oi.quantity else 0 end)::numeric, 2), 0) as rev
    from public.products p
    left join public.order_items oi on oi.product_id = p.id
    left join public.orders o on o.id = oi.order_id and o.status <> 'cancelled'
    group by p.id, p.name, p.name_fr
    order by qty asc, rev asc
    limit v_limit
  ) t;

  return jsonb_build_object('top', coalesce(v_top, '[]'::jsonb), 'least', coalesce(v_least, '[]'::jsonb));
end $$;

-- الأمان: لا تنفيذ إلا لموظفي الإدارة و service_role
revoke all on function public.admin_dashboard_kpis() from public, anon;
revoke all on function public.admin_sales_series(text) from public, anon;
revoke all on function public.admin_product_performance(int) from public, anon;
grant execute on function public.admin_dashboard_kpis() to authenticated, service_role;
grant execute on function public.admin_sales_series(text) to authenticated, service_role;
grant execute on function public.admin_product_performance(int) to authenticated, service_role;

-- ============================================================
-- Step 5: staff listing + fulfillment (driver/packager) KPIs
-- كلتاهما SECURITY DEFINER وتتحققان من is_super_admin().
-- ملاحظة: auth.users.email من نوع varchar لذا تُحوَّل إلى text.
-- ============================================================

-- 4) قائمة الموظفين مع البريد والاسم والهاتف من auth.users/profiles
create or replace function public.admin_list_staff()
returns table (
  user_id uuid,
  email text,
  role text,
  is_active boolean,
  full_name text,
  phone text,
  created_at timestamptz
)
language plpgsql stable security definer set search_path = public
as $$
begin
  if not public.is_super_admin() then
    raise exception 'forbidden';
  end if;

  return query
  select
    sr.user_id,
    coalesce(u.email::text, '') as email,
    sr.role::text as role,
    sr.is_active,
    coalesce(nullif(p.display_name, ''), '') as full_name,
    p.phone,
    sr.created_at
  from public.staff_roles sr
  join auth.users u on u.id = sr.user_id
  left join public.profiles p on p.id = sr.user_id
  order by sr.created_at desc;
end $$;

-- 5) مؤشرات أداء السائقين والمعبئين من جدول الطلبات
create or replace function public.admin_fulfillment_kpis()
returns table (
  user_id uuid,
  role text,
  full_name text,
  email text,
  total_orders bigint,
  successful_rate numeric,
  avg_delivery_min int
)
language plpgsql stable security definer set search_path = public
as $$
begin
  if not public.is_super_admin() then
    raise exception 'forbidden';
  end if;

  return query
  select
    sr.user_id,
    sr.role::text as role,
    coalesce(nullif(p.display_name, ''), u.email::text, '') as full_name,
    coalesce(u.email::text, '') as email,
    count(o.id)::bigint as total_orders,
    case
      when count(o.id) = 0 then 0
      else round(
        (count(*) filter (where o.status = 'delivered'))::numeric
        / count(o.id)::numeric, 4)
    end as successful_rate,
    coalesce(
      round(
        avg(extract(epoch from (o.delivered_at - o.created_at)) / 60.0)
          filter (where o.status = 'delivered' and o.delivered_at is not null)
      )::int,
      0
    ) as avg_delivery_min
  from public.staff_roles sr
  join auth.users u on u.id = sr.user_id
  left join public.profiles p on p.id = sr.user_id
  left join public.orders o
    on (sr.role = 'driver' and o.driver_id = sr.user_id)
    or (sr.role = 'packager' and o.packager_id = sr.user_id)
  where sr.role in ('driver', 'packager')
  group by sr.user_id, sr.role, p.display_name, u.email
  order by count(o.id) desc;
end $$;

revoke all on function public.admin_list_staff() from public, anon;
revoke all on function public.admin_fulfillment_kpis() from public, anon;
grant execute on function public.admin_list_staff() to authenticated, service_role;
grant execute on function public.admin_fulfillment_kpis() to authenticated, service_role;
