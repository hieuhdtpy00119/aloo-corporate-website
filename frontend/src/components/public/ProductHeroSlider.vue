<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import VerticalProductNav from './VerticalProductNav.vue'

const props = defineProps({
  featuredProducts: {
    type: Array,
    default: () => [],
  },
})

const fallbackSlides = [
  {
    id: 1,
    title: 'Kem bơ truyền thống',
    subtitle: 'Signature ALOO',
    description: 'Bơ sáp chín tự nhiên hòa cùng kem tươi mát lạnh, tạo vị béo mịn và thơm nhẹ.',
    productImage: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85',
    bgImage: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1800&q=80',
    tone: 'light',
  },
  {
    id: 2,
    title: 'Kem bơ sầu riêng',
    subtitle: 'Tropical Bold',
    description: 'Lớp bơ mịn kết hợp sầu riêng đậm vị, dành cho khách thích hương nhiệt đới rõ nét.',
    productImage: 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85',
    bgImage: 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1800&q=80',
    tone: 'dark',
  },
  {
    id: 3,
    title: 'Sinh tố bơ kem',
    subtitle: 'Creamy Smoothie',
    description: 'Sinh tố bơ sánh mịn, thêm viên kem vàng mát lạnh cho trải nghiệm nhẹ và dễ uống.',
    productImage: 'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1200&q=85',
    bgImage: 'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1800&q=80',
    tone: 'light',
  },
  {
    id: 4,
    title: 'Kem bơ cacao',
    subtitle: 'Cacao Edition',
    description: 'Vị bơ béo nhẹ gặp cacao thơm dịu, tạo chiều sâu vị giác nhưng vẫn giữ cảm giác tươi mát.',
    productImage: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1200&q=85',
    bgImage: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1800&q=80',
    tone: 'dark',
  },
]

const activeIndex = ref(0)
let timer = null

const slides = computed(() =>
  props.featuredProducts.slice(0, 4).map((product, index) => ({
    id: product.id || index + 1,
    title: product.name || product.title,
    subtitle: product.subtitle || fallbackSlides[index]?.subtitle || 'ALOO Signature',
    description: product.description || fallbackSlides[index]?.description,
    productImage: product.imageUrl || product.image || product.productImage || fallbackSlides[index]?.productImage,
    bgImage: product.imageUrl || product.image || product.bgImage || fallbackSlides[index]?.bgImage,
    tone: product.tone || fallbackSlides[index]?.tone || 'light',
  })),
)
const activeSlide = computed(() => slides.value[activeIndex.value] || null)
const isDark = computed(() => activeSlide.value?.tone === 'dark')

const selectSlide = (index) => {
  activeIndex.value = index
}

const nextSlide = () => {
  if (!slides.value.length) return
  activeIndex.value = (activeIndex.value + 1) % slides.value.length
}

const prevSlide = () => {
  if (!slides.value.length) return
  activeIndex.value = activeIndex.value === 0 ? slides.value.length - 1 : activeIndex.value - 1
}

const handleKeydown = (event) => {
  if (event.key === 'ArrowDown' || event.key === 'ArrowRight') nextSlide()
  if (event.key === 'ArrowUp' || event.key === 'ArrowLeft') prevSlide()
}

watch(
  () => slides.value.length,
  (length) => {
    if (activeIndex.value >= length) activeIndex.value = 0
  },
)

