import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import ContactView from './ContactView.vue'
import { contactMessageService } from '../../services/cmsService'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => key,
  }),
}))

vi.mock('../../services/cmsService', () => ({
  contactMessageService: { create: vi.fn() },
}))

describe('ContactView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    contactMessageService.create.mockReset()
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

  it('submits contact data through the contact message endpoint', async () => {
    contactMessageService.create.mockResolvedValue({
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

    expect(contactMessageService.create).toHaveBeenCalledWith({
      fullName: 'Nguyen Van A',
      phone: '0900123456',
      email: 'lead@example.com',
      subject: 'TP.HCM',
      message: 'Can tu van mo cua hang',
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
    expect(contactMessageService.create).not.toHaveBeenCalled()
  })
})


