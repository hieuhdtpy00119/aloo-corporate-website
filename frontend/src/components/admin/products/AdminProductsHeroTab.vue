<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import AdminShellFrame from '../shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../shell/AdminShellTablePanel.vue'
import BaseModal from '../BaseModal.vue'
import ConfirmModal from '../ConfirmModal.vue'
import EmptyState from '../EmptyState.vue'
import Pagination from '../Pagination.vue'
import SearchFilterBar from '../SearchFilterBar.vue'
import { heroBannerService, normalizeStorageAssetUrl, resolveBackendAssetUrl, uploadService } from '../../../services/cmsService'
import { useAdminModuleI18n } from '../../../composables/useAdminModuleI18n'
import { useToastStore } from '../../../stores/toastStore'
import { Edit2, Trash2, Image as ImageIcon } from 'lucide-vue-next'

const { m, t } = useAdminModuleI18n('products')
const toast = useToastStore()

const showHeroModal = ref(false)
const heroMode = ref('create')
const editingHeroId = ref(null)
const pendingDeleteHeroId = ref(null)
const heroSearchQuery = ref('')
const heroStatusFilter = ref(t('admin.shared.all'))
const heroCurrentPage = ref(1)
const isLoadingHeroBanners = ref(false)
const heroBannerError = ref('')
const isUploadingHeroImage = ref('')
const heroBanners = ref([])
const pageSize = 6

const showCropper = ref(false)
const cropperSrc = ref('')
const cropperTargetField = ref('')
const cropperFile = ref(null)
const cropBox = reactive({
  x: 10,
  y: 10,
  w: 80,
  h: 40,
})

const productStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
}))
const heroStatusLabels = computed(() => ({
  ACTIVE: m('status.visible'),
  INACTIVE: m('status.INACTIVE'),
}))
const heroStatusFilters = computed(() => [t('admin.shared.all'), ...productStatuses.map((status) => heroStatusLabels.value[status])])

const heroForm = reactive({
  title: '',
  subtitle: '',
  description: '',
  backgroundImageUrl: '',
  tone: 'light',
  sortOrder: 0,
  status: 'ACTIVE',
})

const heroBackgroundPreviewUrl = computed(() => resolveBackendAssetUrl(heroForm.backgroundImageUrl || ''))

const normalizeHeroBanner = (banner) => ({
  ...banner,
  title: banner.title || '',
  subtitle: banner.subtitle || '',
  description: banner.description || '',
  backgroundImageUrl: normalizeStorageAssetUrl(banner.backgroundImageUrl || ''),
  tone: banner.tone || 'light',
  sortOrder: Number(banner.sortOrder || 0),
  status: banner.status || 'ACTIVE',
})

const resetHeroForm = () => {
  Object.assign(heroForm, {
    title: '',
    subtitle: '',
    description: '',
    backgroundImageUrl: '',
    tone: 'light',
    sortOrder: 0,
    status: 'ACTIVE',
  })
  editingHeroId.value = null
}

const openCreateHeroModal = () => {
  heroMode.value = 'create'
  resetHeroForm()
  showHeroModal.value = true
}

const openEditHeroModal = (banner) => {
  heroMode.value = 'edit'
  editingHeroId.value = banner.id
  Object.assign(heroForm, {
    title: banner.title || '',
    subtitle: banner.subtitle || '',
    description: banner.description || '',
    backgroundImageUrl: banner.backgroundImageUrl || '',
    tone: banner.tone || 'light',
    sortOrder: Number(banner.sortOrder || 0),
    status: banner.status || 'ACTIVE',
  })
  showHeroModal.value = true
}

const closeHeroModal = () => {
  showHeroModal.value = false
  resetHeroForm()
}

const adjustCropBox = (field, val) => {
  const num = Math.min(100, Math.max(0, Number(val)))
  if (field === 'w') {
    cropBox.w = Math.min(100 - cropBox.x, Math.max(10, num))
  } else if (field === 'h') {
    cropBox.h = Math.min(100 - cropBox.y, Math.max(10, num))
  } else if (field === 'x') {
    cropBox.x = Math.min(100 - cropBox.w, num)
  } else if (field === 'y') {
    cropBox.y = Math.min(100 - cropBox.h, num)
  }
}

const cropWrapperRef = ref(null)
let dragState = null

const getWrapperSize = () => {
  const el = cropWrapperRef.value
  if (!el) return { width: 1, height: 1 }
  const rect = el.getBoundingClientRect()
  return { width: rect.width || 1, height: rect.height || 1 }
}

