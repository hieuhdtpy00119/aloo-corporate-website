# ALOO Corporate Website

Frontend website and admin CMS demo for **ALOO - Kem Bơ Thuần Việt**.

## Tech Stack

- Vue 3
- Vite
- Vue Router
- Pinia
- Tailwind CSS
- Axios

## Requirements

- Node.js 18+ recommended
- npm
- Git

## Download Project

Clone repository:

```bash
git clone https://github.com/hieuhdtpy00119/aloo-corporate-website.git
cd aloo-corporate-website
```

## Install Dependencies

```bash
npm install
```

## Environment Setup

Create `.env` from the example file if needed:

```bash
cp .env.example .env
```

Default example:

```env
VITE_API_URL=http://localhost:3000/api
```

This project currently uses mock data, so backend setup is not required.

## Run Development Server

```bash
npm run dev
```

Open:

```text
http://localhost:5173/
```

## Build Production

```bash
npm run build
```

## Preview Production Build

```bash
npm run preview
```

## Admin Demo

Admin login route:

```text
http://localhost:5173/admin/login
```

Demo account:

```text
Email: admin@aloo.vn
Password: 123456
```

## Main Routes

Public:

- `/`
- `/products`
- `/locations`
- `/franchise`
- `/about`
- `/blog`
- `/consultation`

Admin:

- `/admin`
- `/admin/products`
- `/admin/banners`
- `/admin/posts`
- `/admin/registrations`
- `/admin/locations`
- `/admin/franchise-content`

## Notes

- `node_modules/`, `dist/`, and `.env` are ignored by Git.
- Do not commit real API keys or secrets.
- Vite variables starting with `VITE_` are exposed to browser code, so secret keys should be stored in a backend service.
