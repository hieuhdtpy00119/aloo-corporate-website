import { defineStore } from 'pinia'
import { franchiseContentService } from '../services/cmsService'

const sectionKeys = ['benefits', 'conditions', 'process', 'costs']
const emptyContent = () =>
  sectionKeys.reduce((acc, key) => {
    acc[key] = []
    return acc
  }, {})

const isVisible = (item) => !['HIDDEN', 'INACTIVE'].includes(item.status)

const normalizeItem = (item) => {
  const content = item.content || ''
  const [amount, ...noteParts] = content.split('|||')
  const isCost = item.sectionKey === 'costs'

  return {
    id: item.id,
    sectionKey: item.sectionKey,
    title: item.title || '',
    description: isCost ? '' : content,
    amount: isCost ? item.amount || amount || '' : '',
    note: isCost ? item.note || noteParts.join('|||') || '' : '',
    sortOrder: Number(item.sortOrder || item.id || 0),
    status: item.status || 'ACTIVE',
  }
}

const buildPayload = (sectionKey, item, index) => ({
  sectionKey,
  title: item.title?.trim(),
  content: sectionKey === 'costs' ? null : item.description || item.content || '',
  amount: sectionKey === 'costs' ? item.amount || '' : null,
  note: sectionKey === 'costs' ? item.note || '' : null,
  sortOrder: Number(item.sortOrder ?? index),
  status: item.status || 'ACTIVE',
})

export const useFranchiseContentStore = defineStore('franchiseContent', {
  state: () => ({
    content: emptyContent(),
    loading: false,
    error: '',
  }),
  getters: {
    visibleBenefits: (state) => state.content.benefits.filter(isVisible),
    visibleConditions: (state) => state.content.conditions.filter(isVisible),
    visibleProcess: (state) => state.content.process.filter(isVisible),
    visibleCosts: (state) => state.content.costs.filter(isVisible),
  },
  actions: {
    async fetchContent() {
      this.loading = true
      this.error = ''
      try {
        const { data } = await franchiseContentService.list()
        const grouped = emptyContent()
        data.map(normalizeItem).forEach((item) => {
          if (!grouped[item.sectionKey]) grouped[item.sectionKey] = []
          grouped[item.sectionKey].push(item)
        })
        Object.keys(grouped).forEach((key) => {
          grouped[key].sort((a, b) => a.sortOrder - b.sortOrder)
        })
        this.content = grouped
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Không tải được nội dung nhượng quyền'
        throw error
      } finally {
        this.loading = false
      }
    },
    async updateSection(sectionKey, items) {
      const updatedItems = []
      for (const [index, item] of items.entries()) {
        if (!item.id) continue
        const { data } = await franchiseContentService.update(item.id, buildPayload(sectionKey, item, index))
        updatedItems.push(normalizeItem(data))
      }
      this.content[sectionKey] = updatedItems.sort((a, b) => a.sortOrder - b.sortOrder)
    },
  },
})
