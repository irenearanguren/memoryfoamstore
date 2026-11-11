import { createClient } from '@supabase/supabase-js'

export async function loadCatalog() {
  const config = useRuntimeConfig()
  const supabaseUrl = config.public.supabaseUrl
  const supabaseAnonKey = config.public.supabaseAnonKey

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('[catalog] Supabase is not configured', {
      hasUrl: Boolean(supabaseUrl),
      hasAnonKey: Boolean(supabaseAnonKey)
    })
    return { configured: false, products: [], images: [], links: [] }
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey)
  const [productsResult, imagesResult, linksResult] = await Promise.all([
    supabase.from('products').select('*').order('sort_order'),
    supabase.from('product_images').select('*').order('position'),
    supabase.from('links').select('*').order('sort_order')
  ])

  for (const [table, result] of [
    ['products', productsResult],
    ['product_images', imagesResult],
    ['links', linksResult]
  ]) {
    if (result.error) {
      console.error('[catalog] Supabase query failed', {
        table,
        code: result.error.code,
        message: result.error.message
      })
      throw createError({
        statusCode: 500,
        statusMessage: 'No se pudo cargar el catálogo',
        message: result.error.message
      })
    }
  }

  const images = imagesResult.data.map((image) => ({
    ...image,
    url: supabase.storage.from('product-images').getPublicUrl(image.storage_path).data.publicUrl
  }))

  return {
    configured: true,
    products: productsResult.data,
    images,
    links: linksResult.data
  }
}
