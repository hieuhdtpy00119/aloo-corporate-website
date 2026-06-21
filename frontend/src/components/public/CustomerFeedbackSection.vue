<script setup>
import { onMounted, ref } from 'vue'
import { Star } from 'lucide-vue-next'
import { feedbackService, resolveBackendAssetUrl } from '../../services/cmsService'

const feedbacks = ref([])
const isLoading = ref(false)
const errorMessage = ref('')

const loadFeedbacks = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await feedbackService.featured()
    feedbacks.value = Array.isArray(data) ? data : []
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Không tải được cảm nhận khách hàng'
  } finally {
    isLoading.value = false
  }
}

onMounted(loadFeedbacks)
</script>

<template>
  <section class="bg-white px-4 py-16 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-[1240px]">
      <div class="mb-10 border-b border-brand-forest/5 pb-4">
        <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Cảm nhận khách hàng</span>
        <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">Khách hàng nói gì về ALOO</h2>
      </div>

      <p v-if="errorMessage" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-bold text-red-700">{{ errorMessage }}</p>
      <div v-else-if="isLoading" class="grid gap-6 md:grid-cols-3">
        <div v-for="i in 3" :key="i" class="h-52 animate-pulse rounded-3xl bg-slate-100"></div>
      </div>
      <p v-else-if="!feedbacks.length" class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        Chưa có cảm nhận nổi bật.
      </p>

      <div v-else class="grid gap-6 md:grid-cols-3">
        <article v-for="feedback in feedbacks.slice(0, 6)" :key="feedback.id" class="overflow-hidden rounded-3xl border border-brand-forest/5 bg-cream-50 shadow-sm">
          <img v-if="feedback.avatarUrl" :src="resolveBackendAssetUrl(feedback.avatarUrl)" :alt="feedback.customerName" class="aspect-[5/3] w-full object-cover" />
          <div class="p-6">
            <div class="flex items-center gap-1 text-brand-sand">
              <Star v-for="star in 5" :key="star" class="h-4 w-4" :class="star <= feedback.rating ? 'fill-brand-sand' : 'fill-transparent opacity-35'" />
            </div>
            <p class="mt-4 line-clamp-4 text-sm font-medium leading-7 text-brand-muted">{{ feedback.content }}</p>
            <div class="mt-5 border-t border-brand-forest/5 pt-4">
              <h3 class="font-black text-brand-dark">{{ feedback.customerName }}</h3>
              <p v-if="feedback.storeName" class="mt-1 text-xs font-bold text-brand-forest">
                {{ feedback.storeName }}
              </p>
            </div>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>
