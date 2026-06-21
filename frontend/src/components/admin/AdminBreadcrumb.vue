<script setup>
import { computed } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronRight } from 'lucide-vue-next'
import { buildAdminBreadcrumbItems } from '../../utils/adminBreadcrumb'

const route = useRoute()
const { t } = useI18n()

const items = computed(() => buildAdminBreadcrumbItems(route.path, t))
</script>

<template>
  <nav aria-label="Breadcrumb" class="min-w-0">
    <ol class="flex flex-wrap items-center gap-1 text-sm">
      <li v-for="(item, index) in items" :key="`${item.label}-${index}`" class="flex min-w-0 items-center gap-1">
        <ChevronRight v-if="index > 0" class="h-3.5 w-3.5 shrink-0 text-slate-300" />
        <RouterLink
          v-if="item.to && !item.current"
          :to="item.to"
          class="truncate font-semibold text-slate-500 transition hover:text-avocado-800"
        >
          {{ item.label }}
        </RouterLink>
        <span
          v-else
          class="truncate font-bold"
          :class="item.current ? 'text-avocado-950' : 'text-slate-500'"
        >
          {{ item.label }}
        </span>
      </li>
    </ol>
  </nav>
</template>
