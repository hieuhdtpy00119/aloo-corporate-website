<script setup>
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <footer class="bg-avocado-950 text-white">
    <div class="mx-auto grid max-w-7xl gap-8 px-4 py-12 sm:px-6 lg:grid-cols-[1.4fr_1fr_1fr_1fr] lg:px-8">
      <div>
        <div class="text-2xl font-black">{{ t('brand.name') }}</div>
        <p class="mt-3 max-w-sm text-sm leading-6 text-avocado-100">
          {{ t('footer.description') }}
        </p>
        <div class="mt-5 flex gap-3">
          <a href="#" class="grid h-9 w-9 place-items-center rounded-full bg-white/10 text-sm font-black hover:bg-cream-400 hover:text-avocado-950">f</a>
          <a href="#" class="grid h-9 w-9 place-items-center rounded-full bg-white/10 text-sm font-black hover:bg-cream-400 hover:text-avocado-950">ig</a>
          <a href="#" class="grid h-9 w-9 place-items-center rounded-full bg-white/10 text-sm font-black hover:bg-cream-400 hover:text-avocado-950">yt</a>
        </div>
      </div>
      <div>
        <h3 class="font-bold text-cream-300">{{ t('footer.brand') }}</h3>
        <div class="mt-4 grid gap-2 text-sm text-avocado-100">
          <RouterLink to="/about">{{ t('nav.about') }}</RouterLink>
          <RouterLink to="/products">{{ t('nav.products') }}</RouterLink>
          <RouterLink to="/blog">{{ t('nav.blog') }}</RouterLink>
          <RouterLink to="/contact">{{ t('nav.contact') }}</RouterLink>
        </div>
      </div>
      <div>
        <h3 class="font-bold text-cream-300">{{ t('footer.system') }}</h3>
        <div class="mt-4 grid gap-2 text-sm text-avocado-100">
          <RouterLink to="/locations">{{ t('footer.storeLocations') }}</RouterLink>
          <RouterLink to="/franchise">{{ t('nav.franchise') }}</RouterLink>
          <RouterLink to="/consultation">{{ t('nav.consultation') }}</RouterLink>
        </div>
      </div>
      <div>
        <h3 class="font-bold text-cream-300">{{ t('nav.contact') }}</h3>
        <div class="mt-4 space-y-2 text-sm text-avocado-100">
          <p>{{ t('footer.hotline') }}: 0900 888 168</p>
          <p>{{ t('footer.email') }}: franchise@aloo.vn</p>
          <p>{{ t('footer.address') }}: {{ t('footer.addressValue') }}</p>
        </div>
      </div>
    </div>
    <div class="border-t border-white/10 py-4 text-center text-sm text-avocado-100">
      {{ t('footer.copyright') }}
    </div>
  </footer>
</template>
