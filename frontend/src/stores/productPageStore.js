import { defineStore } from 'pinia'
import { heroBannerService, menuPosterService, resolveBackendAssetUrl } from '../services/cmsService'


const toBranchLabel = (branchKey) =>
  String(branchKey || '')
    .split('-')
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ')

const normalizeHero = (slide) => ({
  ...slide,
  backgroundImage: resolveBackendAssetUrl(slide.backgroundImageUrl || slide.backgroundImage || slide.bgImage || ''),
  productImage: resolveBackendAssetUrl(slide.productImageUrl || slide.productImage || slide.image || ''),
  thumbnailImage: resolveBackendAssetUrl(slide.thumbnailImageUrl || slide.thumbnailImage || slide.productImageUrl || ''),
  sortOrder: Number(slide.sortOrder || slide.id || 0),
  status: slide.status || 'ACTIVE',
})

const normalizePoster = (poster) => ({
  ...poster,
  branchKey: poster.branchKey || 'default',
  label: poster.label || toBranchLabel(poster.branchKey),
  altText: poster.altText || poster.alt || poster.title,
  imageUrl: resolveBackendAssetUrl(poster.imageUrl || poster.image || ''),
  sortOrder: Number(poster.sortOrder || poster.id || 0),
  status: poster.status || 'ACTIVE',
})

export const useProductPageStore = defineStore('productPage', {
  state: () => ({
    heroSlides: [],
    menuGroups: [],
    menuPoster: null,
    menuPosterByBranch: {},
    loading: false,
    error: '',
  }),
  getters: {
    visibleHeroSlides: (state) =>
      state.heroSlides
        .map(normalizeHero)
        .filter((slide) => slide.status === 'ACTIVE')
        .sort((a, b) => Number(a.sortOrder) - Number(b.sortOrder)),
    visibleMenuGroups: (state) =>
      state.menuGroups
        .filter((group) => group.status === 'ACTIVE')
        .map((group) => ({
          ...group,
          items: group.items
            .filter((item) => item.status === 'ACTIVE')
            .sort((a, b) => Number(a.sortOrder) - Number(b.sortOrder)),
        }))
        .sort((a, b) => Number(a.sortOrder) - Number(b.sortOrder)),
  },
  actions: {
    async fetchProductPageContent() {
      this.loading = true
      this.error = ''
      try {
        const [heroResult, posterResult] = await Promise.allSettled([
          heroBannerService.list(),
          menuPosterService.list(),
        ])

        if (heroResult.status === 'fulfilled') {
          const heroData = Array.isArray(heroResult.value.data) ? heroResult.value.data : []
          this.heroSlides = heroData.map(normalizeHero)
        }

        if (posterResult.status === 'fulfilled') {
          const posterData = Array.isArray(posterResult.value.data) ? posterResult.value.data : []
          const posters = posterData.map(normalizePoster)
          this.menuPoster = posters[0] || null
          this.menuPosterByBranch = posters.reduce((acc, poster) => {
            acc[poster.branchKey] = poster
            return acc
          }, {})
        }

        if (heroResult.status === 'rejected' || posterResult.status === 'rejected') {
          this.error = 'Không tải được một phần nội dung trang sản phẩm'
        }
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Không tải được nội dung trang sản phẩm'
      } finally {
        this.loading = false
      }
    },
  },
})
