# mengirim.id — Landing Page

Landing page production-ready untuk **mengirim.id**, platform omnichannel CRM untuk WhatsApp Business API, Instagram DM, dan Facebook Messenger. Dioperasikan oleh **PT Mengirim Digital Nusantara**.

Dibangun dengan **Astro + Tailwind CSS** — static, cepat, dan siap deploy.

## Stack

- **Framework:** Astro 4
- **Styling:** Tailwind CSS 3
- **Font:** Plus Jakarta Sans (via `@fontsource`)
- **Ikon:** Inline SVG (ringan, gak ada overhead library)
- **Integrasi:** `@astrojs/sitemap` untuk sitemap otomatis

## Quickstart

```bash
# 1. Install dependencies
npm install

# 2. Jalankan dev server
npm run dev
# → http://localhost:4321

# 3. Build untuk production
npm run build

# 4. Preview build lokal
npm run preview
```

## Struktur Folder

```
├── public/
│   ├── favicon.svg
│   ├── robots.txt
│   └── images/              ← taruh dashboard-mockup.webp, og-image.webp di sini
├── src/
│   ├── components/
│   │   ├── sections/        ← section-section landing page
│   │   ├── Navbar.astro
│   │   ├── Footer.astro
│   │   ├── Logo.astro
│   │   ├── Button.astro
│   │   ├── Section.astro
│   │   ├── FeatureCard.astro
│   │   └── BenefitCard.astro
│   ├── layouts/
│   │   ├── BaseLayout.astro
│   │   └── LegalLayout.astro
│   ├── pages/
│   │   ├── index.astro       ← landing page utama
│   │   ├── privacy-policy.astro
│   │   └── terms.astro
│   └── styles/
│       └── global.css
├── astro.config.mjs
├── tailwind.config.mjs
├── tsconfig.json
├── vercel.json
└── netlify.toml
```

## Environment Variables

Copy `.env.example` ke `.env` kalau butuh override:

```bash
cp .env.example .env
```

Variabel yang tersedia:

- `PUBLIC_SITE_URL` — canonical URL (default: `https://mengirim.id`)

## Asset yang Perlu Ditambahkan

Letakkan file berikut di `/public/images/`:

- `dashboard-mockup.webp` (rekomendasi 1920×1080, ≤200KB)
- `og-image.webp` (rekomendasi 1200×630, untuk social share)
- `logo.webp` (rekomendasi 512×512, untuk structured data)

Landing page punya fallback graceful kalau file belum ada — aman untuk dev.

## Deploy

### Vercel

1. Push repo ke GitHub/GitLab/Bitbucket.
2. Import project di [vercel.com/new](https://vercel.com/new).
3. Vercel akan auto-detect Astro dan pakai `vercel.json` yang sudah ada.
4. (Opsional) Set custom domain `mengirim.id` di dashboard Vercel.

Atau via CLI:

```bash
npm i -g vercel
vercel
```

### Netlify

1. Push repo ke GitHub/GitLab/Bitbucket.
2. Import project di [app.netlify.com/start](https://app.netlify.com/start).
3. Netlify akan pakai `netlify.toml` yang sudah ada.
4. (Opsional) Set custom domain `mengirim.id` di Site settings → Domain management.

Atau via CLI:

```bash
npm i -g netlify-cli
netlify deploy --prod
```

## SEO

- Meta title + description
- Open Graph + Twitter Card
- Canonical URL
- Sitemap otomatis (`/sitemap-index.xml`)
- `robots.txt`
- JSON-LD Organization dengan `legalName: "PT Mengirim Digital Nusantara"`
- `lang="id"`, `og:locale="id_ID"`

## Customization

- **Warna brand:** edit di `tailwind.config.mjs` (section `theme.extend.colors.brand`).
- **Gradient:** `bg-brand-gradient` — define di `tailwind.config.mjs` di section `backgroundImage`.
- **Font:** ganti di `src/styles/global.css` (import) dan `tailwind.config.mjs` (fontFamily).
- **Konten copy:** edit langsung di `src/components/sections/*.astro`.
- **Nav menu:** edit array `navItems` di `src/components/Navbar.astro`.

## Lighthouse Target

Konfigurasi sudah dioptimasi untuk Lighthouse ≥95 di semua kategori:

- Static HTML (Astro SSG)
- CSS inline untuk above-the-fold
- SVG icon (zero JS overhead)
- Font subset via `@fontsource`
- Responsive images dengan `loading="lazy"`
- Cache headers untuk assets

Untuk verifikasi:

```bash
npm run build && npm run preview
# lalu run Lighthouse di http://localhost:4321
```

## Kontak

- Website: [mengirim.id](https://mengirim.id)
- Support: [support@mengirim.id](mailto:support@mengirim.id)
- Dioperasikan oleh **PT Mengirim Digital Nusantara**
