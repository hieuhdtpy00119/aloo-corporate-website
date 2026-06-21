export const decodeBase64JsonUtf8 = (payload) => {
  if (!payload) return null

  try {
    const normalized = payload.replace(/-/g, '+').replace(/_/g, '/')
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')
    const binary = atob(padded)
    const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0))
    const json = new TextDecoder('utf-8').decode(bytes)
    return JSON.parse(json)
  } catch {
    return null
  }
}

export const repairUtf8Mojibake = (value) => {
  if (!value || typeof value !== 'string') {
    return value
  }

  try {
    const bytes = Uint8Array.from(value, (char) => char.charCodeAt(0) & 0xff)
    const repaired = new TextDecoder('utf-8', { fatal: true }).decode(bytes)

    if (repaired && repaired !== value && !repaired.includes('\uFFFD')) {
      return repaired
    }
  } catch {
    return value
  }

  return value
}
