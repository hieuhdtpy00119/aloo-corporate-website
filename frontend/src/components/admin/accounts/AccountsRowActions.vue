<script setup>
import { computed, nextTick, onBeforeUnmount, ref, watch } from 'vue'

const props = defineProps({
  user: { type: Object, required: true },
  open: { type: Boolean, default: false },
  layout: { type: String, default: 'desktop' },
  showPromote: { type: Boolean, default: false },
  showDemote: { type: Boolean, default: false },
  lockAccountLabel: { type: String, default: '' },
  activateAccountLabel: { type: String, default: '' },
  actionsLabel: { type: String, default: '' },
  promoteLabel: { type: String, default: '' },
  demoteLabel: { type: String, default: '' },
  passwordLabel: { type: String, default: '' },
  editLabel: { type: String, default: '' },
  deleteLabel: { type: String, default: '' },
  showPassword: { type: Boolean, default: true },
  showDelete: { type: Boolean, default: true },
  showStatusToggle: { type: Boolean, default: true },
})

const statusToggle = computed(() => {
  if (props.user.status === 'ACTIVE') {
    return { status: 'LOCKED', label: props.lockAccountLabel }
  }
  if (props.user.status === 'INACTIVE' || props.user.status === 'LOCKED') {
    return { status: 'ACTIVE', label: props.activateAccountLabel }
  }
  return null
})

const showStatusAction = computed(() => props.showStatusToggle && Boolean(statusToggle.value))

const hasFooterActions = computed(() => showStatusAction.value || props.showDelete)

defineEmits(['toggle', 'action'])

const menuBtn = ref(null)
const menuRef = ref(null)
const menuStyle = ref({ top: '0px', left: '0px' })
const menuVisible = ref(false)
const isDesktopViewport = ref(true)

const syncViewport = () => {
  if (typeof window === 'undefined') return
  isDesktopViewport.value = window.matchMedia('(min-width: 1024px)').matches
}

const isLayoutActive = computed(() => (
  props.layout === 'desktop' ? isDesktopViewport.value : !isDesktopViewport.value
))

const isTriggerVisible = (el) => {
  if (!el) return false

  const style = window.getComputedStyle(el)
  if (style.display === 'none' || style.visibility === 'hidden') return false

  const rect = el.getBoundingClientRect()
  return rect.width > 0 && rect.height > 0
}

const positionMenu = () => {
  const trigger = menuBtn.value
  const menu = menuRef.value
  if (!trigger || !menu || !isTriggerVisible(trigger)) {
    menuVisible.value = false
    return
  }

  const rect = trigger.getBoundingClientRect()
  const menuWidth = menu.offsetWidth || 188
  const menuHeight = menu.offsetHeight || 120
  const gap = 6
  const viewportPadding = 8

  let top = rect.bottom + gap
  let left = rect.right - menuWidth

  if (left < viewportPadding) left = viewportPadding
  if (left + menuWidth > window.innerWidth - viewportPadding) {
    left = window.innerWidth - menuWidth - viewportPadding
  }

  if (top + menuHeight > window.innerHeight - viewportPadding) {
    top = Math.max(viewportPadding, rect.top - menuHeight - gap)
  }

  menuStyle.value = {
    top: `${top}px`,
    left: `${left}px`,
  }
}

const updateMenu = async () => {
  if (!props.open || !isLayoutActive.value) {
    menuVisible.value = false
    return
  }

  if (!menuBtn.value || !isTriggerVisible(menuBtn.value)) {
    menuVisible.value = false
    return
  }

  menuVisible.value = true
  await nextTick()
  positionMenu()
}

const onViewportChange = () => {
  syncViewport()
  if (props.open) updateMenu()
}

watch(() => props.open, () => {
  updateMenu()
})

watch(isLayoutActive, () => {
  if (props.open) updateMenu()
})

watch(() => props.user.id, () => {
  if (props.open) updateMenu()
})

watch([showStatusAction, () => props.showDelete, () => props.showPassword, () => props.showDemote, () => props.showPromote], () => {
  if (props.open && menuVisible.value) nextTick(positionMenu)
})

if (typeof window !== 'undefined') {
  syncViewport()
  window.addEventListener('resize', onViewportChange)
  window.addEventListener('scroll', onViewportChange, true)
}

onBeforeUnmount(() => {
  if (typeof window === 'undefined') return
  window.removeEventListener('resize', onViewportChange)
  window.removeEventListener('scroll', onViewportChange, true)
})
</script>

<template>
  <div class="accounts-actions">
    <button
      ref="menuBtn"
      type="button"
      class="accounts-menu-btn"
      :aria-label="actionsLabel"
      :aria-expanded="open && menuVisible"
      @click.stop="$emit('toggle')"
    >
      <slot name="icon" />
    </button>
    <Teleport to="body">
      <div
        v-if="open && menuVisible"
        ref="menuRef"
        class="accounts-dropdown accounts-dropdown--fixed"
        :style="menuStyle"
        @click.stop
      >
        <button
          v-if="showPromote"
          type="button"
          class="is-promote"
          @click="$emit('action', 'promote', null)"
        >
          {{ promoteLabel }}
        </button>
        <button
          v-if="showDemote"
          type="button"
          class="is-demote"
          @click="$emit('action', 'demote', null)"
        >
          {{ demoteLabel }}
        </button>
        <button v-if="showPassword" type="button" @click="$emit('action', 'password', null)">{{ passwordLabel }}</button>
        <button type="button" @click="$emit('action', 'edit', null)">{{ editLabel }}</button>
        <template v-if="hasFooterActions">
          <div class="accounts-dropdown-divider" />
          <button
            v-if="showStatusAction"
            type="button"
            @click="$emit('action', 'status', statusToggle.status)"
          >
            {{ statusToggle.label }}
          </button>
          <button
            v-if="showDelete"
            type="button"
            class="is-danger"
            @click="$emit('action', 'delete', null)"
          >
            {{ deleteLabel }}
          </button>
        </template>
      </div>
    </Teleport>
  </div>
</template>
