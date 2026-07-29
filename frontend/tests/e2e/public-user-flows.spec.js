import { expect, test } from '@playwright/test'

const userJwt = 'eyJhbGciOiJub25lIn0.eyJyb2xlIjoiVVNFUiIsImV4cCI6NDEwMjQ0NDgwMH0.e2e'

const user = {
  id: 10,
  email: 'user@aloo.vn',
  fullName: 'ALOO User',
  phone: '0901234567',
  avatarUrl: '/logo-aloo.png',
  role: 'USER',
  status: 'ACTIVE',
  authProvider: 'LOCAL',
  passwordSetAt: '2026-05-22T10:00:00',
  hasPasswordLogin: true,
  passwordChangeRequiresOtp: false,
}

const publishedPosts = [
  {
    id: 1,
    title: 'Câu chuyện ALOO E2E',
    slug: 'cau-chuyen-aloo-e2e',
    excerpt: 'Bài viết test điều hướng blog.',
    content: '<h2>Điểm chính</h2><p>Nội dung chi tiết ALOO.</p>',
    category: 'Nhượng quyền',
    status: 'PUBLISHED',
    publishedAt: '2026-05-22T10:00:00',
    tags: ['aloo'],
  },
]

async function mockPublicApis(page) {
  await page.route('**/api/categories', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        { id: 1, name: 'Nhượng quyền', type: 'ARTICLE', status: 'ACTIVE', sortOrder: 1 },
      ]),
    })
  })

  await page.route('**/api/posts', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(publishedPosts),
    })
  })

  await page.route('**/api/franchise-registrations', async (route) => {
    if (route.request().method() !== 'POST') return route.continue()
    await route.fulfill({
      status: 201,
      contentType: 'application/json',
      body: JSON.stringify({
        id: Date.now(),
        fullName: 'Lead Public E2E',
        phone: '0900123456',
        email: 'lead@example.com',
        province: 'TP.HCM',
        expectedBudget: 300000000,
        note: 'Can tu van',
        status: 'NEW',
        createdAt: '2026-05-22T10:00:00',
      }),
    })
  })

  await page.route('**/api/contact-messages', async (route) => {
    if (route.request().method() !== 'POST') return route.continue()
    await route.fulfill({
      status: 201,
      contentType: 'application/json',
      body: JSON.stringify({ id: Date.now(), status: 'NEW' }),
    })
  })
}

async function mockUserApis(page, options = {}) {
  await page.route('**/api/auth/login', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        token: userJwt,
        tokenType: 'Bearer',
        user,
      }),
    })
  })

  await page.route('**/api/auth/me', async (route) => {
    if (options.expiredToken) {
      await route.fulfill({
        status: 401,
        contentType: 'application/json',
        body: JSON.stringify({ message: 'Invalid user token' }),
      })
      return
    }

    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(user),
    })
  })

  await page.route('**/api/auth/profile', async (route) => {
    const payload = await route.request().postDataJSON()
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        ...user,
        ...payload,
      }),
    })
  })

  await page.route('**/api/auth/change-password', async (route) => {
    await route.fulfill({
      status: 204,
    })
  })

  await page.route('**/api/chat/sessions/account', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        id: 1,
        sessionToken: 'e2e-account-chat',
        status: 'OPEN',
        messages: [],
      }),
    })
  })
}

async function loginUser(page) {
  await page.goto('/login', { waitUntil: 'domcontentloaded' })
  await page.locator('input[type="email"]').fill('user@aloo.vn')
  await page.locator('input[type="password"]').fill('123456')
  await page.getByRole('button', { name: /xác thực tài khoản/i }).click()
  await expect(page).toHaveURL(/\/account/)
}

