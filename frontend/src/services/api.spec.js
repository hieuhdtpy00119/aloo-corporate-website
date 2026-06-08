import { describe, expect, it, beforeEach, vi } from 'vitest'

const axiosMock = vi.hoisted(() => ({
  create: vi.fn(),
  handlers: {},
}))

vi.mock('axios', () => ({
  default: {
    create: axiosMock.create,
  },
}))

const loadApi = async () => {
  vi.resetModules()
  axiosMock.handlers = {}
  const instance = {
    defaults: {
      baseURL: 'http://localhost:8080/api',
    },
    interceptors: {
      request: {
        use: vi.fn((handler) => {
          axiosMock.handlers.request = handler
        }),
      },
      response: {
        use: vi.fn((successHandler, errorHandler) => {
          axiosMock.handlers.responseSuccess = successHandler
          axiosMock.handlers.responseError = errorHandler
        }),
      },
    },
  }
  axiosMock.create.mockReturnValue(instance)

  const module = await import('./api')
  return { api: module.default, instance }
}

describe('api axios instance', () => {
  beforeEach(() => {
    localStorage.clear()
    axiosMock.create.mockReset()
  })

  it('uses VITE_API_URL fallback and attaches admin JWT for CMS requests', async () => {
    const { instance } = await loadApi()
    localStorage.setItem('admin_token', 'admin.jwt.token')

    const config = axiosMock.handlers.request({
      url: '/products',
      headers: {},
    })

    expect(instance.defaults.baseURL).toBe('http://localhost:8080/api')
    expect(config.headers.Authorization).toBe('Bearer admin.jwt.token')
  })

  it('uses admin JWT for testimonial requests', async () => {
    await loadApi()
    localStorage.setItem('admin_token', 'admin.jwt.token')

    const config = axiosMock.handlers.request({
      url: '/admin/testimonials',
      headers: {},
    })

    expect(config.headers.Authorization).toBe('Bearer admin.jwt.token')
  })

  it('does not overwrite an explicit Authorization header', async () => {
    await loadApi()
    localStorage.setItem('admin_token', 'admin.jwt.token')

    const config = axiosMock.handlers.request({
      url: '/products',
      headers: {
        Authorization: 'Bearer explicit.token',
      },
    })

    expect(config.headers.Authorization).toBe('Bearer explicit.token')
  })

  it('clears stored admin token on 401 responses', async () => {
    await loadApi()
    window.history.pushState({}, '', '/')
    const authEvent = vi.fn()
    window.addEventListener('aloo-auth-change', authEvent)
    localStorage.setItem('admin_token', 'expired.jwt.token')
    localStorage.setItem('admin_user', '{"email":"admin@aloo.vn"}')

    const error = {
      response: { status: 401 },
      config: { url: '/products' },
    }

    await expect(axiosMock.handlers.responseError(error)).rejects.toBe(error)

    expect(localStorage.getItem('admin_token')).toBeNull()
    expect(localStorage.getItem('admin_user')).toBeNull()
    expect(authEvent).toHaveBeenCalledTimes(1)
    window.removeEventListener('aloo-auth-change', authEvent)
  })
})
