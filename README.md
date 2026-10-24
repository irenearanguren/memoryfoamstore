# ATE Memory Foam

Catálogo online de cojines de memory foam y productos ergonómicos. Aplicación construida con Nuxt 4, Vue 3 y JavaScript, con Supabase como fuente pública de productos e imágenes.

## Requisitos

- Node.js 22.19.0 o superior y npm.
- Un proyecto de Supabase.

## Puesta en marcha

1. Instala las dependencias:

   ```sh
   npm install
   ```

2. Copia `.env.example` a `.env` y completa la URL y la clave pública (`anon`) de Supabase. No pongas claves `service_role` en el frontend.

3. En el SQL Editor de Supabase, ejecuta `supabase/migrations/20261017170000_create_catalog.sql`. Esto crea las tablas, las políticas de lectura pública y el bucket público `product-images`.

4. Inicia Nuxt en el puerto **4173**:

   ```sh
   npm run dev -- --port 4173
   ```

5. Abre `http://localhost:4173`. Nuxt actualiza la página automáticamente cuando guardas cambios.

Para probar la compilación de producción localmente, primero ejecuta `npm run build` y luego:

```sh
npm run preview -- --port 4173
```

Abre `http://localhost:4173`.

## Supabase: cargar productos e imágenes

- Añade cada producto en `products`. Usa `available`, `low_stock`, `out_of_stock` o `coming_soon` para el estado.
- Sube hasta tres imágenes por producto al bucket `product-images`, dentro de una carpeta con el UUID del producto: `products/<product_id>/foto.webp`.
- Registra cada foto en `product_images` con el mismo `product_id`, su `storage_path`, texto alternativo y posición única entre 1 y 3.
- En `links`, usa `product_id` vacío para enlaces globales de redes y contacto, y el UUID del producto para enlaces de MercadoLibre o del catálogo de WhatsApp.
- El acceso público es de solo lectura. Las cargas y modificaciones se hacen desde el panel de Supabase; no hay autenticación ni formulario de administración en esta etapa.

## Variables de entorno

| Variable | Uso |
| --- | --- |
| `NUXT_PUBLIC_SUPABASE_URL` | URL del proyecto Supabase |
| `NUXT_PUBLIC_SUPABASE_ANON_KEY` | Clave pública `anon` del proyecto |

En Vercel, crea estas mismas variables en la configuración del proyecto y vuelve a desplegar. `.env` es local y no se debe subir al repositorio.

## Estructura de carpetas

```text
app/
  app.vue                 # Documento raíz, metadatos y estilos globales
  assets/css/main.css     # Estilos y paleta de marca
  composables/
    useCatalog.js         # Consultas públicas a Supabase
  pages/
    index.vue             # Landing: portada, catálogo y próximos productos
supabase/
  migrations/             # Esquema SQL versionado
.env.example              # Plantilla de variables locales
nuxt.config.ts            # Configuración Nuxt y variables públicas
package.json              # Dependencias y comandos
```

## Módulos y tecnologías

- **Nuxt 4 + Vue 3:** interfaz y renderizado del lado del servidor para que el catálogo pueda entregar contenido indexable.
- **`@supabase/supabase-js`:** cliente para leer productos, imágenes, enlaces y obtener URLs públicas del Storage.
- **CSS propio:** estilos adaptables y colores de marca; no se añade un framework visual.

No se instala un módulo de autenticación: en esta etapa el catálogo solo lee datos públicos. Nuxt puede consumir en el futuro las APIs de Laravel para autenticación y operaciones como pagos e integraciones.

## Comandos

```sh
npm run dev -- --port 4173       # Desarrollo local
npm run build                    # Compilación de producción
npm run preview -- --port 4173   # Vista previa local en el puerto 4173
```
