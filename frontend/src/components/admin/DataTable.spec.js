import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import DataTable from './DataTable.vue'

describe('DataTable', () => {
  it('renders data rows, status badge and one-line table cells', () => {
    const wrapper = mount(DataTable, {
      props: {
        columns: [
          { key: 'name', label: 'Ten' },
          { key: 'status', label: 'Trang thai' },
        ],
        rows: [
          {
            id: 1,
            name: 'ALOO Nguyen Trai',
            status: 'Dang hien thi',
          },
        ],
        actions: true,
      },
    })

    expect(wrapper.text()).toContain('ALOO Nguyen Trai')
    expect(wrapper.text()).toContain('Dang hien thi')
    expect(wrapper.find('td').classes()).toContain('whitespace-nowrap')
    expect(wrapper.findAll('tbody tr')).toHaveLength(1)
  })
})
