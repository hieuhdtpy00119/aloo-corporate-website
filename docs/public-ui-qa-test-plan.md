# Public UI QA Test Plan

## Screen Checklist

| Screen | UI checks | Logic/API checks |
| --- | --- | --- |
| `PublicLayout` | Header, route body and footer stay visible after navigation | Active nav state follows current route |
| `/` | Hero image, featured cards, product rail, brand story, location section, CTA links | CTA goes to `/products`, `/franchise`, `/consultation`, `/locations` |
| `/about` | Brand story + CMS timeline milestones | Loads `brandTimelineService.list(true)`; falls back to locale defaults |
| `/products` | Hero slider, product grid, empty/loading/error states | Calls product API; inactive products hidden for anonymous |
| `/franchise` | Hero, benefits, conditions, process, costs, CTA | Uses franchise content CMS; has loading/error states |
| `/locations` | Search/filter bar, location cards, map links | Calls locations API; search filters by name/address |
| `/locations/:slug` | Store hero, amenities, gallery, **menu posters**, map/phone CTAs | Uses store slug API; posters from `menuPosters` / `menuPostersJson` |
| `/blog` | Lead post, editor picks, category chips, latest sidebar | Only published posts shown |
| `/blog/:slug` | Detail hero, article body (sanitized HTML), TOC, related posts | Supports slug; SEO title from article |
| `/consultation` | Form fields and submit disabled state | Payload maps to franchise registration DTO |
| `/contact` | Contact cards + form | Submits to `/api/contact-messages` (not franchise registrations) |
| `/login` | Validation errors, loading state | USER → `/account`; ADMIN → `/admin` |
| `/account` | Profile/security tabs (shared with admin profile) | Protected; uses `/api/auth/me` and `/api/auth/profile` |
| `404` | Clear not-found message and home button | Random route shows 404 |

## Flow Checklist

- Guest funnel: `/` -> `/franchise` -> `/consultation` -> submit success.
- Contact message: `/contact` validates and submits to `/api/contact-messages`.
- User account: `/login` -> `/account` -> update profile / security tab.
- Route protection: unauthenticated `/account` redirects to `/login`; authenticated `/login` redirects away.
- Expired JWT: `401` from auth API clears `admin_token` and redirects to `/login`.
- Blog navigation: list -> detail -> browser back -> list; missing slug shows clear error.

## Implemented Test Code

Vitest:

- `src/layouts/PublicLayout.spec.js`
- `src/components/public/Navbar.spec.js`
- `src/views/public/ProductsView.spec.js`
- `src/views/public/LocationsView.spec.js`
- `src/views/public/BlogView.spec.js`
- `src/views/public/BlogDetailView.spec.js`
- `src/views/public/ContactView.spec.js`
- `src/views/public/ProcessView.spec.js`
- `src/views/public/UserLoginView.spec.js`
- `src/views/public/UserProfileView.spec.js`
- `src/views/public/UserChangePasswordView.spec.js`
- Existing: `ConsultationForm.spec.js`, `api.spec.js`, `router/index.spec.js`

Playwright:

- `tests/e2e/public-user-flows.spec.js`
- Existing admin smoke: `tests/e2e/aloo-flows.spec.js`

## Commands

```bash
cd frontend
npm run test
npm run build
npx playwright test --list
```

Run E2E UI flows with mocked APIs:

```bash
cd frontend
npx playwright test tests/e2e/public-user-flows.spec.js
```

Run full E2E against real backend:

```bash
cd backend
mvn spring-boot:run

cd frontend
npm run e2e
```

## Common Vue 3 + JWT Risks

- Route guard only checks token existence; expired tokens are detected after API call by Axios interceptor.
- Public pages that depend on API need explicit empty/error states, otherwise failures look like blank pages.
- Browser-native validation is not enough for consistent tests; critical fields should still be validated in component logic or backend.
- Changing password in real E2E can mutate shared test data. Prefer mocked API for UI flow, or reset the password after test.
- Blog pages need deterministic slug/id handling; do not assume numeric id only.
