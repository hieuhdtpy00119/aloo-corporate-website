import { defineStore } from 'pinia'
import { heroBannerService, resolveBackendAssetUrl } from '../services/cmsService'

const normalizeHero = (slide) => ({
  ...slide,
  backgroundImage: resolveBackendAssetUrl(slide.backgroundImageUrl || slide.backgroundImage || slide.bgImage || ''),
  productImage: resolveBackendAssetUrl(slide.productImageUrl || slide.productImage || slide.image || ''),
  thumbnailImage: resolveBackendAssetUrl(slide.thumbnailImageUrl || slide.thumbnailImage || slide.productImageUrl || ''),
  sortOrder: Number(slide.sortOrder || slide.id || 0),
  status: slide.status || 'ACTIVE',
})

export const useProductPageStore = defineStore('productPage', {
  state: () => ({
    heroSlides: [],
    loading: false,
    error: '',
  }),
  getters: {
    visibleHeroSlides: (state) =>
      state.heroSlides
        .map(normalizeHero)
        .filter((slide) => slide.status === 'ACTIVE')
        .sort((a, b) => Number(a.sortOrder) - Number(b.sortOrder)),
  },
  actions: {
    async fetchProductPageContent() {
      this.loading = true
      this.error = ''
      try {
        const heroResult = await heroBannerService.list()
        const heroData = Array.isArray(heroResult.data) ? heroResult.data : []
        this.heroSlides = heroData.map(normalizeHero)
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Không tải được nội dung trang sản phẩm'
      } finally {
        this.loading = false
      }
    },
  },
})
