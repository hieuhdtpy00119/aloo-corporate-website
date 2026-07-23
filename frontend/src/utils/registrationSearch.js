const searchableValue = (value) => String(value || '').toLowerCase()

export const matchesRegistrationSearch = (registration, keyword) => {
  const normalizedKeyword = String(keyword || '').trim().toLowerCase()
  if (!normalizedKeyword) return true

  return [registration?.name, registration?.phone, registration?.email, registration?.area]
    .some((value) => searchableValue(value).includes(normalizedKeyword))
}
