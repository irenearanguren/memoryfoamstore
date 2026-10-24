<script setup>
const { data: catalog, pending, error } = await useAsyncData('catalog', loadCatalog)
const search = ref('')
const heroImageIndex = ref(0)
const page = ref(0)
const pageSize = 4

const products = computed(() =>
  (catalog.value?.products ?? []).filter((product) => product.availability !== 'coming_soon')
)
const comingSoon = computed(() =>
  (catalog.value?.products ?? []).filter((product) => product.availability === 'coming_soon')
)
const filteredProducts = computed(() => {
  const query = search.value.trim().toLocaleLowerCase()
  if (!query) return products.value

  return products.value.filter((product) =>
    [product.name, product.description, product.dimensions, ...(product.colors ?? [])]
      .filter(Boolean)
      .join(' ')
      .toLocaleLowerCase()
      .includes(query)
  )
})
const pageCount = computed(() => Math.ceil(filteredProducts.value.length / pageSize))
const visibleProducts = computed(() =>
  filteredProducts.value.slice(page.value * pageSize, (page.value + 1) * pageSize)
)
const heroImages = computed(() =>
  (catalog.value?.images ?? []).filter((image) =>
    products.value.some((product) => product.id === image.product_id)
  )
)
const currentHeroImage = computed(() =>
  heroImages.value.length ? heroImages.value[heroImageIndex.value % heroImages.value.length] : null
)
const globalLinks = computed(() =>
  (catalog.value?.links ?? []).filter((link) => link.product_id === null)
)

watch(search, () => {
  page.value = 0
})

useSeoMeta({
  title: 'ATE Memory Foam | Confort para cada día',
  description: 'Cojines de memory foam y productos ergonómicos. Compra online desde Barquisimeto.',
  ogTitle: 'ATE Memory Foam',
  ogDescription: 'Confort ergonómico para cada día. Compra online desde Barquisimeto.',
  ogType: 'website'
})

function productImages(productId) {
  return (catalog.value?.images ?? []).filter((image) => image.product_id === productId)
}

function productLinks(productId) {
  return (catalog.value?.links ?? []).filter((link) => link.product_id === productId)
}

function moveHeroImage(direction) {
  const length = heroImages.value.length
  if (!length) return
  heroImageIndex.value = (heroImageIndex.value + direction + length) % length
}
</script>

