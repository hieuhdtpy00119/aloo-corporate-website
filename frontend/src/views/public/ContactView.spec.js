import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import ContactView from './ContactView.vue'
import { createFranchiseRegistration } from '../../services/franchiseRegistrationService'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => key,
  }),
}))

vi.mock('../../services/franchiseRegistrationService', () => ({
  createFranchiseRegistration: vi.fn(),
}))

describe('ContactView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    createFranchiseRegistration.mockReset()
  })

  const mountView = () =>
    mount(ContactView, {
      global: {
        plugins: [createPinia()],
        stubs: {
          SectionTitle: {
            props: ['eyebrow', 'title', 'description'],
            template: '<section><h2>{{ title }}</h2><p>{{ description }}</p></section>',
          },
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

  it('submits contact data through the franchise registration endpoint', async () => {
    createFranchiseRegistration.mockResolvedValue({
      data: {
        id: 10,
        status: 'NEW',
      },
    })

    const wrapper = mountView()
    const form = wrapper.get('[data-testid="contact-form"]')
    const inputs = form.findAll('input')

    await inputs[0].setValue('Nguyen Van A')
    await inputs[1].setValue('0900123456')
    await inputs[2].setValue('lead@example.com')
    await inputs[3].setValue('TP.HCM')
    await form.find('textarea').setValue('Can tu van mo cua hang')
    await form.trigger('submit')
    await flushPromises()

    expect(createFranchiseRegistration).toHaveBeenCalledWith({
      fullName: 'Nguyen Van A',
      phone: '0900123456',
      email: 'lead@example.com',
      province: 'TP.HCM',
      expectedBudget: 0,
      note: '[Lien he website] Can tu van mo cua hang',
    })
    expect(inputs[0].element.value).toBe('')
  })

  it('validates required fields and phone format before submitting', async () => {
    const wrapper = mountView()
    const form = wrapper.get('[data-testid="contact-form"]')
    const inputs = form.findAll('input')

    await inputs[0].setValue('Nguyen Van A')
    await inputs[1].setValue('abc')
    await form.find('textarea').setValue('Can tu van')
    await form.trigger('submit')

    expect(wrapper.text()).toContain('Số điện thoại không đúng định dạng')
    expect(createFranchiseRegistration).not.toHaveBeenCalled()
  })
})
