import { describe, expect, it } from 'vitest'
import { decodeBase64JsonUtf8, repairUtf8Mojibake } from './textEncoding'

describe('textEncoding', () => {
  it('decodes base64 JSON with Vietnamese characters', () => {
    const payload = btoa(unescape(encodeURIComponent('{"fullName":"Hiếu Huỳnh Đoàn Tr"}')))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '')

    expect(decodeBase64JsonUtf8(payload)).toEqual({ fullName: 'Hiếu Huỳnh Đoàn Tr' })
  })

  it('repairs UTF-8 mojibake from latin1 misread', () => {
    const original = 'Hiếu Huỳnh Đoàn Tr'
    const broken = String.fromCharCode(...new TextEncoder().encode(original))
    expect(repairUtf8Mojibake(broken)).toBe(original)
  })
})
