<script setup>
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import {
  ADMIN_STATIC_PAGES,
  FRANCHISE_HASH_ANCHORS,
  inferAdminLinkState,
  isActiveProduct,
  isPublishedPost,
  resolveAdminLink,
} from '../../utils/adminLinkPicker'

const props = defineProps({
  modelValue: { type: String, default: '' },
  module: { type: String, default: 'franchise' },
  products: { type: Array, default: () => [] },
  posts: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  allowHash: { type: Boolean, default: true },
  allowNone: { type: Boolean, default: true },
  error: { type: String, default: '' },
})

const emit = defineEmits(['update:modelValue'])
const { t } = useI18n()
const m = (suffix, params) => t(`admin.${props.module}.${suffix}`, params)

const linkType = ref('NONE')
const linkTarget = ref('')
const customLink = ref('')

const staticLinkOptions = computed(() =>
  ADMIN_STATIC_PAGES.map((item) => ({
    value: item.value,
    label: m(`staticLinks.${item.key}`),
  })),
)

const hashLinkOptions = computed(() =>
  FRANCHISE_HASH_ANCHORS.map((item) => ({
    value: item.value,
    label: m(`hashLinks.${item.key}`),
  })),
)

const linkTypeOptions = computed(() => {
  const options = []
  if (props.allowNone) options.push({ value: 'NONE', label: m('linkTypes.NONE') })
  if (props.allowHash) options.push({ value: 'HASH', label: m('linkTypes.HASH') })
  options.push(
    { value: 'STATIC', label: m('linkTypes.STATIC') },
    { value: 'PRODUCT', label: m('linkTypes.PRODUCT') },
    { value: 'POST', label: m('linkTypes.POST') },
    { value: 'CUSTOM', label: m('linkTypes.CUSTOM') },
  )
  return options
})

const linkableProducts = computed(() => {
  const active = props.products.filter(isActiveProduct)
  if (linkType.value !== 'PRODUCT' || !linkTarget.value) return active
  const selected = props.products.find((product) => String(product.slug || product.id) === linkTarget.value)
  if (selected && !active.some((product) => product.id === selected.id)) {
    return [selected, ...active]
  }
  return active
})

const linkablePosts = computed(() => {
  const published = props.posts.filter(isPublishedPost)
  if (linkType.value !== 'POST' || !linkTarget.value) return published
  const selected = props.posts.find((post) => String(post.slug || post.id) === linkTarget.value)
  if (selected && !published.some((post) => post.id === selected.id)) {
    return [selected, ...published]
  }
  return published
})

const resolvedLink = computed(() =>
  resolveAdminLink({
    type: linkType.value,
    target: linkTarget.value,
    custom: customLink.value,
  }),
)

const applyInferredState = (link) => {
  const state = inferAdminLinkState(link, { allowHash: props.allowHash })
  linkType.value = state.type
  linkTarget.value = state.target
  customLink.value = state.custom || (state.type === 'CUSTOM' ? link : '')
}

watch(
  () => props.modelValue,
  (value) => {
    if (value !== resolvedLink.value) applyInferredState(value)
  },
  { immediate: true },
)

watch(resolvedLink, (value) => {
  if (value !== props.modelValue) emit('update:modelValue', value)
})

const handleLinkTypeChange = () => {
  if (linkType.value === 'NONE') {
    linkTarget.value = ''
    customLink.value = ''
    return
  }
  if (linkType.value === 'STATIC') {
    linkTarget.value = '/consultation'
    customLink.value = ''
    return
  }
  if (linkType.value === 'HASH') {
    linkTarget.value = '#investment'
    customLink.value = ''
    return
  }
  if (linkType.value === 'CUSTOM') {
    linkTarget.value = ''
    customLink.value = props.modelValue || ''
    return
  }
  linkTarget.value = ''
  customLink.value = ''
}
</script>

<template>
  <div class="grid gap-3 md:col-span-2">
    <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ m('fields.linkType') }}
      <select v-model="linkType" class="admin-input-premium cursor-pointer" @change="handleLinkTypeChange">
        <option v-for="option in linkTypeOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
      </select>
    </label>

    <label v-if="linkType === 'HASH'" class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ m('fields.hashSection') }}
      <select v-model="linkTarget" class="admin-input-premium cursor-pointer">
        <option v-for="option in hashLinkOptions" :key="option.value" :value="option.value">
          {{ option.label }} — {{ option.value }}
        </option>
      </select>
    </label>

    <label v-else-if="linkType === 'STATIC'" class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ m('fields.staticPage') }}
      <select v-model="linkTarget" class="admin-input-premium cursor-pointer">
        <option v-for="option in staticLinkOptions" :key="option.value" :value="option.value">
          {{ option.label }} — {{ option.value }}
        </option>
      </select>
    </label>

    <label v-else-if="linkType === 'PRODUCT'" class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ m('fields.product') }}
      <select v-model="linkTarget" class="admin-input-premium cursor-pointer" :disabled="loading">
        <option value="">{{ m('placeholders.selectProduct') }}</option>
        <option v-for="product in linkableProducts" :key="product.id" :value="String(product.slug || product.id)">
          {{ product.name }} — /products/{{ product.slug || product.id }}{{ !isActiveProduct(product) ? ` (${m('linkOptions.inactive')})` : '' }}
        </option>
      </select>
      <span v-if="!linkableProducts.length && !loading" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('linkOptions.noActiveProducts') }}</span>
    </label>

    <label v-else-if="linkType === 'POST'" class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ m('fields.post') }}
      <select v-model="linkTarget" class="admin-input-premium cursor-pointer" :disabled="loading">
        <option value="">{{ m('placeholders.selectPost') }}</option>
        <option v-for="post in linkablePosts" :key="post.id" :value="String(post.slug || post.id)">
          {{ post.title }} — /blog/{{ post.slug || post.id }}{{ !isPublishedPost(post) ? ` (${m('linkOptions.inactive')})` : '' }}
        </option>
      </select>
      <span v-if="!linkablePosts.length && !loading" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('linkOptions.noPublishedPosts') }}</span>
    </label>

    <label v-else-if="linkType === 'CUSTOM'" class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
      {{ m('fields.customLink') }}
      <input v-model="customLink" class="admin-input-premium" :placeholder="m('placeholders.customLink')" />
    </label>

    <p v-if="error" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ error }}</p>

    <div
      v-if="linkType !== 'NONE'"
      class="rounded-xl border border-avocado-100 bg-avocado-50/40 px-4 py-3 text-xs font-semibold text-slate-600"
    >
      {{ m('fields.linkPreview') }}:
      <span class="font-black text-avocado-800">{{ resolvedLink || m('fields.linkPending') }}</span>
    </div>
  </div>
</template>
