insert into public.products (
  name,
  slug,
  description,
  dimensions,
  colors,
  price_usd,
  availability,
  sort_order
)
values
  (
    'Almohada cervical tipo ola',
    'almohada-cervical-ola',
    'Relleno sólido de memory foam que no se deforma.',
    '55 × 35 cm; 8 y 11 cm de espesor',
    array['Azul claro', 'Rosa'],
    42,
    'available',
    1
  ),
  (
    'Cojín para sillas',
    'cojin-para-sillas',
    'Relleno sólido de memory foam que no se deforma.',
    '40 × 40 cm; 6 cm de espesor',
    array['Azul claro', 'Negro'],
    55,
    'available',
    2
  ),
  (
    'Cojín de asiento con soporte lumbar',
    'cojin-asiento-soporte-lumbar',
    null,
    null,
    array['Azul'],
    null,
    'available',
    3
  ),
  (
    'Soporte lumbar',
    'soporte-lumbar',
    null,
    null,
    '{}',
    null,
    'available',
    4
  ),
  (
    'Soporte lumbar',
    'soporte-lumbar-2',
    null,
    null,
    '{}',
    null,
    'available',
    5
  )
on conflict (slug) do update set
  name = excluded.name,
  description = excluded.description,
  dimensions = excluded.dimensions,
  colors = excluded.colors,
  price_usd = excluded.price_usd,
  availability = excluded.availability,
  sort_order = excluded.sort_order;

insert into public.links (id, product_id, platform, label, url, sort_order)
select seed.link_id, products.id, 'whatsapp', 'Consultar por WhatsApp', seed.url, 1
from (
  values
    ('b454a627-6b59-4c48-9035-cf55fe50fb01'::uuid, 'almohada-cervical-ola', 'https://wa.me/p/35061515866825699/584245091678'),
    ('b454a627-6b59-4c48-9035-cf55fe50fb02'::uuid, 'cojin-para-sillas', 'https://wa.me/p/35227152816899157/584245091678'),
    ('b454a627-6b59-4c48-9035-cf55fe50fb03'::uuid, 'cojin-asiento-soporte-lumbar', 'https://wa.me/p/37343170291995782/584245091678'),
    ('b454a627-6b59-4c48-9035-cf55fe50fb04'::uuid, 'soporte-lumbar', 'https://wa.me/p/28647634674842302/584245091678'),
    ('b454a627-6b59-4c48-9035-cf55fe50fb05'::uuid, 'soporte-lumbar-2', 'https://wa.me/p/27024308083909764/584245091678')
) as seed(link_id, slug, url)
join public.products on products.slug = seed.slug
on conflict (id) do update set
  product_id = excluded.product_id,
  platform = excluded.platform,
  label = excluded.label,
  url = excluded.url,
  sort_order = excluded.sort_order;
