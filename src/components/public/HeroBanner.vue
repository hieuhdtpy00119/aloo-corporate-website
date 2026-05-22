<script setup>
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <section class="overflow-hidden bg-gradient-to-br from-avocado-50 via-white to-cream-100">
    <div class="mx-auto grid max-w-6xl items-center gap-8 px-4 py-12 sm:px-5 lg:grid-cols-2 lg:px-6 lg:py-16">
      <div>
        <p class="mb-3 inline-flex rounded-full bg-avocado-100 px-3.5 py-1.5 text-xs font-bold text-avocado-800">
          {{ t('brand.badge') }}
        </p>
        <h1 class="max-w-2xl text-3xl font-black leading-tight text-avocado-950 sm:text-4xl lg:text-5xl">
          {{ t('home.heroTitle') }}
        </h1>
        <p class="mt-4 max-w-xl text-base leading-7 text-slate-700">
          {{ t('home.heroSubtitle') }}
        </p>
        <div class="mt-6 flex flex-col gap-3 sm:flex-row">
          <RouterLink to="/consultation" class="rounded-full bg-avocado-700 px-5 py-2.5 text-center text-sm font-bold text-white shadow-lg shadow-avocado-900/10 hover:bg-avocado-800">
            {{ t('nav.consultation') }}
          </RouterLink>
          <RouterLink to="/products" class="rounded-full border border-avocado-200 bg-white px-5 py-2.5 text-center text-sm font-bold text-avocado-800 hover:bg-avocado-50">
            {{ t('common.viewProducts') }}
          </RouterLink>
        </div>
      </div>
      <div class="relative">
        <div class="aspect-[4/3] overflow-hidden rounded-[1.5rem] bg-avocado-100 shadow-2xl shadow-avocado-900/10">
          <img src="https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=80" alt="ALOO avocado ice cream" class="h-full w-full object-cover" />
        </div>
        <div class="absolute -bottom-4 left-5 rounded-xl bg-white px-4 py-3 shadow-xl">
          <p class="text-xs font-semibold text-slate-500">{{ t('home.heroMetaLabel') }}</p>
          <p class="text-xl font-black text-avocado-800">{{ t('home.heroMetaValue') }}</p>
        </div>
      </div>
    </div>
  </section>
</template>
