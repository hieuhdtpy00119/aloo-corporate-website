import { describe, expect, it } from 'vitest'
import { matchesRegistrationSearch } from './registrationSearch'

describe('matchesRegistrationSearch', () => {
  it('handles nullable optional lead fields without throwing', () => {
    const registration = {
      name: 'Nguyễn Văn A',
      phone: '0901234567',
      email: null,
      area: null,
    }

    expect(matchesRegistrationSearch(registration, 'không khớp')).toBe(false)
    expect(matchesRegistrationSearch(registration, '0901')).toBe(true)
  })

  it('treats an empty keyword as a match', () => {
    expect(matchesRegistrationSearch({}, '  ')).toBe(true)
  })
})
