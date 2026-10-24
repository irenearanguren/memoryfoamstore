create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text,
  dimensions text,
  colors text[] not null default '{}',
  cover_removability text not null default 'not_applicable'
    check (cover_removability in ('yes', 'no', 'not_applicable')),
  material text,
  warranty text,
  price_usd numeric(10, 2) check (price_usd is null or price_usd >= 0),
  availability text not null default 'available'
    check (availability in ('available', 'low_stock', 'out_of_stock', 'coming_soon')),
  sort_order integer not null default 0,
  seo_title text,
  seo_description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  storage_path text not null,
  alt_text text not null default '',
  position smallint not null check (position between 1 and 3),
  created_at timestamptz not null default now(),
  constraint product_images_storage_path_matches_product
    check (storage_path like ('products/' || product_id::text || '/%')),
  constraint product_images_unique_position unique (product_id, position),
  constraint product_images_unique_storage_path unique (storage_path)
);

create table public.links (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products (id) on delete cascade,
  platform text not null
    check (platform in ('whatsapp', 'instagram', 'tiktok', 'mercadolibre', 'website', 'other')),
  label text not null,
  url text not null check (url ~* '^https?://'),
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create index products_availability_sort_order_idx
  on public.products (availability, sort_order);
create index links_product_sort_order_idx
  on public.links (product_id, sort_order);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger products_set_updated_at
before update on public.products
for each row execute function public.set_updated_at();

create function public.enforce_product_image_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  image_count integer;
begin
  if tg_op = 'UPDATE' and new.product_id = old.product_id then
    return new;
  end if;

  perform 1
  from public.products
  where id = new.product_id
  for update;

  select count(*)
  into image_count
  from public.product_images
  where product_id = new.product_id
    and id <> new.id;

  if image_count >= 3 then
    raise exception 'A product can have at most 3 images'
      using errcode = 'check_violation';
  end if;

  return new;
end;
$$;

create trigger product_images_enforce_limit
before insert or update of product_id on public.product_images
for each row execute function public.enforce_product_image_limit();

revoke execute on function public.enforce_product_image_limit() from public, anon, authenticated;

alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.links enable row level security;

create policy "Public can read products"
  on public.products for select
  to anon, authenticated
  using (true);

create policy "Public can read product images"
  on public.product_images for select
  to anon, authenticated
  using (true);

create policy "Public can read links"
  on public.links for select
  to anon, authenticated
  using (true);

revoke all on public.products, public.product_images, public.links from anon, authenticated;
grant select on public.products, public.product_images, public.links to anon, authenticated;

insert into storage.buckets (id, name, public, allowed_mime_types)
values (
  'product-images',
  'product-images',
  true,
  array['image/jpeg', 'image/png', 'image/webp', 'image/avif']
)
on conflict (id) do update
set public = excluded.public,
    allowed_mime_types = excluded.allowed_mime_types;

create policy "Public can read product images"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'product-images');
