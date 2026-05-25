import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import ProcessView from './ProcessView.vue'
import { useFranchiseContentStore } from '../../stores/franchiseContentStore'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => key,
  }),
}))

describe('ProcessView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('uses a consultation CTA that matches its destination', () => {
    const store = useFranchiseContentStore()
    vi.spyOn(store, 'fetchContent').mockResolvedValue()

    const wrapper = mount(ProcessView, {
      global: {
        stubs: {
          SectionTitle: {
            props: ['eyebrow', 'title', 'description'],
            template: '<section><h2>{{ title }}</h2><p>{{ description }}</p></section>',
          },
          FranchiseStep: { props: ['step'], template: '<article>{{ step.title }}</article>' },
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    const cta = wrapper.get('a[href="/consultation"]')
    expect(cta.text()).toContain('Đăng ký tư vấn mở cửa hàng')
  })
})