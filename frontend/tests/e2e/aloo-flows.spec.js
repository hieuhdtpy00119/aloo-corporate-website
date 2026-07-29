import { expect, test } from '@playwright/test'

const adminEmail = process.env.E2E_ADMIN_EMAIL || 'admin@aloo.vn'
const adminPassword = process.env.E2E_ADMIN_PASSWORD || '123456'

async function loginAdmin(page) {
  await page.goto('/login')
  await page.locator('input[type="email"]').fill(adminEmail)
  await page.locator('input[type="password"]').fill(adminPassword)
  await page.getByRole('button', { name: /xac thuc tai khoan|xác thực tài khoản/i }).click()
  await expect(page).toHaveURL(/\/admin/)
}

test.describe('ALOO critical user journeys', () => {
  test.describe.configure({ mode: 'serial' })

  test('admin logs in and performs product CRUD', async ({ page }) => {
    const suffix = Date.now()
    const name = `Kem bo E2E ${suffix}`
    const slug = `kem-bo-e2e-${suffix}`

    await loginAdmin(page)
    await page.goto('/admin/products')

    await page.getByRole('button', { name: /them san pham|thêm sản phẩm/i }).click()
    await page.getByLabel(/ten san pham|tên sản phẩm/i).fill(name)
    await page.getByLabel(/slug/i).fill(slug)
    await page.getByLabel(/danh muc|danh mục/i).fill('Thiên đường bơ ngon')
    await page.getByLabel(/gia ban|giá bán/i).fill('10000')
    await page.getByLabel(/^url anh|^url ảnh/i).fill('/logo-aloo.png')
    await page.getByRole('button', { name: /^noi dung$|^nội dung$/i }).click()
    await page.getByLabel(/mo ta danh sach|mô tả danh sách/i).fill('San pham tao tu Playwright')
    await page.getByRole('button', { name: /them san pham|thêm sản phẩm/i }).last().click()

    await page.getByRole('searchbox', { name: /tim san pham|tìm sản phẩm/i }).fill(name)
    const productRow = page.getByRole('row').filter({ hasText: name })
    await expect(productRow).toBeVisible()

    await productRow.getByRole('button', { name: /sua|sửa/i }).click()
    await page.getByRole('button', { name: /^noi dung$|^nội dung$/i }).click()
    await page.getByLabel(/mo ta danh sach|mô tả danh sách/i).fill('San pham da cap nhat tu Playwright')
    await page.getByRole('button', { name: /luu cap nhat|lưu cập nhật/i }).click()
    await expect(productRow).toBeVisible()

    await productRow.getByRole('button', { name: /xoa|xóa/i }).click()
    await page.getByRole('button', { name: /xoa san pham|xóa sản phẩm/i }).click()
    await expect(productRow).toHaveCount(0)
  })

  test('public franchise form creates a lead visible in admin', async ({ page }) => {
    const suffix = Date.now()
    const fullName = `Lead E2E ${suffix}`
    const phone = `090${String(suffix).slice(-7)}`

    await page.goto('/consultation')
    const form = page.locator('form').first()
    const inputs = form.locator('input')
    await inputs.nth(0).fill(fullName)
    await inputs.nth(1).fill(phone)
    await inputs.nth(2).fill(`lead${suffix}@example.com`)
    await inputs.nth(3).fill('TP.HCM')
    await inputs.nth(4).fill('300000000')
    await form.locator('textarea').fill('Lead tao tu Playwright')
    await form.getByRole('button').click()

    await loginAdmin(page)
    await page.goto('/admin/registrations')
    await page.getByPlaceholder(/tim ho ten|tìm họ tên/i).fill(fullName)
    await expect(page.getByRole('table').getByText(fullName, { exact: true })).toBeVisible()
  })
})
