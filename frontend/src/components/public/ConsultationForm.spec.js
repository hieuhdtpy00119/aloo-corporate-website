import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import ConsultationForm from './ConsultationForm.vue'
import { createFranchiseRegistration } from '../../services/franchiseRegistrationService'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => key,
  }),
}))

vi.mock('../../services/franchiseRegistrationService', () => ({
  createFranchiseRegistration: vi.fn(),
}))

describe('ConsultationForm', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    createFranchiseRegistration.mockReset()
  })

  it('maps public form fields to backend franchise registration DTO', async () => {
    createFranchiseRegistration.mockResolvedValue({
      data: {
        id: 1,
        fullName: 'Nguyen Van A',
        phone: '0900123456',
        email: 'lead@example.com',
        province: 'TP.HCM',
        expectedBudget: 300000000,
        note: 'Can tu van',
        status: 'NEW',
        createdAt: '2026-05-22T10:00:00',
      },
    })

    const wrapper = mount(ConsultationForm, {
      global: {
        plugins: [createPinia()],
      },
    })

    const inputs = wrapper.findAll('input')
    await inputs[0].setValue('Nguyen Van A')
    await inputs[1].setValue('0900123456')
    await inputs[2].setValue('lead@example.com')
    await inputs[3].setValue('TP.HCM')
    await inputs[4].setValue('300,000,000')
    await wrapper.find('textarea').setValue('Can tu van')

    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(createFranchiseRegistration).toHaveBeenCalledWith({
      fullName: 'Nguyen Van A',
      phone: '0900123456',
      email: 'lead@example.com',
      province: 'TP.HCM',
      expectedBudget: 300000000,
      note: 'Can tu van',
    })
    expect(inputs[0].element.value).toBe('')
  })

  it('shows an error toast path when backend rejects the lead', async () => {
    createFranchiseRegistration.mockRejectedValue({
      response: {
        data: {
          message: 'Phone is invalid',
        },
      },
    })

    const wrapper = mount(ConsultationForm, {
      global: {
        plugins: [createPinia()],
      },
    })

    const inputs = wrapper.findAll('input')
    await inputs[0].setValue('Nguyen Van A')
    await inputs[1].setValue('abc')
    await inputs[3].setValue('TP.HCM')
    await inputs[4].setValue('300000000')

    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(createFranchiseRegistration).toHaveBeenCalledTimes(1)
    expect(wrapper.text()).not.toContain('Dang gui')
  })
})