test.describe('ALOO public UI and user flows', () => {
  test.beforeEach(async ({ page }) => {
    await mockPublicApis(page)
  })

  test('guest navigates franchise funnel and submits consultation form', async ({ page }) => {
    await page.goto('/', { waitUntil: 'domcontentloaded' })
    await expect(page.getByRole('link', { name: /đăng ký tư vấn miễn phí/i })).toBeVisible()

    await page.goto('/franchise', { waitUntil: 'domcontentloaded' })
    await expect(page.getByRole('heading', { name: /nhượng quyền/i }).first()).toBeVisible()

    await page.goto('/cost', { waitUntil: 'domcontentloaded' })
    await expect(page).toHaveURL(/\/franchise#investment/)
    await expect(page.getByRole('heading', { name: /bảng chi phí tham khảo chi tiết/i })).toBeVisible()

    await page.goto('/consultation', { waitUntil: 'domcontentloaded' })
    const form = page.locator('form').first()
    const inputs = form.locator('input')
    await inputs.nth(0).fill('Lead Public E2E')
    await inputs.nth(1).fill('0900123456')
    await inputs.nth(2).fill('lead@example.com')
    await inputs.nth(3).fill('TP.HCM')
    await inputs.nth(4).fill('300000000')
    await form.locator('textarea').fill('Can tu van')
    await form.getByRole('button').click()

    await expect(page.getByText(/cảm ơn bạn đã quan tâm tới aloo/i)).toBeVisible()
  })

  test('contact form validates and submits a contact lead', async ({ page }) => {
    await page.goto('/contact', { waitUntil: 'domcontentloaded' })
    const form = page.getByTestId('contact-form')
    const inputs = form.locator('input')

    await inputs.nth(0).fill('Lead Contact E2E')
    await inputs.nth(1).fill('abc')
    await form.locator('textarea').fill('Can lien he')
    await form.getByRole('button', { name: /gửi liên hệ/i }).click()
    await expect(page.getByText(/số điện thoại không đúng định dạng/i)).toBeVisible()

    await inputs.nth(1).fill('0900111222')
    await inputs.nth(2).fill('contact@example.com')
    await inputs.nth(3).fill('Đà Nẵng')
    await form.locator('textarea').fill('Can duoc tu van hop tac')
    await form.getByRole('button', { name: /gửi liên hệ/i }).click()

    await expect(page.getByText(/đã gửi liên hệ thành công/i)).toBeVisible()
  })

  test('user login, profile update and password change flow', async ({ page }) => {
    await mockUserApis(page)

    await loginUser(page)
    await expect(page.getByRole('heading', { name: /thông tin cá nhân/i })).toBeVisible()

    await page.getByLabel(/họ tên/i).fill('ALOO User Updated')
    await page.getByRole('button', { name: /cập nhật thông tin/i }).click()
    await expect(page.getByText(/cập nhật thông tin thành công/i)).toBeVisible()

    await page.getByRole('button', { name: /^bảo mật$/i }).click()
    await page.locator('input[autocomplete="current-password"]').fill('123456')
    await page.locator('input[autocomplete="new-password"]').first().fill('StrongPass1!')
    await page.locator('input[autocomplete="new-password"]').last().fill('StrongPass1!')
    await page.getByRole('button', { name: /đổi mật khẩu/i }).click()

    await expect(page).toHaveURL(/\/account\?tab=security/)
    await expect(page.getByText(/đổi mật khẩu thành công/i)).toBeVisible()
    await expect(page.evaluate(() => localStorage.getItem('admin_token'))).resolves.toBe(userJwt)
  })

  test('protected user routes redirect to login and login redirects authenticated user away', async ({ page }) => {
    await page.goto('/account', { waitUntil: 'domcontentloaded' })
    await expect(page).toHaveURL(/\/login/)

    await mockUserApis(page)
    await page.addInitScript(() => {
      localStorage.setItem('admin_token', 'eyJhbGciOiJub25lIn0.eyJyb2xlIjoiVVNFUiIsImV4cCI6NDEwMjQ0NDgwMH0.e2e')
      localStorage.setItem('admin_user', JSON.stringify({ role: 'USER', email: 'user@aloo.vn' }))
    })
    await page.goto('/login', { waitUntil: 'domcontentloaded' })
    await expect(page).toHaveURL(/\/account/)
  })

  test('expired user JWT clears token and redirects to login', async ({ page }) => {
    await mockUserApis(page, { expiredToken: true })
    await page.goto('/', { waitUntil: 'domcontentloaded' })
    await page.evaluate(() => {
      localStorage.setItem('admin_token', 'eyJhbGciOiJub25lIn0.eyJyb2xlIjoiVVNFUiIsImV4cCI6NDEwMjQ0NDgwMH0.e2e')
      localStorage.setItem('admin_user', '{"role":"USER","email":"user@aloo.vn"}')
    })

    await page.goto('/account', { waitUntil: 'domcontentloaded' })

    await expect(page).toHaveURL(/\/login/)
    await expect(page.evaluate(() => localStorage.getItem('admin_token'))).resolves.toBeNull()
  })

  test('blog navigation opens detail, browser back returns to list, missing slug is clear', async ({ page }) => {
    await page.goto('/blog', { waitUntil: 'domcontentloaded' })
    await expect(page.getByText('Câu chuyện ALOO E2E').first()).toBeVisible()

    await page.locator('a[href="/blog/cau-chuyen-aloo-e2e"]').first().click({ noWaitAfter: true })
    await expect(page).toHaveURL(/\/blog\/cau-chuyen-aloo-e2e/)
    await expect(page.getByRole('heading', { name: /câu chuyện aloo e2e/i })).toBeVisible()

    await page.getByRole('link', { name: /blog/i }).first().click({ noWaitAfter: true })
    await expect(page).toHaveURL(/\/blog$/)

    await page.goto('/blog/khong-ton-tai', { waitUntil: 'domcontentloaded' })
    await expect(page.getByText(/không tìm thấy bài viết/i)).toBeVisible()
  })
})