const onCropDrag = (event) => {
  if (!dragState) return
  const { width, height } = getWrapperSize()
  const dxPct = ((event.clientX - dragState.startX) / width) * 100
  const dyPct = ((event.clientY - dragState.startY) / height) * 100
  const box = dragState.startBox
  const minSize = 10

  if (dragState.mode === 'move') {
    cropBox.x = Math.min(100 - box.w, Math.max(0, box.x + dxPct))
    cropBox.y = Math.min(100 - box.h, Math.max(0, box.y + dyPct))
    return
  }

  let { x, y, w, h } = box
  const handle = dragState.handle
  if (handle.includes('e')) {
    w = Math.min(100 - box.x, Math.max(minSize, box.w + dxPct))
  }
  if (handle.includes('s')) {
    h = Math.min(100 - box.y, Math.max(minSize, box.h + dyPct))
  }
  if (handle.includes('w')) {
    const newX = Math.min(box.x + box.w - minSize, Math.max(0, box.x + dxPct))
    w = box.w + (box.x - newX)
    x = newX
  }
  if (handle.includes('n')) {
    const newY = Math.min(box.y + box.h - minSize, Math.max(0, box.y + dyPct))
    h = box.h + (box.y - newY)
    y = newY
  }
  cropBox.x = x
  cropBox.y = y
  cropBox.w = w
  cropBox.h = h
}

const endCropDrag = () => {
  dragState = null
  window.removeEventListener('pointermove', onCropDrag)
  window.removeEventListener('pointerup', endCropDrag)
}

const startCropDrag = (event, mode, handle = null) => {
  event.preventDefault()
  event.stopPropagation()
  dragState = {
    mode,
    handle,
    startX: event.clientX,
    startY: event.clientY,
    startBox: { x: cropBox.x, y: cropBox.y, w: cropBox.w, h: cropBox.h },
  }
  window.addEventListener('pointermove', onCropDrag)
  window.addEventListener('pointerup', endCropDrag)
}

const setCropRatioPreset = (ratio) => {
  if (ratio === '21:9') {
    cropBox.w = 90
    cropBox.h = Math.round(90 * (9 / 21))
    cropBox.x = 5
    cropBox.y = Math.round((100 - cropBox.h) / 2)
  } else if (ratio === '16:9') {
    cropBox.w = 80
    cropBox.h = Math.round(80 * (9 / 16))
    cropBox.x = 10
    cropBox.y = Math.round((100 - cropBox.h) / 2)
  } else if (ratio === '4:3') {
    cropBox.w = 60
    cropBox.h = Math.round(60 * (3 / 4))
    cropBox.x = 20
    cropBox.y = Math.round((100 - cropBox.h) / 2)
  } else {
    cropBox.w = 80
    cropBox.h = 60
    cropBox.x = 10
    cropBox.y = 20
  }
}

const executeCropAndUpload = () => {
  if (!cropperSrc.value) return

  isUploadingHeroImage.value = cropperTargetField.value
  showCropper.value = false

  const img = new window.Image()
  img.src = cropperSrc.value
  img.onload = async () => {
    try {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')

      const sx = (cropBox.x / 100) * img.naturalWidth
      const sy = (cropBox.y / 100) * img.naturalHeight
      const sw = (cropBox.w / 100) * img.naturalWidth
      const sh = (cropBox.h / 100) * img.naturalHeight

      canvas.width = sw
      canvas.height = sh

      ctx.drawImage(img, sx, sy, sw, sh, 0, 0, sw, sh)

      canvas.toBlob(async (blob) => {
        if (!blob) {
          toast.error(m('toasts.cropExtractError'))
          isUploadingHeroImage.value = ''
          return
        }

        const fileName = (cropperFile.value?.name || 'banner.jpg').replace(/\.[^/.]+$/, '') + '_cropped.jpg'
        const file = new File([blob], fileName, { type: 'image/jpeg' })

        try {
          const { data } = await uploadService.image(file)
          heroForm[cropperTargetField.value] = normalizeStorageAssetUrl(data.url)
          toast.success(m('toasts.cropSuccess'))
        } catch (error) {
          toast.error(error.response?.data?.message || m('toasts.cropUploadError'))
        } finally {
          isUploadingHeroImage.value = ''
          cropperSrc.value = ''
          cropperFile.value = null
        }
      }, 'image/jpeg', 0.9)
    } catch (err) {
      console.error(err)
      toast.error(m('toasts.cropError'))
      isUploadingHeroImage.value = ''
    }
  }
}

