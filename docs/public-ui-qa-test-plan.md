# Public UI QA Test Plan

## Screen Checklist

| Screen | UI checks | Logic/API checks |
| --- | --- | --- |
| `PublicLayout` | Header, route body and footer stay visible after navigation | Active nav state follows current route |
| `/` | Hero image, featured cards, product rail, brand story, location section, CTA links | CTA goes to `/products`, `/franchise`, `/consultation`, `/locations` |
| `/about` | Brand story cards and content are distinct from blog | Static content should not depend on API |
| `/products` | Hero slider, menu poster, product grid, empty/loading/error states | Calls product API through `store.fetchProducts`; hidden products are not shown |
| `/franchise` | Hero, benefits, conditions, process, costs, CTA | Uses `franchiseContentStore.fetchContent`; has loading/error states |
| `/process` | 6-step process cards render from locale data | CTA copy matches `/consultation` destination |
| `/cost` | Cost cards render in 3-column grid desktop and stack mobile | CTA goes to `/consultation` |
| `/locations` | Search/filter bar, location cards, map links | Calls `store.fetchLocations`; search filters by name/address; closed branches hidden |
| `/blog` | Lead post, editor picks, category chips, latest sidebar, empty/loading/error states | Calls categories/posts API; only published posts shown |
| `/blog/:id` | Detail hero, article body, TOC, related posts, CTA, not-found state | Supports id or slug; updates `document.title` from article SEO/title |
| `/consultation` | Form fields and submit disabled state | Client required/email/phone pattern; payload maps to backend DTO; success/error toast |
| `/contact` | Contact cards, hotline/email/address, contact form, CTA | Client required/email/phone pattern; submits to franchise registration endpoint as a contact lead |
| `/login` | Demo account text, validation errors, loading state | User login redirects `/profile`; admin email redirects `/admin`; logged-in user cannot stay on `/login` |
| `/profile` | Avatar, account summary, editable form | Protected route; loads `/user-auth/me`; saves `/user-auth/profile` |
| `/change-password` | Current/new/confirm fields and validation | Protected route; min 8 chars; success clears token and returns to `/login` |
| `404` | Clear not-found message and home button | Random route shows 404 |

## Flow Checklist

- Guest funnel: `/` -> `/franchise` -> `/cost` -> `/consultation` -> submit success.
- Contact lead: `/contact` validates phone/email and submits a contact lead successfully.
- User account: `/login` -> `/profile` -> update profile -> `/change-password` -> logout to `/login`.
- Route protection: unauthenticated `/profile` and `/change-password` redirect to `/login`; authenticated `/login` redirects away.
- Expired JWT: `401` from user API clears `user_token` and redirects to `/login`.
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