<template>
  <div>
    <header class="site-header container">
      <a class="brand" href="#inicio">ATE MEMORY FOAM</a>
      <nav class="social-links" aria-label="Redes sociales y contacto">
        <a
          v-for="link in globalLinks"
          :key="link.id"
          :href="link.url"
          target="_blank"
          rel="noopener noreferrer"
        >
          {{ link.label }}
        </a>
      </nav>
    </header>

    <main>
      <section id="inicio" class="hero container">
        <div>
          <p class="eyebrow">Confort pensado para ti</p>
          <h1>Descansa mejor. Vive más cómodo.</h1>
          <p class="hero-copy">
            Cojines de memory foam y productos ergonómicos para acompañar cada momento de tu día.
            Compra online desde Barquisimeto.
          </p>
          <div class="hero-actions">
            <a class="button" href="#catalogo">Ver catálogo</a>
            <a
              v-if="globalLinks.find((link) => link.platform === 'whatsapp')"
              class="button button-secondary"
              :href="globalLinks.find((link) => link.platform === 'whatsapp').url"
              target="_blank"
              rel="noopener noreferrer"
            >
              Escríbenos
            </a>
          </div>
        </div>

        <div class="hero-visual" aria-label="Galería de imágenes de productos">
          <img
            v-if="currentHeroImage"
            :src="currentHeroImage.url"
            :alt="currentHeroImage.alt_text || 'Producto ATE Memory Foam'"
          >
          <div v-else class="hero-placeholder">
            <span aria-hidden="true">☁</span>
            <p>Tu espacio de confort</p>
          </div>
          <div v-if="heroImages.length > 1" class="gallery-controls">
            <button class="icon-button" aria-label="Imagen anterior" @click="moveHeroImage(-1)">
              ‹
            </button>
            <button class="icon-button" aria-label="Imagen siguiente" @click="moveHeroImage(1)">
              ›
            </button>
          </div>
        </div>
      </section>

      <section id="catalogo" class="section">
        <div class="container">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Encuentra tu favorito</p>
              <h2>Nuestros productos</h2>
            </div>
            <div class="carousel-controls" aria-label="Páginas del catálogo">
              <button
                class="icon-button"
                aria-label="Productos anteriores"
                :disabled="page <= 0"
                @click="page = Math.max(0, page - 1)"
              >
                ‹
              </button>
              <span>{{ pageCount ? page + 1 : 0 }} / {{ pageCount }}</span>
              <button
                class="icon-button"
                aria-label="Más productos"
                :disabled="page >= pageCount - 1"
                @click="page = Math.min(pageCount - 1, page + 1)"
              >
                ›
              </button>
            </div>
          </div>

          <div class="catalog-tools">
            <input
              v-model="search"
              class="search-input"
              type="search"
              placeholder="Buscar productos..."
              aria-label="Buscar productos"
            >
          </div>

          <p v-if="pending" class="load-state">Cargando catálogo...</p>
          <p v-else-if="error" class="load-state error-message">
            No pudimos cargar el catálogo. Intenta de nuevo más tarde.
          </p>
          <p v-else-if="catalog && !catalog.configured" class="load-state">
            Configura las variables de Supabase para conectar el catálogo.
          </p>
          <p v-else-if="!visibleProducts.length" class="load-state">
            {{ search ? 'No encontramos productos para esa búsqueda.' : 'Pronto publicaremos nuestros productos.' }}
          </p>

          <div v-else class="product-grid">
            <article v-for="product in visibleProducts" :key="product.id" class="product-card">
              <div class="product-image">
                <img
                  v-if="productImages(product.id)[0]"
                  :src="productImages(product.id)[0].url"
                  :alt="productImages(product.id)[0].alt_text || product.name"
                  loading="lazy"
                >
                <span v-else class="product-image-placeholder" aria-hidden="true">☁</span>
              </div>
              <div class="product-content">
                <span class="availability" :class="`availability-${product.availability}`">
                  {{
                    product.availability === 'out_of_stock'
                      ? 'Agotado'
                      : product.availability === 'low_stock'
                        ? 'Pocas unidades'
                        : 'Disponible'
                  }}
                </span>
                <h3>{{ product.name }}</h3>
                <p v-if="product.description" class="product-description">
                  {{ product.description }}
                </p>
                <p v-if="product.dimensions" class="product-meta">{{ product.dimensions }}</p>
                <p v-if="product.price_usd !== null" class="product-price">
                  ${{ Number(product.price_usd).toFixed(2) }} USD
                </p>
                <div v-if="productLinks(product.id).length" class="card-links">
                  <a
                    v-for="link in productLinks(product.id)"
                    :key="link.id"
                    class="text-link"
                    :href="link.url"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    {{ link.label }}
                  </a>
                </div>
              </div>
            </article>
          </div>
        </div>
      </section>

      <section class="coming-soon">
        <div class="container">
          <p class="eyebrow">Próximamente</p>
          <h2>Más confort está en camino</h2>
          <p>
            Estamos preparando sobrecolchones y nuevos productos ergonómicos. Muy pronto te
            contaremos más.
          </p>
          <ul v-if="comingSoon.length">
            <li v-for="product in comingSoon" :key="product.id">{{ product.name }}</li>
          </ul>
        </div>
      </section>
    </main>

    <footer class="site-footer">
      <div class="footer-inner container">
        <a class="brand" href="#inicio">ATE MEMORY FOAM</a>
        <p>Venta online desde Barquisimeto, Venezuela.</p>
        <p>© {{ new Date().getFullYear() }} ATE Memory Foam</p>
      </div>
    </footer>
  </div>
</template>
