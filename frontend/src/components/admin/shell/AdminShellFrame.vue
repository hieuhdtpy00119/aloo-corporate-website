<script setup>
defineProps({
  as: { type: String, default: 'section' },
  variant: { type: String, default: 'body' },
  inner: { type: String, default: '' },
  padded: { type: Boolean, default: false },
  visibility: { type: String, default: '' },
})
</script>

<template>
  <component
    :is="as"
    class="admin-shell-frame"
    :class="[
      `admin-shell-frame--${variant}`,
      visibility === 'desktop' && 'admin-shell-desktop-only',
      visibility === 'mobile' && 'admin-shell-mobile-only',
    ]"
  >
    <div
      v-if="inner"
      class="admin-shell-frame__inner"
      :class="[
        `admin-shell-frame__inner--${inner}`,
        padded && 'admin-shell-frame__inner--pad',
      ]"
    >
      <slot />
    </div>
    <slot v-else />
    <slot name="after" />
  </component>
</template>
