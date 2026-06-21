<script setup>
import { ref } from 'vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import AdminProductsCatalogTab from '../../components/admin/products/AdminProductsCatalogTab.vue'
import AdminProductsHeroTab from '../../components/admin/products/AdminProductsHeroTab.vue'
import AdminProductsMenuTab from '../../components/admin/products/AdminProductsMenuTab.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { Plus } from 'lucide-vue-next'

const { m } = useAdminModuleI18n('products')

const activeTab = ref('products')
const catalogTabRef = ref(null)
const heroTabRef = ref(null)
const menuTabRef = ref(null)

const handleAddClick = () => {
  if (activeTab.value === 'products') {
    catalogTabRef.value?.openCreate()
  } else if (activeTab.value === 'menu') {
    menuTabRef.value?.openCreate()
  } else {
    heroTabRef.value?.openCreate()
  }
}
</script>

<template>
  <section>
    <AdminPageHeader :eyebrow="m('eyebrow')" :title="m('title')" :description="m('description')">
      <template #actions>
        <button class="aloo-btn aloo-btn--primary inline-flex items-center gap-2" @click="handleAddClick">
          <Plus class="h-4 w-4" />
          {{
            activeTab === 'products'
              ? m('addProduct')
              : activeTab === 'menu'
                ? m('addPoster')
                : m('addHero')
          }}
        </button>
      </template>
    </AdminPageHeader>

    <div class="inline-flex w-full rounded-3xl border border-slate-100 bg-white p-1.5 shadow-sm sm:w-auto">
      <button
        type="button"
        class="flex-1 rounded-2xl px-5 py-3 text-xs font-black uppercase tracking-wider transition sm:flex-none"
        :class="activeTab === 'products' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-500 hover:bg-avocado-50 hover:text-avocado-900'"
        @click="activeTab = 'products'"
      >
        {{ m('tabs.products') }}
      </button>
      <button
        type="button"
        class="flex-1 rounded-2xl px-5 py-3 text-xs font-black uppercase tracking-wider transition sm:flex-none"
        :class="activeTab === 'hero' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-500 hover:bg-avocado-50 hover:text-avocado-900'"
        @click="activeTab = 'hero'"
      >
        {{ m('tabs.hero') }}
      </button>
      <button
        type="button"
        class="flex-1 rounded-2xl px-5 py-3 text-xs font-black uppercase tracking-wider transition sm:flex-none"
        :class="activeTab === 'menu' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-500 hover:bg-avocado-50 hover:text-avocado-900'"
        @click="activeTab = 'menu'"
      >
        {{ m('tabs.menu') }}
      </button>
    </div>

    <AdminProductsCatalogTab v-if="activeTab === 'products'" ref="catalogTabRef" />
    <AdminProductsHeroTab v-else-if="activeTab === 'hero'" ref="heroTabRef" />
    <AdminProductsMenuTab v-else ref="menuTabRef" />
  </section>
</template>
