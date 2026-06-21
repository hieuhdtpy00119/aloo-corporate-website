<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  poster: {
    type: Object,
    default: () => null,
  },
  postersByBranch: {
    type: Object,
    default: () => null,
  },
})

const selectedBranch = ref('quy-nhon')

const toBranchLabel = (branchKey) =>
  String(branchKey || '')
    .split('-')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ')

const branches = computed(() => {
  const keys = Object.keys(props.postersByBranch || {})
  return keys.map((key) => ({
    label: props.postersByBranch[key]?.label || toBranchLabel(key),
    value: key,
  }))
})

const activeBranch = computed(() =>
  branches.value.some((branch) => branch.value === selectedBranch.value)
    ? selectedBranch.value
    : branches.value[0]?.value,
)

const currentPoster = computed(() => {
  const branchPoster = props.postersByBranch?.[activeBranch.value]
  if (!branchPoster) return props.poster
  return {
    title: branchPoster.title,
    subtitle: branchPoster.subtitle,
    image: branchPoster.imageUrl,
    alt: branchPoster.altText,
    status: branchPoster.status,
  }
})
</script>

<template>
  <section v-if="currentPoster?.status === 'ACTIVE' && currentPoster.image" class="bg-gradient-to-b from-avocado-100/20 via-avocado-100/40 to-transparent px-4 py-16 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-4xl text-center">
      <p class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">{{ currentPoster.subtitle || 'Thực đơn' }}</p>
      <h2 class="mt-2 text-3xl font-black tracking-tight text-avocado-950 md:text-4xl">{{ currentPoster.title || 'Menu theo chi nhánh' }}</h2>
      
      <div class="mt-6 inline-flex rounded-full bg-white p-1.5 shadow-md border border-avocado-100/40">
        <button
          v-for="branch in branches"
          :key="branch.value"
          type="button"
          class="rounded-full px-6 py-2.5 text-xs font-bold uppercase tracking-wider transition-all duration-300"
          :class="activeBranch === branch.value ? 'bg-avocado-600 text-white shadow-md' : 'text-slate-500 hover:text-avocado-800'"
          @click="selectedBranch = branch.value"
        >
          {{ branch.label }}
        </button>
      </div>

      <div class="mx-auto mt-8 max-w-xl overflow-hidden rounded-3xl bg-white p-3 shadow-xl border border-avocado-100/40 relative group">
        <div class="absolute inset-0 bg-avocado-950/20 opacity-0 group-hover:opacity-100 transition duration-300 flex items-center justify-center pointer-events-none rounded-3xl">
          <span class="bg-white/90 backdrop-blur-sm text-avocado-950 text-xs font-bold px-4 py-2 rounded-full shadow-lg">Xem chi tiết</span>
        </div>
        
        <div class="overflow-hidden rounded-2xl bg-cream-50">
          <Transition name="fade" mode="out-in">
            <img
              v-if="currentPoster.image"
              :key="`${activeBranch}-${currentPoster.image}`"
              :src="currentPoster.image"
              :alt="currentPoster.alt || currentPoster.title"
              class="max-h-[580px] w-full rounded-2xl object-cover mx-auto"
              loading="lazy"
            />
            <div v-else :key="`empty-${activeBranch}`" class="grid min-h-[340px] place-items-center px-5 text-center text-sm text-slate-500">
              <p class="font-bold">Chưa có ảnh menu poster. Vui lòng thêm ảnh trong admin.</p>
            </div>
          </Transition>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition:
    opacity 0.25s ease,
    transform 0.25s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.98);
}
</style>
