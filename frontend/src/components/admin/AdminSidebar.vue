<script setup>
import { computed } from 'vue'
import {
  FileText,
  Handshake,
  LayoutDashboard,
  Images,
  MapPin,
  Package,
  Star,
  MessageCircle,
  MessagesSquare,
  Users,
  UserCog,
  ScrollText,
} from 'lucide-vue-next'
import { useI18n } from 'vue-i18n'
import { adminPaths } from '../../constants/adminPaths'
import { ADMIN_SCOPES } from '../../utils/adminAccess'
import { useAdminAccess } from '../../composables/useAdminAccess'

defineProps({
  mobileOpen: {
    type: Boolean,
    default: false,
  },
})
const emit = defineEmits(['navigate'])

const { t } = useI18n()
const { permissions } = useAdminAccess()

const navGroups = [
  {
    items: [{ labelKey: 'admin.nav.dashboard', path: adminPaths.dashboard, icon: LayoutDashboard, scope: ADMIN_SCOPES.dashboard }],
  },
  {
    labelKey: 'admin.nav.groups.content',
    items: [
      { labelKey: 'admin.nav.homeSections', path: adminPaths.content.homeSections, icon: Images, scope: ADMIN_SCOPES.content },
      { labelKey: 'admin.nav.products', path: adminPaths.content.products, icon: Package, scope: ADMIN_SCOPES.content },
      { labelKey: 'admin.nav.franchise', path: adminPaths.content.franchise, icon: Handshake, scope: ADMIN_SCOPES.content },
      { labelKey: 'admin.nav.articles', path: adminPaths.content.articles, icon: FileText, scope: ADMIN_SCOPES.content },
    ],
  },
  {
    labelKey: 'admin.nav.groups.stores',
    items: [
      { labelKey: 'admin.nav.locations', path: adminPaths.stores.locations, icon: MapPin, scope: ADMIN_SCOPES.stores },
      { labelKey: 'admin.nav.feedbacks', path: adminPaths.crm.feedbacks, icon: Star, scope: ADMIN_SCOPES.crm },
      { labelKey: 'admin.nav.productReviews', path: adminPaths.crm.productReviews, icon: MessageCircle, scope: ADMIN_SCOPES.crm },
    ],
  },
  {
    labelKey: 'admin.nav.groups.business',
    items: [
      { labelKey: 'admin.nav.registrations', path: adminPaths.crm.leads, icon: Users, scope: ADMIN_SCOPES.crm },
      { labelKey: 'admin.nav.liveChat', path: adminPaths.crm.liveChat, icon: MessagesSquare, scope: ADMIN_SCOPES.crm },
    ],
  },
  {
    labelKey: 'admin.nav.groups.system',
    items: [
      { labelKey: 'admin.nav.accounts', path: adminPaths.system.accounts, icon: UserCog, scope: ADMIN_SCOPES.system },
      { labelKey: 'admin.nav.auditLogs', path: adminPaths.system.auditLogs, icon: ScrollText, scope: ADMIN_SCOPES.system },
    ],
  },
]

const visibleGroups = computed(() =>
  navGroups
    .map((group) => ({
      ...group,
      items: group.items.filter((item) => permissions.value[item.scope]),
    }))
    .filter((group) => group.items.length),
)

const isActive = (path, currentPath) => {
  if (path === adminPaths.dashboard) return currentPath === adminPaths.dashboard
  if (path === adminPaths.content.articles) {
    return currentPath === adminPaths.content.articles || currentPath.startsWith(`${adminPaths.content.articles}/`)
  }
  return currentPath === path || currentPath.startsWith(`${path}/`)
}
</script>

<template>
  <aside
    :class="[
      'h-screen w-72 bg-gradient-to-b from-brand-dark to-[#082414] p-6 text-white shadow-2xl flex flex-col justify-between border-r border-white/5 overflow-y-auto',
      mobileOpen ? 'fixed inset-y-0 left-0 z-50 flex' : 'fixed inset-y-0 left-0 z-40 hidden lg:flex',
    ]"
  >
    <div>
      <RouterLink to="/" class="block group" @click="emit('navigate')">
        <div class="flex items-center gap-3">
          <div class="h-9 w-9 bg-brand-lime text-brand-dark font-black rounded-xl grid place-items-center text-sm shadow-md transition group-hover:scale-105">
            A
          </div>
          <div>
            <div class="text-sm font-bold tracking-tight text-white transition group-hover:text-brand-lime">{{ t('admin.shell.brandTitle') }}</div>
            <p class="text-[10px] uppercase font-bold tracking-widest text-brand-lime/85">{{ t('admin.shell.brandSubtitle') }}</p>
          </div>
        </div>
      </RouterLink>

      <nav class="mt-10 space-y-6">
        <div v-for="(group, groupIndex) in visibleGroups" :key="group.labelKey || `group-${groupIndex}`">
          <p
            v-if="group.labelKey"
            class="mb-2 px-3.5 text-[10px] font-bold uppercase tracking-[0.18em] text-slate-500"
          >
            {{ t(group.labelKey) }}
          </p>
          <div class="space-y-1">
            <RouterLink
              v-for="item in group.items"
              :key="item.path"
              :to="item.path"
              class="flex items-center gap-3 rounded-xl py-2.5 pr-3 transition duration-200"
              :class="
                isActive(item.path, $route.path)
                  ? 'bg-white/5 text-brand-lime border-l-[3px] border-brand-lime pl-3.5 font-bold shadow-sm'
                  : 'text-slate-400 hover:bg-white/5 hover:text-white border-l-[3px] border-transparent pl-3.5'
              "
              @click="emit('navigate')"
            >
              <span
                class="grid h-8 w-8 shrink-0 place-items-center rounded-lg text-current transition duration-200"
                :class="isActive(item.path, $route.path) ? 'bg-brand-lime/10 text-brand-lime' : 'bg-white/5'"
              >
                <component :is="item.icon" class="h-4.5 w-4.5" aria-hidden="true" />
              </span>
              <span class="truncate text-current text-[11px] font-semibold tracking-wide">{{ t(item.labelKey) }}</span>
            </RouterLink>
          </div>
        </div>
      </nav>
    </div>
    <div class="mt-8 border-t border-white/10 pt-4"></div>
  </aside>
</template>
