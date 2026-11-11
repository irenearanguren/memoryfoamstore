# Repository instructions

## Build and run

- Install dependencies with `npm install` (Node.js 22.19.0 or newer).
- Run the Nuxt development server with `npm run dev -- --port 4173`.
- Build with `npm run build`; preview the production build with `npm run preview -- --port 4173`.
- `package.json` does not define test or lint scripts, and there is no configured test suite or single-test command.

## Architecture

- This is a Nuxt 4 / Vue 3 storefront. The main catalog page is `app/pages/index.vue`; shared app-level setup is in `app/app.vue`, and custom site styling is in `app/assets/css/main.css`.
- `app/composables/useCatalog.js` reads the public runtime config and fetches `products`, `product_images`, and `links` from Supabase. It turns image storage paths into public URLs and raises a Nuxt error if a query fails.
- `nuxt.config.ts` exposes Supabase's project URL and publishable/legacy anon key as `supabaseUrl` and `supabaseAnonKey`. In deployment, configure `NUXT_PUBLIC_SUPABASE_URL` and `NUXT_PUBLIC_SUPABASE_ANON_KEY`. These are public client values; never expose a Supabase `secret` or `service_role` key in `NUXT_PUBLIC_*`.
- Supabase schema, public read-only RLS policies, and the public `product-images` bucket are defined in `supabase/migrations/`. Product records are managed in Supabase; `supabase/catalog_seed.sql` is an example SQL import, and `supabase/products_template.csv` gives the `products` column header structure.
- Product images are separate rows in `product_images`, with `storage_path` under `products/<product_id>/` and a unique position from 1 through 3. Global social/contact links have a null `product_id`; product-specific links reference the product.
- The homepage filters products with `availability = 'coming_soon'` into a separate section; other products appear in the catalog. It paginates four products at a time and includes local image fallbacks for seeded product slugs.
- `server/routes/robots.txt.ts` and `server/routes/sitemap.xml.ts` generate SEO endpoints from the configured public site URL.

## Project conventions

- Keep customer-facing copy and SEO metadata in Spanish.
- Product availability values are `available`, `low_stock`, `out_of_stock`, and `coming_soon`; cover removability values are `yes`, `no`, and `not_applicable`. Keep values consistent with the SQL checks.
- Supabase's public client is read-only under the current RLS grants. Add or edit products, images, and links through Supabase rather than adding unauthenticated write paths to the storefront.
- Keep presentation styles in the existing custom CSS rather than introducing a UI framework.