onMounted(() => {
  timer = window.setInterval(nextSlide, 5600)
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  if (timer) window.clearInterval(timer)
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <section class="relative isolate min-h-[calc(100vh-76px)] overflow-hidden bg-avocado-950" aria-label="ALOO product hero slider">
    <VerticalProductNav v-if="slides.length" :slides="slides" :active-index="activeIndex" @select="selectSlide" @prev="prevSlide" @next="nextSlide" />

    <transition name="hero-bg" mode="out-in">
      <img v-if="activeSlide" :key="activeSlide.id" :src="activeSlide.bgImage" :alt="`${activeSlide.title} background`" class="absolute inset-0 -z-30 h-full w-full scale-110 object-cover object-center opacity-70 blur-[2px]" :loading="activeIndex === 0 ? 'eager' : 'lazy'" :fetchpriority="activeIndex === 0 ? 'high' : 'auto'" />
    </transition>
    <div class="absolute inset-0 -z-20" :class="isDark ? 'bg-[linear-gradient(105deg,rgba(9,22,11,0.94),rgba(33,75,36,0.66)_48%,rgba(7,15,8,0.76))]' : 'bg-[linear-gradient(105deg,rgba(255,244,213,0.94),rgba(255,250,235,0.46)_46%,rgba(43,90,39,0.34))]'"></div>
    <div class="absolute left-[14%] top-[14%] -z-10 h-72 w-72 rounded-full blur-3xl" :class="isDark ? 'bg-avocado-400/20' : 'bg-cream-300/55'"></div>
    <div class="absolute bottom-[10%] right-[8%] -z-10 h-[34rem] w-[34rem] rounded-full bg-white/18 blur-3xl"></div>
    <div class="absolute right-[9%] top-[14%] hidden h-32 w-32 rounded-full border border-white/20 lg:block"></div>
    <div class="absolute bottom-[20%] left-[24%] hidden h-20 w-20 rounded-full bg-cream-200/25 blur-md lg:block"></div>

    <div class="relative mx-auto grid min-h-[calc(100vh-76px)] max-w-7xl items-center gap-8 px-4 pb-32 pt-20 sm:px-6 lg:grid-cols-[0.92fr_1.08fr] lg:px-8 lg:pb-20 lg:pl-24">
      <transition name="hero-copy" mode="out-in">
        <div v-if="activeSlide" :key="`copy-${activeSlide.id}`" class="relative z-30 max-w-3xl">
          <p class="text-xs font-black uppercase tracking-[0.34em]" :class="isDark ? 'text-cream-200' : 'text-avocado-700'">
            {{ activeSlide.subtitle }}
          </p>
          <h1 class="mt-6 text-[clamp(3.6rem,8vw,8.8rem)] font-black leading-[0.84] tracking-tight" :class="isDark ? 'text-white' : 'text-avocado-950'">
            {{ activeSlide.title }}
          </h1>
          <p class="mt-7 max-w-xl text-lg leading-8 md:text-xl" :class="isDark ? 'text-white/78' : 'text-slate-700'">
            {{ activeSlide.description }}
          </p>
        </div>
        <div v-else class="relative z-30 max-w-3xl">
          <p class="text-xs font-black uppercase tracking-[0.34em] text-avocado-700">ALOO Products</p>
          <h1 class="mt-6 text-[clamp(3rem,7vw,7rem)] font-black leading-[0.9] tracking-tight text-avocado-950">
            Chưa có sản phẩm
          </h1>
          <p class="mt-7 max-w-xl text-lg leading-8 text-slate-700">
            Sản phẩm public sẽ hiển thị sau khi được thêm và bật trạng thái trong Admin CMS.
          </p>
        </div>
      </transition>

      <div class="relative min-h-[56vh] lg:min-h-[720px]">
        <transition name="hero-product" mode="out-in">
          <div v-if="activeSlide" :key="`product-${activeSlide.id}`" class="absolute inset-0">
            <img :src="activeSlide.productImage" :alt="activeSlide.title" class="absolute left-[46%] top-1/2 h-[60vh] max-h-[720px] min-h-[390px] w-[88%] -translate-x-1/2 -translate-y-1/2 rounded-[46%_54%_48%_52%/44%_48%_52%_56%] object-cover object-center shadow-[0_70px_170px_rgba(0,0,0,0.38)] lg:left-1/2" :loading="activeIndex === 0 ? 'eager' : 'lazy'" :fetchpriority="activeIndex === 0 ? 'high' : 'auto'" />
            <img :src="activeSlide.productImage" :alt="`${activeSlide.title} texture detail`" class="absolute right-[4%] top-[11%] h-32 w-32 rotate-12 rounded-full object-cover opacity-35 blur-sm sm:h-40 sm:w-40" loading="lazy" />
            <div class="absolute bottom-[15%] left-[12%] h-24 w-24 rounded-full bg-cream-200/30 blur-xl"></div>
          </div>
        </transition>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hero-bg-enter-active,
.hero-bg-leave-active,
.hero-copy-enter-active,
.hero-copy-leave-active,
.hero-product-enter-active,
.hero-product-leave-active {
  transition: all 780ms cubic-bezier(0.22, 1, 0.36, 1);
}

.hero-bg-enter-from,
.hero-bg-leave-to {
  opacity: 0;
  transform: scale(1.04);
}

.hero-copy-enter-from {
  opacity: 0;
  transform: translateY(36px);
}

.hero-copy-leave-to {
  opacity: 0;
  transform: translateY(-18px);
}

.hero-product-enter-from {
  opacity: 0;
  transform: translateY(34px) scale(0.96);
}

.hero-product-leave-to {
  opacity: 0;
  transform: translateY(-20px) scale(1.03);
}
</style>