const handleHeroImageFileChange = async (event, field) => {
  const file = event.target.files?.[0]
  if (!file) return

  if (field === 'backgroundImageUrl') {
    cropperTargetField.value = field
    cropperFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => {
      cropperSrc.value = e.target.result
      setCropRatioPreset('21:9')
      showCropper.value = true
    }
    reader.readAsDataURL(file)
    event.target.value = ''
  } else {
    isUploadingHeroImage.value = field
    try {
      const { data } = await uploadService.image(file)
      heroForm[field] = normalizeStorageAssetUrl(data.url)
      toast.success(m('toasts.bannerUploaded'))
    } catch (error) {
      toast.error(error.response?.data?.message || m('toasts.bannerUploadError'))
    } finally {
      isUploadingHeroImage.value = ''
      event.target.value = ''
    }
  }
}

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
    : 'border-slate-200 bg-slate-50 text-slate-500'

const getStatusValue = (label) =>
  [...Object.entries(statusLabels.value), ...Object.entries(heroStatusLabels.value)].find(([, value]) => value === label)?.[0] || label

const filteredHeroBanners = computed(() => {
  const keyword = heroSearchQuery.value.trim().toLowerCase()
  return heroBanners.value.filter((banner) => {
    const haystack = [banner.title, banner.subtitle, banner.description].filter(Boolean).join(' ').toLowerCase()
    const matchesSearch = !keyword || haystack.includes(keyword)
    const matchesStatus = heroStatusFilter.value === t('admin.shared.all') || banner.status === getStatusValue(heroStatusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const totalHeroPages = computed(() => Math.max(1, Math.ceil(filteredHeroBanners.value.length / pageSize)))
const paginatedHeroBanners = computed(() =>
  filteredHeroBanners.value.slice((heroCurrentPage.value - 1) * pageSize, heroCurrentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredHeroBanners.value.length }))

const fetchHeroBanners = async () => {
  isLoadingHeroBanners.value = true
  heroBannerError.value = ''
  try {
    const { data } = await heroBannerService.list()
    heroBanners.value = Array.isArray(data) ? data.map(normalizeHeroBanner) : []
  } catch (error) {
    heroBannerError.value = error.response?.data?.message || m('uploadErrors.heroLoadFailed')
    throw error
  } finally {
    isLoadingHeroBanners.value = false
  }
}

const saveHeroBanner = async () => {
  if (!heroForm.title.trim()) {
    toast.error(m('toasts.heroTitleRequired'))
    return
  }

  const payload = {
    title: heroForm.title.trim(),
    subtitle: '',
    description: '',
    backgroundImageUrl: normalizeStorageAssetUrl(heroForm.backgroundImageUrl),
    thumbnailImageUrl: '',
    tone: 'light',
    sortOrder: Number(heroForm.sortOrder || 0),
    status: heroForm.status || 'ACTIVE',
  }

  try {
    const request = editingHeroId.value ? heroBannerService.update(editingHeroId.value, payload) : heroBannerService.create(payload)
    const { data } = await request
    const normalized = normalizeHeroBanner(data)
    const index = heroBanners.value.findIndex((item) => item.id === normalized.id)
    if (index === -1) heroBanners.value.unshift(normalized)
    else heroBanners.value.splice(index, 1, normalized)
    toast.success(heroMode.value === 'create' ? m('toasts.heroCreated') : m('toasts.heroUpdated'))
    closeHeroModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.heroSaveError'))
  }
}

const confirmDeleteHeroBanner = async () => {
  try {
    await heroBannerService.remove(pendingDeleteHeroId.value)
    heroBanners.value = heroBanners.value.filter((item) => item.id !== pendingDeleteHeroId.value)
    toast.success(m('toasts.heroDeleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.heroDeleteError'))
  } finally {
    pendingDeleteHeroId.value = null
  }
}

watch([heroSearchQuery, heroStatusFilter], () => {
  heroCurrentPage.value = 1
})

onMounted(() => {
  fetchHeroBanners().catch(() => {
    toast.error(m('toasts.partialLoadError'))
  })
})

defineExpose({ openCreate: openCreateHeroModal })
</script>

<template>
  <AdminShellFrame variant="toolbar" inner="toolbar">
    <SearchFilterBar
      v-model:search="heroSearchQuery"
      v-model:status="heroStatusFilter"
      :search-label="m('filters.heroSearchLabel')"
      :search-placeholder="m('filters.heroSearchPlaceholder')"
      :status-label="m('filters.heroStatusLabel')"
      :status-options="heroStatusFilters"
    />
  </AdminShellFrame>

  <AdminShellFrame v-if="heroBannerError" as="p" variant="alert" class="admin-list-alert">
    {{ heroBannerError }}
  </AdminShellFrame>

  <AdminShellFrame v-if="isLoadingHeroBanners" variant="body" inner="pad">
    <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
  </AdminShellFrame>

  <AdminShellFrame v-else-if="!filteredHeroBanners.length" variant="body" inner="pad">
    <EmptyState :message="m('emptyHero')" />
  </AdminShellFrame>

  <AdminShellFrame v-else variant="body" visibility="desktop">
    <AdminShellTablePanel :title="m('tabs.hero')" :count-text="listCountText">
      <table class="admin-shell-table">
        <colgroup>
          <col style="width: 10%" />
          <col style="width: 30%" />
          <col style="width: 14%" />
          <col style="width: 12%" />
          <col style="width: 14%" />
          <col style="width: 10%" />
          <col style="width: 10%" />
        </colgroup>
        <thead>
          <tr>
            <th>{{ m('columns.hero.image') }}</th>
            <th>{{ m('columns.hero.content') }}</th>
            <th>{{ m('columns.hero.background') }}</th>
            <th>{{ m('columns.hero.tone') }}</th>
            <th class="text-center">{{ m('columns.hero.status') }}</th>
            <th>{{ m('columns.hero.sortOrder') }}</th>
            <th class="text-right">{{ m('columns.hero.actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="banner in paginatedHeroBanners" :key="banner.id">
            <td>
              <img v-if="banner.backgroundImageUrl" :src="resolveBackendAssetUrl(banner.backgroundImageUrl)" :alt="banner.title" class="h-12 w-14 rounded-xl border border-slate-100 object-cover shadow-sm" />
              <div v-else class="grid h-12 w-14 place-items-center rounded-xl border border-slate-100 bg-slate-50 text-slate-400">
                <ImageIcon class="h-4 w-4" />
              </div>
            </td>
            <td>
              <p class="truncate font-bold text-avocado-950">{{ banner.title }}</p>
            </td>
            <td class="admin-shell-cell-muted font-semibold">
              {{ banner.backgroundImageUrl ? m('misc.hasBackgroundYes') : m('misc.hasBackgroundNo') }}
            </td>
            <td class="admin-shell-cell-muted font-semibold">{{ banner.tone === 'dark' ? m('misc.toneDark') : m('misc.toneLight') }}</td>
            <td class="text-center">
              <span class="inline-flex min-w-[92px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(banner.status)">
                {{ heroStatusLabels[banner.status] || banner.status }}
              </span>
            </td>
            <td class="admin-shell-cell-muted font-semibold">{{ banner.sortOrder }}</td>
            <td>
              <div class="flex justify-end gap-1.5">
                <button class="rounded-xl border border-avocado-100/50 p-2 font-bold text-avocado-700 transition hover:bg-avocado-50/50" :title="m('actions.edit')" @click="openEditHeroModal(banner)">
                  <Edit2 class="h-3.5 w-3.5" />
                </button>
                <button class="rounded-xl border border-red-100 p-2 font-bold text-red-600 transition hover:bg-red-50" :title="m('actions.delete')" @click="pendingDeleteHeroId = banner.id">
                  <Trash2 class="h-3.5 w-3.5" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </AdminShellTablePanel>
  </AdminShellFrame>

  <AdminShellFrame v-if="!isLoadingHeroBanners && filteredHeroBanners.length" variant="body" visibility="mobile">
    <AdminShellTablePanel :title="m('tabs.hero')" :count-text="listCountText">
      <template #below>
        <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
          <article v-for="banner in paginatedHeroBanners" :key="banner.id" class="admin-shell-mobile-card">
            <div class="flex items-start gap-3">
              <img
                v-if="banner.backgroundImageUrl"
                :src="resolveBackendAssetUrl(banner.backgroundImageUrl)"
                :alt="banner.title"
                class="h-14 w-20 rounded-xl border border-slate-100 object-cover"
              />
              <div v-else class="grid h-14 w-20 shrink-0 place-items-center rounded-xl border border-slate-100 bg-slate-50 text-slate-400">
                <ImageIcon class="h-5 w-5" />
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="truncate font-black text-avocado-950">{{ banner.title }}</h3>
                <p class="mt-1 text-xs text-slate-500">{{ m('columns.hero.sortOrder') }}: {{ banner.sortOrder }}</p>
              </div>
              <span class="shrink-0 rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(banner.status)">
                {{ heroStatusLabels[banner.status] || banner.status }}
              </span>
            </div>
            <div class="mt-4 flex flex-wrap gap-2">
              <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditHeroModal(banner)">
                {{ m('actions.edit') }}
              </button>
              <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteHeroId = banner.id">
                {{ m('actions.delete') }}
              </button>
            </div>
          </article>
        </div>
      </template>
    </AdminShellTablePanel>
  </AdminShellFrame>

  <AdminShellFrame v-if="filteredHeroBanners.length" variant="footer">
    <Pagination
      :page="heroCurrentPage"
      :total-pages="totalHeroPages"
      :visible-count="paginatedHeroBanners.length"
      :total-count="filteredHeroBanners.length"
      :label="m('paginationLabels.banner')"
      @prev="heroCurrentPage = Math.max(1, heroCurrentPage - 1)"
      @next="heroCurrentPage = Math.min(totalHeroPages, heroCurrentPage + 1)"
    />
  </AdminShellFrame>

  <BaseModal :show="showHeroModal" :title="heroMode === 'create' ? m('modals.createHero') : m('modals.editHero')" max-width="max-w-5xl" @close="closeHeroModal">
      <form id="hero-form" class="grid gap-5" @submit.prevent="saveHeroBanner">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.bannerTitle') }}
            <input v-model="heroForm.title" required class="admin-input-premium" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.displayOrder') }}
            <input v-model.number="heroForm.sortOrder" type="number" min="0" class="admin-input-premium" />
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.status') }}
            <select v-model="heroForm.status" class="admin-input-premium cursor-pointer">
              <option v-for="status in productStatuses" :key="status" :value="status">{{ heroStatusLabels[status] }}</option>
            </select>
          </label>
        </div>

        <div>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.backgroundImage') }}
            <input v-model="heroForm.backgroundImageUrl" class="admin-input-premium" />
            <input type="file" accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif" class="w-full text-xs font-bold text-slate-600 file:mr-3 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white" :disabled="Boolean(isUploadingHeroImage)" @change="handleHeroImageFileChange($event, 'backgroundImageUrl')" />
            <span v-if="isUploadingHeroImage === 'backgroundImageUrl'" class="text-xs font-bold text-avocado-700 animate-pulse">{{ m('misc.uploadingHeroBg') }}</span>
            <img v-if="heroBackgroundPreviewUrl" :src="heroBackgroundPreviewUrl" :alt="heroForm.title || ''" class="h-28 w-full rounded-xl border border-slate-100 object-cover" />
          </label>
        </div>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
          <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition" @click="closeHeroModal">{{ m('actions.cancel') }}</button>
          <button class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60 transition shadow-md" form="hero-form" type="submit" :disabled="Boolean(isUploadingHeroImage)">
            {{ heroMode === 'create' ? m('addHero') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <BaseModal :show="showCropper" :title="m('modals.cropper')" max-width="max-w-3xl" @close="showCropper = false">
      <div class="space-y-5">
        <p class="text-center text-[11px] font-semibold text-slate-400">{{ m('misc.cropDragHint') }}</p>
        <div class="relative mx-auto border border-slate-200 rounded-xl overflow-hidden bg-slate-900 flex items-center justify-center p-2 max-h-[380px]">
          <div ref="cropWrapperRef" class="relative inline-block overflow-hidden max-w-full touch-none">
            <img :src="cropperSrc" :alt="m('misc.cropSourceAlt')" class="max-h-[340px] block select-none pointer-events-none" draggable="false" />
            <div
              class="absolute border-[2px] border-dashed border-lime-500 cursor-move"
              :style="{
                left: cropBox.x + '%',
                top: cropBox.y + '%',
                width: cropBox.w + '%',
                height: cropBox.h + '%',
                boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.65)'
              }"
              @pointerdown="startCropDrag($event, 'move')"
            >
              <span class="crop-handle crop-handle--nw" @pointerdown="startCropDrag($event, 'resize', 'nw')"></span>
              <span class="crop-handle crop-handle--ne" @pointerdown="startCropDrag($event, 'resize', 'ne')"></span>
              <span class="crop-handle crop-handle--sw" @pointerdown="startCropDrag($event, 'resize', 'sw')"></span>
              <span class="crop-handle crop-handle--se" @pointerdown="startCropDrag($event, 'resize', 'se')"></span>
            </div>
          </div>
        </div>

        <div class="grid gap-4 sm:grid-cols-2 bg-slate-50 p-4 rounded-xl border border-slate-100">
          <div class="sm:col-span-2 flex flex-wrap items-center gap-2">
            <span class="text-[10px] font-bold text-slate-400 mr-2">{{ m('misc.cropRatioLabel') }}</span>
            <button
              type="button"
              class="rounded-lg bg-white border border-slate-200 px-3 py-1.5 text-xs font-bold text-slate-700 hover:border-avocado-500 hover:text-avocado-600 transition"
              @click="setCropRatioPreset('21:9')"
            >
              {{ m('misc.ratio21x9') }}
            </button>
            <button
              type="button"
              class="rounded-lg bg-white border border-slate-200 px-3 py-1.5 text-xs font-bold text-slate-700 hover:border-avocado-500 hover:text-avocado-600 transition"
              @click="setCropRatioPreset('16:9')"
            >
              {{ m('misc.ratio16x9') }}
            </button>
            <button
              type="button"
              class="rounded-lg bg-white border border-slate-200 px-3 py-1.5 text-xs font-bold text-slate-700 hover:border-avocado-500 hover:text-avocado-600 transition"
              @click="setCropRatioPreset('4:3')"
            >
              {{ m('misc.ratio4x3') }}
            </button>
            <button
              type="button"
              class="rounded-lg bg-white border border-slate-200 px-3 py-1.5 text-xs font-bold text-slate-700 hover:border-avocado-500 hover:text-avocado-600 transition"
              @click="setCropRatioPreset('free')"
            >
              {{ m('misc.ratioFree') }}
            </button>
          </div>

          <div class="space-y-3">
            <label class="block text-xs font-bold text-slate-600">
              {{ m('misc.cropPosX', { value: cropBox.x }) }}
              <input
                type="range"
                min="0"
                :max="100 - cropBox.w"
                :value="cropBox.x"
                class="w-full accent-avocado-600 h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer"
                @input="adjustCropBox('x', $event.target.value)"
              />
            </label>
            <label class="block text-xs font-bold text-slate-600">
              {{ m('misc.cropPosY', { value: cropBox.y }) }}
              <input
                type="range"
                min="0"
                :max="100 - cropBox.h"
                :value="cropBox.y"
                class="w-full accent-avocado-600 h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer"
                @input="adjustCropBox('y', $event.target.value)"
              />
            </label>
          </div>

          <div class="space-y-3">
            <label class="block text-xs font-bold text-slate-600">
              {{ m('misc.cropWidth', { value: cropBox.w }) }}
              <input
                type="range"
                min="10"
                max="100"
                :value="cropBox.w"
                class="w-full accent-avocado-600 h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer"
                @input="adjustCropBox('w', $event.target.value)"
              />
            </label>
            <label class="block text-xs font-bold text-slate-600">
              {{ m('misc.cropHeight', { value: cropBox.h }) }}
              <input
                type="range"
                min="10"
                max="100"
                :value="cropBox.h"
                class="w-full accent-avocado-600 h-2 bg-slate-200 rounded-lg appearance-none cursor-pointer"
                @input="adjustCropBox('h', $event.target.value)"
              />
            </label>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
          <button
            type="button"
            class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition"
            @click="showCropper = false"
          >
            {{ m('actions.cancel') }}
          </button>
          <button
            type="button"
            class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 transition shadow-md"
            @click="executeCropAndUpload"
          >
            {{ m('misc.cropAndUpload') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteHeroId)"
      :title="m('confirmDelete.heroTitle')"
      :message="m('confirmDelete.heroMessage')"
      :confirm-text="m('confirmDelete.heroConfirm')"
      @cancel="pendingDeleteHeroId = null"
      @confirm="confirmDeleteHeroBanner"
    />
</template>

<style scoped>
.crop-handle {
  position: absolute;
  width: 14px;
  height: 14px;
  background: #fff;
  border: 2px solid #65a30d;
  border-radius: 9999px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.35);
  z-index: 2;
}

.crop-handle--nw {
  top: -7px;
  left: -7px;
  cursor: nwse-resize;
}

.crop-handle--ne {
  top: -7px;
  right: -7px;
  cursor: nesw-resize;
}

.crop-handle--sw {
  bottom: -7px;
  left: -7px;
  cursor: nesw-resize;
}

.crop-handle--se {
  bottom: -7px;
  right: -7px;
  cursor: nwse-resize;
}
</style>
