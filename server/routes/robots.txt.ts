export default defineEventHandler((event) => {
  const config = useRuntimeConfig(event)
  const siteUrl = new URL(config.public.siteUrl).origin

  setHeader(event, 'content-type', 'text/plain; charset=utf-8')
  return `User-agent: *
Allow: /
Sitemap: ${siteUrl}/sitemap.xml
`
})
