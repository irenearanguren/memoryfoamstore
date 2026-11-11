<script setup>
const config = useRuntimeConfig()
const measurementId = config.public.gaMeasurementId
const hasValidMeasurementId = /^G-[A-Z0-9]+$/i.test(measurementId)

if (hasValidMeasurementId) {
  useHead({
    script: [
      {
        src: `https://www.googletagmanager.com/gtag/js?id=${measurementId}`,
        async: true
      },
      {
        innerHTML: `window.dataLayer = window.dataLayer || []; function gtag(){dataLayer.push(arguments)}; gtag('js', new Date()); gtag('config', '${measurementId}');`
      }
    ]
  })
}
</script>

<template>
  <NuxtPage />
</template>
