<script setup>
import { computed, ref } from 'vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTabs from '../../components/admin/shell/AdminShellTabs.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import AdminProductsCatalogTab from '../../components/admin/products/AdminProductsCatalogTab.vue'
import AdminProductsMenuPostersTab from '../../components/admin/products/AdminProductsMenuPostersTab.vue'
import AdminProductsHeroTab from '../../components/admin/products/AdminProductsHeroTab.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { Plus } from 'lucide-vue-next'

const { m } = useAdminModuleI18n('products')

const activeTab = ref('products')
const catalogTabRef = ref(null)
const menuTabRef = ref(null)
const heroTabRef = ref(null)

const productTabItems = computed(() => [
  { key: 'products', label: m('tabs.products') },
  { key: 'menu', label: m('tabs.menu') },
  { key: 'hero', label: m('tabs.hero') },
])

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
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="m('title')">
          <template #actions>
            <button class="admin-list-btn admin-list-btn--primary" @click="handleAddClick">
              <Plus class="h-4 w-4" />
              {{ activeTab === 'products' ? m('addProduct') : activeTab === 'menu' ? m('addPoster') : m('addHero') }}
            </button>
          </template>
        </AdminPageHeader>
        <template #after>
          <AdminShellTabs
            v-model="activeTab"
            :items="productTabItems"
            :aria-label="m('title')"
          />
        </template>
      </AdminShellFrame>

      <AdminProductsCatalogTab v-if="activeTab === 'products'" ref="catalogTabRef" />
      <AdminProductsMenuPostersTab v-else-if="activeTab === 'menu'" ref="menuTabRef" />
      <AdminProductsHeroTab v-else ref="heroTabRef" />
    </AdminNestedShell>
  </AdminListPage>
</template>
