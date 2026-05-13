import { defineStore } from 'pinia'
import { banners, locations, posts, products, registrations } from '../data/mockData'

export const useAppStore = defineStore('app', {
  state: () => ({
    products,
    registrations,
    banners,
    posts,
    locations,
  }),
  getters: {
    totalProducts: (state) => state.products.length,
    totalRegistrations: (state) => state.registrations.length,
    newRegistrations: (state) => state.registrations.filter((item) => item.status === 'Mới').length,
    contactedRegistrations: (state) =>
      state.registrations.filter((item) => item.status === 'Đã liên hệ').length,
  },
})
