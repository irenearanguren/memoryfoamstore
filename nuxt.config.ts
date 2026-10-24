export default defineNuxtConfig({
  compatibilityDate: '2026-10-17',
  css: ['~/assets/css/main.css'],
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      supabaseUrl: '',
      supabaseAnonKey: ''
    }
  },
  app: {
    head: {
      htmlAttrs: { lang: 'es' },
      title: 'ATE Memory Foam | Confort para cada día',
      meta: [
        {
          name: 'description',
          content: 'Cojines de memory foam y productos ergonómicos. Compra online desde Barquisimeto.'
        },
        { name: 'theme-color', content: '#F3E8D6' }
      ]
    }
  }
})
