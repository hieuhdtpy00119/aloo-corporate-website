import { mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import ProcessView from './ProcessView.vue'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => key,
    tm: (key) =>
      key === 'franchise.steps'
        ? [{ id: 1, title: 'Tu van', description: 'Khao sat mat bang' }]
        : [],
  }),
}))

describe('ProcessView', () => {
  it('uses a consultation CTA that matches its destination', () => {
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
