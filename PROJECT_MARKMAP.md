---
markmap:
  colorFreezeLevel: 2
  maxWidth: 500
  initialExpandLevel: 2
---

# PMTL_VN — Pháp Môn Tâm Linh

## TỔNG QUAN

- **Tên:** Pháp Môn Tâm Linh (`phapmontamlinh.vn`)
- **Mục tiêu:** Cổng thông tin (Portal) Phật pháp — Niệm kinh, Blog (Khai Thị), Cộng đồng, Lịch âm
- **FE:** Next.js 14.2.35 (App Router) + Tailwind CSS + shadcn/ui
- **BE:** Strapi v5.38.0 (Document Service API, Draft & Publish)
- **DB:** SQLite `better-sqlite3` (dev) / PostgreSQL `pg` (prod) — hỗ trợ cả MySQL
- **Search:** Meilisearch (full-text search bài viết)
- **Cache:** Redis ISR optional (production scale, `@neshca/cache-handler`)
- **Auth:** Strapi Users-Permissions + Google OAuth 2.0 + httpOnly cookie
- **Email:** `@strapi/provider-email-nodemailer` (SMTP Gmail)
- **Media:** Local uploads (dev) / Cloudflare R2 hoặc AWS S3 (prod)
- **Analytics:** PostHog (lazy-load, opt-in)
- **PWA:** manifest.json + Service Worker + push notifications
- **Domain prod:** `phapmontamlinh.vn` (FE) / `api.phapmontamlinh.vn` (BE port 1337)
- **Timezone:** Asia/Bangkok (UTC+7) cho tất cả tính toán ngày

---

## FRONTEND (fe-pmtl)

### Stack & Phiên bản

- Next.js 14.2.35 — App Router, TypeScript strict
- Tailwind CSS 3.4.x + CSS Variables (design tokens)
- shadcn/ui (full component library — Radix UI primitives, 50+ components)
- Framer Motion 12.x (animation)
- react-hook-form 7.x + zod 4.x (forms + validation)
- @tanstack/react-query 5.x (client data fetching)
- embla-carousel-react 8.x (carousel)
- lucide-react 0.575 (icons)
- sonner 2.x (toast notifications)
- recharts 3.x (biểu đồ — dùng cho profile/stats)
- date-fns 4.x (xử lý ngày)
- qs 6.x (stringify query params cho strapiFetch)
- `@forvn/vn-lunar-calendar` 0.0.2 (tính âm lịch server-side)
- `@meilisearch/instant-meilisearch` + `meilisearch` (search client)
- posthog-js 1.x (analytics — lazy-load)
- next-themes 0.4.x (dark/light mode)
- vaul 1.x (Drawer mobile)
- `lenis` + `lenis/react` 1.3.x (smooth scroll)
- Playfair Display (`font-display`) + Be Vietnam Pro (`font-body`)

### Cấu trúc thư mục FE

- `app/` — Trang App Router + Route Handlers
- `components/` — Components dùng chung
  - `ui/` — shadcn/ui primitives (50+ components)
  - `blog/` — `SeriesNav.tsx`
  - `comments/` — `CommentForm`, `CommentItem`, `CommentsClient`, `CommentsSection`
  - `guestbook/` — `GuestbookForm`, `GuestbookList`
  - `hub/` — `HubLinkCard`, `HubPageComponent`, `HubSection`
  - `archive/` — `ArchiveGrid`, `ArchivePostList`
  - `icons/` — Custom SVG icons
  - `layout/` — Layout wrappers
- `lib/` — Helpers, API wrappers, config
  - `lib/strapi.ts` — `strapiFetch`, `buildStrapiUrl` (server-only)
  - `lib/strapi-client.ts` — `clientFetch`, `uploadFile`, `buildAuthHeaders` (client-only)
  - `lib/strapi-helpers.ts` — `getStrapiMediaUrl(url)`, `stripHtml()`
  - `lib/meilisearch.ts` — `getMeilisearchClient()`, `searchBlogPostsViaMeilisearch()`
  - `lib/api/` — Domain functions (16 files)
  - `lib/i18n/glossary.ts` — Từ điển tiếng Việt chuẩn (`i18n` object)
  - `lib/config/pagination.ts` — `PAGINATION` constants + `getPaginationRange()`
- `types/strapi.ts` — Tất cả TypeScript interfaces
- `contexts/AuthContext.tsx` — Global auth state (`user`, `loading`, `refresh()`)
- `hooks/use-mobile.tsx` — Hook detect mobile breakpoint
- `hooks/use-toast.ts` — Hook toast (sonner)
- `data/navigation.ts` — Navigation links constants
- `data/mockContributions.ts` — Mock data fallback
- `middleware.ts` — Route protection `auth_token` cookie (edge, matcher: `/profile/*`)
- `public/manifest.json` — PWA manifest
- `public/sw.js` — Service Worker
- `public/images/` — Static assets (logo, icons)
- `tailwind.config.ts` — Tailwind config + custom design tokens
- `next.config.mjs` — Next.js config (Redis ISR, image domains, TypeScript strict)
- `cache-handler.js` — Custom ISR handler (Redis / file system)

### lib/api/ — Domain Functions (16 files)

- `archive.ts` — `fetchArchiveIndex()`, `fetchArchivePosts(year, month)`
- `beginnerGuide.ts` — `fetchBeginnerGuides()`, `fetchBeginnerGuideFiles()`
- `blog.ts` — `fetchBlogPosts()`, `fetchBlogPost(slug)`, `fetchRelatedPosts()`, `checkDuplicatePost(sourceUrl)`
- `blogComments.ts` — `fetchCommentsByPost(slug)`, `submitComment()`, `likeComment()`
- `categories.ts` — `fetchCategories()`, `buildCategoryTree()` (server-only)
- `categories-client.ts` — `fetchCategoriesClient()` (client-only)
- `chanting.ts` — `fetchTodayChant(date, planSlug)`, type `TodayChantResponse`
- `community.ts` — `fetchCommunityPosts()`, `submitCommunityPost()`, `likeCommunityPost()`
- `downloads.ts` — `fetchDownloads()`, `fetchDownloadsByCategory()`, `DOWNLOAD_CATEGORIES` (server-only)
- `guestbook.ts` — `fetchGuestbookEntries()`, `submitGuestbookEntry()`, `fetchGuestbookArchive()`
- `guides.ts` — alias `fetchGuides()` → `fetchBeginnerGuides()`
- `homepage.ts` — `fetchHomepageSettings()` (hero, stats, phapbao, v.v.)
- `hub.ts` — `getHubBySlug(slug)`, `getHubPages()` với ISR 3600s
- `lunar-calendar.ts` — `fetchLunarEvents()`, `fetchLunarEventsWithBlogs()`
- `series.ts` — `fetchSeriesPosts(seriesKey)`
- `settings.ts` — `getSiteSettings()` (StickyBanner, social links)
- `sidebar.ts` — `fetchSidebarConfig()`
- `user.ts` — `fetchUserProfile()`, `updateUserProfile()`, `uploadAvatarFile()`

### Tất cả trang app/ (App Router)

#### Trang công khai (ISR)
- `/` — Trang chủ, ISR 3600s, dữ liệu từ `setting` SingleType
- `/blog` — Danh sách bài (Server + `BlogListClient` client filter/pagination)
  - `/blog/[slug]` — Chi tiết bài (ISR 3600s, `generateStaticParams`)
- `/niem-kinh` — Niệm kinh (tính âm lịch server-side → `ChantingRunner` client)
- `/beginner-guide` — Hướng dẫn sơ học (Server, ISR)
- `/lunar-calendar` — Lịch âm (Client)
- `/category/[slug]` — Bài viết theo danh mục (Server, ISR)
- `/search` — Tìm kiếm full-text Meilisearch (Client, Server Action)
- `/events` — Sự kiện Phật giáo (Client)
- `/videos` — Video (Client)
- `/radio` — Radio stream (Client)
- `/library` — Thư viện PDF/tài liệu (Client)
- `/shares` — Chia sẻ cộng đồng (Client)
- `/donations` — Ủng hộ (Static)
- `/testimonials` — Cảm nhận (Static)
- `/directory` — Danh bạ (Static)
- `/hub/[slug]` — Hub pages động từ CMS (Server)
- `/guestbook` — Sổ lưu bút (Client)
  - `/guestbook/[year]/[month]` — Archive lưu bút theo tháng
- `/archive` — Blog archive theo năm/tháng
  - `/archive/[year]/[month]` — Bài viết theo tháng
- `error.tsx` / `not-found.tsx` — Error boundaries
- `layout.tsx` — Root layout (metadata, font, Providers, ServiceWorker)
- `providers.tsx` — Client providers (AuthContext, ThemeProvider, PostHog)

#### Trang có xác thực (cookie protected)
- `/profile` — Hồ sơ người dùng (Client, protected bởi middleware)
- `/auth` — Đăng nhập / Đăng ký
  - `/auth/google/` — Google OAuth initiation
  - `/auth/google/callback` — Google OAuth callback page

### app/api/ — Route Handlers

#### Auth
- `POST /api/auth/login` → Proxy Strapi `/auth/local` → set `auth_token` httpOnly cookie
- `POST /api/auth/register` → Proxy Strapi `/auth/local/register` → set cookie
- `GET  /api/auth/me` → Đọc cookie → gọi Strapi `/users/me` → user JSON
- `POST /api/auth/logout` → Xóa `auth_token` cookie (Set-Cookie: maxAge=0)
- `GET  /api/auth/google-callback` → Trao đổi Google code → JWT Strapi → set httpOnly cookie (7d, SameSite:lax)

#### User
- `PUT  /api/user/update` → Proxy PUT `/users/me` dùng cookie JWT
- `POST /api/user/avatar` → Proxy upload avatar dùng cookie JWT (multipart)

#### Nội dung (Proxy với ISR tags)
- `GET /api/blog-posts` → Proxy Strapi với `next: { tags: ['blog-posts'] }`
- `GET /api/categories` → Proxy danh mục
- `GET /api/lunar-events` → Proxy sự kiện âm lịch
- `GET /api/today-chant` → Tính âm lịch (Asia/Bangkok) + proxy `/chant-plans/today-chant`
- `GET /api/hub` → Proxy hub pages
- `GET /api/sidebar-config` → Proxy sidebar config

#### Practice Log (yêu cầu JWT cookie)
- `GET /api/practice-log` → Proxy `GET /practice-logs/my` (Strapi)
- `PUT /api/practice-log` → Proxy `PUT /practice-logs/my` (Strapi)

#### Push Notifications
- `POST   /api/push/subscribe` → Lưu VAPID subscription
- `DELETE /api/push/subscribe` → Hủy subscription
- `POST   /api/push/send` → Gửi notification (header `Authorization: Bearer <PUSH_SEND_SECRET>`, dùng cho cron)

#### Server Actions
- `app/actions/search.ts` → Server Action tìm kiếm (gọi Meilisearch)

#### Revalidation
- `POST /api/revalidate?tag=<tag>&secret=<REVALIDATE_SECRET>` → On-demand ISR clear

### Tất cả Components

#### Layout
- `Header.tsx` — Nav (Client, `useAuth`, dark mode toggle, mobile menu)
- `Footer.tsx` — Footer (Static)
- `StickyBanner.tsx` — Biểu ngữ đính từ CMS (Client, dismiss)
- `Breadcrumbs.tsx` — Breadcrumb navigation

#### Trang chủ
- `HeroSection.tsx` — Carousel ảnh bìa (embla-carousel, priority image)
- `ContentFeeds.tsx` — Luồng nội dung tổng hợp (blog + events)
- `ActionCards.tsx` — Thẻ hành động (links nhanh)
- `PhaoBaoSection.tsx` — 5 Pháp Bảo blocks
- `RegisterSection.tsx` — CTA đăng ký cộng đồng
- `AboutSection.tsx` — Giới thiệu trang
- `AwardsSection.tsx` — Giải thưởng / công nhận
- `HallGallery.tsx` — Gallery ảnh sự kiện (Framer Motion)
- `VideoSection.tsx` — Video nổi bật (YouTube embed)

#### Blog & Nội dung
- `BlogListClient.tsx` — Filter + pagination (Client)
- `BlogPagination.tsx` — Phân trang (`PAGINATION` constants, ellipsis)
- `CategoryNav.tsx` — Điều hướng danh mục có cây phân cấp
- `SearchDirectory.tsx` — Tìm kiếm danh bạ (Client)
- `PdfPreview.tsx` — Xem trước PDF (iframe, responsive)
- `ViewTracker.tsx` — Auto `POST /blog-posts/:documentId/view` (useEffect, 1 lần/session)
- `blog/SeriesNav.tsx` — Điều hướng bài trong cùng series

#### Niệm Kinh
- `ChantingGuidelinesDialog.tsx` — Hướng dẫn niệm kinh (Dialog/Sheet)
- `ChantingNotesSection.tsx` — Ghi chú nghi thức
- `DailyRecitationQA.tsx` — Q&A hằng ngày
- `DailyRecitationSteps.tsx` — Các bước tu tập step-by-step

#### Cộng đồng & Tương tác
- `comments/CommentsSection.tsx` — Container bình luận
- `comments/CommentsClient.tsx` — UI danh sách (Client, nested)
- `comments/CommentForm.tsx` — Form gửi bình luận
- `comments/CommentItem.tsx` — Item + like + reply
- `guestbook/GuestbookForm.tsx` — Form sổ lưu bút
- `guestbook/GuestbookList.tsx` — Danh sách lưu bút + like
- `archive/ArchiveGrid.tsx` — Grid lưu trữ theo năm
- `archive/ArchivePostList.tsx` — Danh sách bài theo tháng

#### Hub & Thư viện
- `hub/HubPageComponent.tsx` — Trang hub tổng hợp
- `hub/HubSection.tsx` — Section trong hub
- `hub/HubLinkCard.tsx` — Card link trong hub
- `hub/HubBlockRenderer.tsx` — Render dynamic blocks (post-list-auto, post-list-manual, download-grid, rich-text)
- `library/LibraryClient.tsx` — Client lọc tài liệu tải xuống

#### User & Profile
- `AvatarUploader.tsx` — Upload ảnh đại diện (proxy `/api/user/avatar`)
- `NewsletterSignup.tsx` — Đăng ký nhận tin

#### Tiện ích
- `MeditationTimer.tsx` — Đồng hồ thiền (countdown/countup, preset 5-60p, Web Audio API, Vibration API)
- `PushNotificationButton.tsx` — Bật/tắt push, chọn giờ nhắc (6AM–11PM)
- `ThemeToggle.tsx` — Chuyển Sáng/Tối (`next-themes`)

### TypeScript Types (types/strapi.ts)

#### Generic wrappers
- `StrapiList<T>` — `{ data: T[], meta: { pagination: { page, pageSize, pageCount, total } } }`
- `StrapiSingle<T>` — `{ data: T, meta: {} }`
- `StrapiMedia` — `{ id, documentId, name, alternativeText, formats, url, mime, size, width, height, provider }`
- `StrapiMediaFormat` — `{ name, hash, ext, mime, width, height, size, url }`
- `StrapiSEO` — `{ metaTitle, metaDescription, metaImage, keywords, canonicalURL }`

#### Content types
- `Category` — `{ id, documentId, name, slug, color, order, is_active, parent, children, blog_posts }`
- `CategoryTree extends Category` — `{ children: CategoryTree[], depth: number }`
- `BlogTag` — `{ id, documentId, name, slug, description, blog_posts }`
- `BlogPost` — `{ id, documentId, title, slug, content, excerpt, original_link, categories[], tags[], thumbnail, gallery[], video_url, audio_url, views, likes, status, featured, original_title, sourceName, sourceUrl, sourceTitle, related_posts[], seriesKey, seriesNumber, eventDate, location, seo }`
- `BeginnerGuide` — `{ title, description, content, details[], duration, order, step_number, guide_type: 'so-hoc'|'kinh-bai-tap', icon, pdf_url, video_url, images[] }`
- `BeginnerGuideFile` — `{ name, description, order, files[] }`

#### Homepage components
- `HeroSlide` — `{ src, title, highlight, sub }`
- `StatItem` — `{ value, label, detail }`
- `PhapBaoItem` — `{ id, title, chinese, color, borderColor, description, link, iconType }`
- `ActionCardItem` — `{ title, description, link, iconType }`
- `VideoItem` — `{ id, title, subtitle, description, youtubeId, duration, category }`
- `AwardItem` — `{ year, title, org, description }`
- `GallerySlide` — `{ src, caption, subcap }`
- `StickyBannerConfig` — `{ title, subtitle, buttonText, buttonLink, enabled }`

### Design System & Styling Rules

- `cn()` từ `@/lib/utils` — BẮT BUỘC gộp className, KHÔNG string concatenation
- KHÔNG hardcode hex color — Dùng CSS variables / Tailwind tokens
- Dark mode: class `.dark` trên `<html>` (next-themes)
- Font tiêu đề: `font-display` (Playfair Display), Font thân: `font-body` (Be Vietnam Pro)
- Màu vàng nhấn: `text-gold` / `bg-primary` / `bg-gold`
- Mobile-first responsive
- HTML semantic (`article`, `section`, `nav`, `main`) + ARIA attributes
- Tailwind Typography plugin cho blog content (`prose prose-stone dark:prose-invert`)

### Fetch Rules (Quy tắc fetch)

- `strapiFetch` — Server Components, Route Handlers, Server Actions ONLY
- `clientFetch` — Client Components (`'use client'`) ONLY
- `getStrapiMediaUrl(url)` — BẮT BUỘC mọi media URL
- KHÔNG template literal: `` `${STRAPI_URL}${img.url}` ``
- `populate` — BẮT BUỘC khai báo rõ ràng cho mọi request
- `populate: '*'` — KHÔNG dùng (chỉ lấy scalar fields + components, không lấy relations)
- `status: 'published'` — luôn thêm cho FE fetch
- ISR: `export const revalidate = 3600`
- Dynamic: `export const dynamic = 'force-dynamic'`
- Webhook: `POST /api/revalidate?tag=blog-posts&secret=...`
- Fallback: constants `FALLBACK_*` khi CMS empty
- `pageSize` — tối đa 100 (giới hạn Strapi maxLimit), phân trang nếu cần nhiều hơn

### Auth Flow (HTTP-only Cookie)

- Cookie: `auth_token` — httpOnly, SameSite: lax, Secure (prod), 7 ngày
- KHÔNG localStorage — đã migrate hoàn toàn (chống XSS)
- `AuthContext.tsx` — `user`, `loading`, `refresh()` → gọi `GET /api/auth/me`
- `useAuth()` → `{ user, loading, refresh }`
- `middleware.ts` → bảo vệ `/profile/*` ở edge, redirect `/auth?redirect=originalPath`
- Login: `POST /api/auth/login` → Strapi `/auth/local` → set cookie → `refresh()`
- Google: `/auth/google/callback` → `GET /api/auth/google-callback` → set cookie
- Logout: `POST /api/auth/logout` → clear cookie → redirect `/auth`

### PWA & Notifications

- manifest: tên, icons, shortcuts (Niệm Kinh, Lịch Âm, Blog), display: standalone
- Service Worker: cache-first static, network-first `/api/*`
- `layout.tsx`: metadata `manifest`, `appleWebApp` (iOS installable), SW registration Script
- Push: VAPID handshake → `POST /api/push/subscribe` → daily cron `POST /api/push/send`
- Generate VAPID: `npx web-push generate-vapid-keys`

### ISR Cache Strategy

- Default: 3600s (blog, homepage, guide)
- Dynamic: `force-dynamic` (profile, practice-log, push)
- On-demand: webhook Strapi → `POST /api/revalidate?tag=...&secret=...`
- Redis handler (`cache-handler.js`): khi `REDIS_URL` → Redis; không thì file system
- Packages: `@neshca/cache-handler`, `ioredis`
- Upstash free: `rediss://default:xxx@xxx.upstash.io:6380`

---

---

## BACKEND (BE_PMTL — Strapi v5)

### Stack & Phiên bản

- Strapi v5.38.0, TypeScript
- Node.js 20.x–24.x, npm >= 6
- SQLite `better-sqlite3` (dev) / PostgreSQL `pg` (prod) / MySQL (optional)
- CKEditor5 via `@_sh/strapi-plugin-ckeditor` 7.x
- `@strapi/plugin-users-permissions` 5.38.0
- `@strapi/provider-email-nodemailer` 5.38.0
- `strapi-plugin-meilisearch` 0.15.0 (auto-sync bài viết)
- `@strapi/plugin-cloud` 5.38.0
- `fs-extra` 11.x (đọc google-auth-config.json)

### Cổng & Đường dẫn

- API: `http://localhost:1337/api`
- Admin UI: `http://localhost:1337/admin`
- Token: `STRAPI_API_TOKEN` — server-side ONLY, KHÔNG dùng prefix `NEXT_PUBLIC_`

### Cấu hình (config/)

- `config/server.ts` — host `0.0.0.0`, port 1337, APP_KEYS (array)
- `config/database.ts`
  - Multi-client: `sqlite` | `postgres` | `mysql`
  - Postgres: `DATABASE_URL` (connectionString) hoặc host/port/user/pass riêng lẻ, SSL optional, schema `public`
  - Pool: `min: 2`, `max: 10`, `acquireConnectionTimeout: 60000`
  - SQLite path: `__dirname/../../.tmp/data.db`
- `config/middlewares.ts`
  - CSP `img-src`, `media-src`: `res.cloudinary.com`, `lh3.googleusercontent.com`, `phapmontamlinh.vn`
  - `frame-src`: `www.youtube.com`, `vimeo.com`
  - `frame-ancestors`: localhost:3000, localhost:3001, phapmontamlinh.vn, www.phapmontamlinh.vn
  - CORS origins: localhost:3000, localhost:3001, phapmontamlinh.vn, www.phapmontamlinh.vn
  - `credentials: true`
- `config/plugins.ts`
  - Email: SMTP host/port/secure/auth, `from: no-reply@phapmontamlinh.vn`
  - Users-Permissions: JWT, allowedFields `[fullName, phone, address, avatar_url, bio, dharmaName]`
  - Google provider: enabled, callback `{FRONTEND_URL}/auth/google/callback`, scope `[openid, email, profile]`
  - CKEditor5: enabled
  - Meilisearch: `host`, `apiKey`

### Content Types — 18 tổng

#### Blog & Nội dung

- `blog-post` — Draft & Publish
  - Trường: `title`, `slug`, `content` (richtext CKEditor5), `excerpt`, `original_link`, `categories[]` (M2M), `tags[]` (M2M), `thumbnail` (media), `gallery[]` (media), `video_url`, `audio_url`, `views`, `likes`, `status`, `featured`, `original_title`, `source`, `related_posts[]` (self-relation M2M), `seriesKey`, `seriesNumber`, `eventDate`, `location`, `seo` (component shared.seo)
  - Routes tùy chỉnh:
    - `POST /blog-posts/:documentId/view` → `incrementView` (atomic SQL)
    - `GET  /blog-posts/archive` → `archive` (bài theo năm/tháng)
    - `GET  /blog-posts/archive-index` → `archiveIndex` (index tháng có bài)
    - `GET  /blog-posts/series/:seriesKey` → `series` (bài cùng series)
  - Files: `routes/blog-post.ts`, `routes/custom-blog-post.ts`, `routes/02-archive.ts`, `routes/03-series.ts`

- `category` — Draft & Publish
  - Trường: `name`, `slug`, `description`, `color` (hex), `order`, `is_active`, `parent` (self-relation), `blog_posts[]`

- `blog-tag` — Draft & Publish
  - Trường: `name`, `slug`, `description`, `blog_posts[]`

- `blog-comment` — Draft & Publish
  - Trường: `content`, `authorName`, `authorCountry`, `authorAvatar`, `userId`, `post` (→ blog-post), `likes`, `parent` (self-relation), `parent_id` (legacy integer)
  - Routes (`routes/01-custom.ts` — load trước core router):
    - `POST /blog-comments/submit` → `submit` (không auth)
    - `POST /blog-comments/like/:documentId` → `like` (atomic)
    - `GET  /blog-comments/by-post/:slug` → `byPost` (nested comments theo slug bài)
    - `GET  /blog-comments/latest` → `latest` (bình luận mới nhất toàn site)

#### Hướng dẫn & Tài liệu

- `beginner-guide` — Draft & Publish
  - Trường: `title`, `description`, `content`, `details[]` (JSON array), `duration`, `order`, `step_number`, `guide_type` (`so-hoc` | `kinh-bai-tap`), `icon`, `pdf_url`, `video_url`, `images[]`, `files[]` (→ beginner-guide-file)

- `beginner-guide-file` — Draft & Publish
  - Trường: `name`, `description`, `order`, `files[]` (media), `guide` (→ beginner-guide)

#### Hệ thống Niệm Kinh

- `chant-plan` — không Draft & Publish
  - Trường: `title`, `slug`, `description`, `planItems[]` (component `chanting.plan-item`)
  - Route (`routes/01-today-chant.ts`):
    - `GET /chant-plans/today-chant?date=YYYY-MM-DD&lunarMonth=M&lunarDay=D&planSlug=slug`
    - Aggregator: merge `chant-plan` + `lunar-event` + `lunar-event-chant-override`
    - Response: `{ date, planSlug, items[{ slug, title, type, target, max, note }], todayEvents[] }`

- `chant-item` — không Draft & Publish
  - Trường: `title`, `slug`, `type` (`kinh` | `chu` | `buoc`), `timeRule` (JSON), `recommendedSettings` (JSON), `preamble`

- `lunar-event` — không Draft & Publish
  - Trường: `title`, `type` (`le` | `an-chay` | `phat` | `bo-tat` | `to-su` | `binh-thuong`), `solarDate`, `lunarMonth`, `lunarDay`, `isRecurring`, `relatedBlogs[]`
  - Route (`routes/01-custom-with-blogs.ts`):
    - `GET /lunar-events/with-blogs` → `findWithBlogs` (không auth)

- `lunar-event-chant-override` — không Draft & Publish
  - Trường: `lunarEvent` (→ lunar-event), `chantItem` (→ chant-item), `mode` (`disable` | `activate` | `override-target` | `max-limit`), `target`, `max`, `priority`

- `practice-log` — KHÔNG Draft & Publish (real-time data)
  - Trường: `user` (→ plugin::users-permissions.user), `date`, `planSlug`, `itemProgress` (JSON), `completedAt`, `plan` (→ chant-plan)
  - Routes:
    - `GET /practice-logs/my` → `findMyLog` (JWT user required)
    - `PUT /practice-logs/my` → `upsertMyLog` (JWT user required)

#### Cộng đồng

- `community-post` — Draft & Publish (submit → draft, admin duyệt mới publish)
  - Trường: `title`, `content`, `type` (`cau-chuyen` | `cau-hoi` | `trai-nghiem`), `category`, `authorName`, `authorCountry`, `authorAvatar`, `videoUrl`, `tags[]`, `likes`, `views`, `coverImage`
  - Routes (`routes/01-custom-community-post.ts` — load trước core router):
    - `POST /community-posts/submit` → `createPost` (không auth, tạo draft)
    - `POST /community-posts/like/:documentId` → `like` (atomic increment)
    - `POST /community-posts/:documentId/view` → `incrementView` (atomic)

- `community-comment` — Draft & Publish
  - Trường: `content`, `authorName`, `authorCountry`, `authorAvatar`, `userId`, `post` (→ community-post), `likes`, `parent_id` (legacy), `parent` (self-relation)
  - Routes (`routes/01-custom-community-comment.ts` — load trước core router):
    - `POST /community-comments/submit` → `createComment` (không auth)
    - `POST /community-comments/like/:documentId` → `likeComment` (atomic)

- `guestbook-entry` — Draft & Publish
  - Trường: `authorName`, `authorCountry`, `authorAvatar`, `content`, `likes`
  - Routes (`routes/01-custom.ts`):
    - `POST /guestbook-entries/submit` → `submit` (không auth → draft)
    - `GET  /guestbook-entries/list` → `list` (không auth, phân trang)
    - `GET  /guestbook-entries/archive/:year/:month` → `archive`

#### Hub & Navigation

- `hub-page` — Draft & Publish
  - Trường: `title`, `slug`, `description`, `sections[]` (component `hub.hub-section`), `coverImage`, `curated_posts[]` (→ blog-post), `downloads[]` (→ download-item), `blocks[]` (dynamic zone: `blocks.post-list-auto`, `blocks.post-list-manual`, `blocks.download-grid`, `blocks.rich-text`)
  - Routes: `find`, `findOne` mở rộng (auth: false)

#### Hệ thống (SingleTypes)

- `setting` — SingleType
  - Trường: `siteTitle`, `siteDescription`, `logo`, `contactEmail`, `contactPhone`, `address`, `footerText`
  - Components: `heroSlides[]`, `stats[]`, `phapBaoItems[]`, `actionCards[]`, `featuredVideos[]`, `awards[]`, `gallerySlides[]`, `stickyBanner`, `searchCategories[]`, `socialLinks[]`

- `sidebar-config` — SingleType
  - Trường: cấu hình sidebar links, sections, widgets
  - Route: `find` public

- `download-item` — Draft & Publish
  - Trường: `title`, `description`, `url`, `fileType` (pdf/mp3/mp4/zip/doc/epub/html/unknown), `category`, `groupYear`, `groupLabel`, `notes`, `isUpdating`, `isNew`, `sortOrder`, `fileSizeMB`, `thumbnail` (media)
  - Dùng bởi: `/library` page và hub block `blocks.download-grid`
  - Route: public find (auth: false)

### Strapi Components (15 tổng)

#### chanting/
- `plan-item` — `{ chantItem (→ chant-item), defaultTarget, note }`

#### homepage/
- `hero-slide` — `{ src, title, highlight, sub }`
- `stat-item` — `{ value, label, detail }`
- `phap-bao-item` — `{ title, chinese, color, borderColor, description, link, iconType }`
- `action-card-item` — `{ title, description, link, iconType }`
- `featured-video` — `{ youtubeId, title, subtitle, description, duration, category }`
- `award-item` — `{ year, title, org, description }`
- `gallery-slide` — `{ src, caption, subcap }`
- `search-category` — `{ label, icon, href }`
- `sticky-banner` — `{ title, subtitle, buttonText, buttonLink, enabled }`

#### hub/
- `hub-section` — `{ title, description, links[] (→ hub.hub-link) }`
- `hub-link` — `{ label, href, icon, description }`

#### shared/
- `seo` — `{ metaTitle, metaDescription, metaImage, keywords, canonicalURL }`
- `social-link` — `{ platform, url, icon }`
- `quick-link` — `{ label, url }`

### Utils tùy chỉnh (src/utils/)

- `strapi-helpers.ts`
  - `atomicIncrementField(strapi, uid, documentId, field)` — `UPDATE ... SET field = field + 1` (Knex, 1 query, trả về new value)
  - `findPublished(strapi, uid, documentId)` — Shorthand `findOne({ documentId, status: 'published' })`
- `logger.ts`
  - `createLogger(prefix)` — Bao bọc `strapi.log.info/warn/error` với prefix module

### Khởi tạo hệ thống (src/index.ts)

#### register()
- Đọc `google-auth-config.json` (root BE) → set env `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REDIRECT_URI`
- `process.on('uncaughtException')` — Chỉ swallow `EPERM` unlink errors (Windows fix), re-throw tất cả còn lại + `process.exit(1)`

#### bootstrap()
1. Re-init `users-permissions.advanced` store nếu null → fix UI bug admin
2. Auto-repair users có `role: null` → gán `authenticated` role (Knex direct query)
3. Auto-grant Public permissions:
   - `community-post`: find, findOne, like, createPost, incrementView
   - `community-comment`: find, findOne, createComment, likeComment
   - `guestbook-entry`: submit, list, archive
   - `blog-comment`: submit, like, byPost, latest
4. Auto-activate Google OAuth provider từ config file

---

### Các bộ sưu tập (Tổng cộng 13)

#### Hệ thống Blog

- `blog-post` — Bài viết chính (Draft & Publish)
  - Các trường: tiêu đề, slug, nội dung (richtext), mô tả ngắn, ảnh đại diện, bộ sưu tập ảnh, lượt xem, danh mục[], thẻ[], seo
  - Tùy chỉnh: `POST /blog-posts/:documentId/view` — Tăng lượt xem một cách nguyên tử
- `category` — Danh mục bài viết
  - Các trường: tên, slug, mô tả, biểu tượng, cha (quan hệ tự thân)
- `blog-tag` — Thẻ bài viết
  - Các trường: tên, slug

#### Hướng dẫn & Tài liệu

- `beginner-guide` — Hướng dẫn sơ học (Draft & Publish)
  - Các trường: tiêu đề, mô tả, nội dung, chi tiết (json), thời lượng, thứ tự, số bước, loại hướng dẫn (sơ học/kinh bài tập), biểu tượng, đường dẫn pdf, đường dẫn video, hình ảnh, **tệp tải về** (→ beginner-guide-file)
- `beginner-guide-file` — Tệp tải về (Draft & Publish)
  - Các trường: tên, mô tả, thứ tự, tệp (media), **thuộc hướng dẫn** (→ beginner-guide)

#### Hệ thống niệm kinh

- `chant-plan` — Kế hoạch niệm kinh
  - Các trường: tiêu đề, slug, mô tả, các mục kế hoạch (planItems, component chanting.plan-item)
  - Tùy chỉnh: `GET /chant-plans/today-chant?date=&lunarMonth=&lunarDay=&planSlug=`
- `chant-item` — Bài niệm kinh đơn lẻ
  - Các trường: tiêu đề, slug, loại (kinh/chú/bước), quy tắc thời gian (json), cài đặt khuyến nghị (json), lời nguyện khai kinh
- `lunar-event` — Sự kiện âm lịch (lễ, kỵ, sắp tới)
  - Các trường: tiêu đề, loại sự kiện (ngày lễ/ăn chay/phật/bồ tát/tổ sư/bình thường), ngày dương, tháng âm, ngày âm, có lặp lại theo âm lịch không, các blog liên quan[]
  - Tùy chỉnh: `GET /lunar-events/with-blogs`
- `lunar-event-chant-override` — Ghi đè kế hoạch niệm kinh theo sự kiện
  - Các trường: sự kiện âm lịch (quan hệ), mục niệm kinh (quan hệ), chế độ (vô hiệu hóa/kích hoạt/ghi đè mục tiêu/giới hạn tối đa), mục tiêu, tối đa, độ ưu tiên
- `practice-log` — Nhật ký tu tập (không dùng Draft & Publish)
  - Các trường: người dùng (quan hệ), ngày, slug kế hoạch, tiến độ các mục (json), thời điểm hoàn thành, **kế hoạch** (→ chant-plan)
  - Tùy chỉnh: `GET/PUT /practice-logs/my` (Yêu cầu JWT)

#### Cộng đồng

- `community-post` — Bài đăng cộng đồng (Draft & Publish)
  - Các trường: tiêu đề, nội dung, loại (câu chuyện/câu hỏi/trải nghiệm), danh mục, tên tác giả, quốc gia tác giả, ảnh đại diện tác giả, đường dẫn video, thẻ[], lượt thích, lượt xem, ảnh bìa
  - Tùy chỉnh: `POST /community-posts/submit` (không cần xác thực), `POST /community-posts/like/:documentId`, `POST /community-posts/:documentId/view`
- `community-comment` — Bình luận (Draft & Publish)
  - Các trường: nội dung, tên tác giả, quốc gia tác giả, ảnh đại diện tác giả, id người dùng, bài đăng (quan hệ), lượt thích, id cha (số nguyên kế thừa), **cha** (→ quan hệ tự thân)
  - Tùy chỉnh: `POST /community-comments/submit`, `POST /community-comments/like/:documentId`

#### Hệ thống

- `setting` (Kiểu đơn nhất - SingleType) — Cài đặt hệ thống và nội dung trang chủ
  - Các trường: tiêu đề trang, mô tả trang, logo, liên kết mạng xã hội, email liên hệ, điện thoại liên hệ, địa chỉ, văn bản cuối trang
  - Các thành phần: trình chiếu trang chủ[], thống kê[], pháp bảo[], thẻ hành động[], video nổi bật[], giải thưởng[], ảnh bộ sưu tập[], biểu ngữ đính

### Thành phần Strapi (Tổng cộng 11)

- `chanting.plan-item` — Mục trong kế hoạch niệm kinh
- `homepage.hero-slide` — Trình chiếu ảnh bìa trang chủ
- `homepage.stat-item` — Số liệu thống kê
- `homepage.phap-bao-item` — 5 Pháp Bảo
- `homepage.action-card-item` — Thẻ hành động
- `homepage.featured-video` — Video nổi bật
- `homepage.award-item` — Giải thưởng / Công nhận
- `homepage.gallery-slide` — Ảnh trong bộ sưu tập
- `homepage.search-category` — Danh mục tìm kiếm
- `homepage.sticky-banner` — Biểu ngữ đính

### Tiện ích tùy chỉnh (src/utils/)

- `strapi-helpers.ts`
  - `atomicIncrementField(...)` — Cập nhật SQL nguyên tử (1 truy vấn)
  - `findPublished(...)` — Viết tắt để tìm một bản ghi đã xuất bản
- `logger.ts`
  - `createLogger(...)` — Hàm bao bọc `strapi.log.*` với tiền tố

### Khởi tạo hệ thống (src/index.ts)

- Tự động sửa lỗi vai trò người dùng bị trống
- Tự động cấp quyền Public cho các API cộng đồng
- Tự động kích hoạt nhà cung cấp xác thực Google từ `google-auth-config.json`
- Ngăn lỗi EPERM (thường gặp trên Windows)

---

## QUY TẮC BẮT BUỘC

### Strapi v5 — Truy cập dữ liệu

- `strapi.documents('api::uid.uid').findMany(...)` — DÙNG ĐÚNG CÁCH
- `strapi.entityService.*` — ĐÃ DEPRECATED, TUYỆT ĐỐI KHÔNG DÙNG
- `strapi.db.query(...)` — Chỉ cho SQL thô, permissions, aggregate
- `status: 'published'` — Luôn thêm khi fetch phía FE
- `documentId` (string) — Luôn dùng, KHÔNG dùng `id` (số nguyên)
- `populate: ['field', 'rel']` — Luôn khai báo explicit. `populate: '*'` chỉ lấy components & direct fields, **KHÔNG** đảm bảo lấy relations — phải list rõ
- `id` là reserved keyword — KHÔNG đặt trong component schema

### Strapi v5 — Custom Routing

- Tên file custom route bắt đầu bằng số: `01-custom.ts`, `02-archive.ts` (load trước core router)
- Nếu tên đứng sau core router theo bảng chữ cái → Strapi nhầm với `:documentId`
- BẮT BUỘC 3 files: **Route + Controller + Service** khi thêm custom endpoint
- `auth: false` trong route config = public endpoint (không cần API token)

### Strapi v5 — Định dạng dữ liệu

- Response phẳng: `item.title` KHÔNG phải `item.attributes.title` (v4 format cũ, đã bỏ)
- v5 không có `.attributes` wrapper nữa
- Luôn check `documentId` tồn tại trước khi thực hiện operations

### FE — Server/Client Boundary

- `strapiFetch` — Server Components, Route Handlers, Server Actions ONLY
- `clientFetch` — Client Components (`'use client'`) ONLY
- KHÔNG import `strapiFetch` trong file có `'use client'` → lỗi build + token leak risk
- Pass data từ Server → Client qua props
- `STRAPI_API_TOKEN` — KHÔNG dùng prefix `NEXT_PUBLIC_` bao giờ
- `NEXT_PUBLIC_STRAPI_API_URL` — Safe to expose (chỉ URL, không có secret)

### FE — Media & Images

- `getStrapiMediaUrl(url)` — BẮT BUỘC cho mọi Strapi media URL
- KHÔNG dùng template literal: `` `${STRAPI_URL}${img.url}` ``
- `next/image` — Luôn dùng (tự động optimization)
- `sizes` attribute — BẮT BUỘC cho responsive images
- Hero images: `priority` prop. Lazy: `loading="lazy"` (default)
- KHÔNG `unoptimized` (trừ YouTube iframe)
- Remote patterns phải khai báo trong `next.config.mjs`

### Bảo mật (OWASP)

- JWT trong httpOnly cookie — KHÔNG localStorage (chống XSS)
- CSRF protection: `SameSite: lax` tự động
- `STRAPI_API_TOKEN` server-side only — không log, không expose
- HTML từ user input → `stripHtml()` trước khi lưu vào Strapi
- Community submit → draft status (không auto-publish)
- Rate limiting: config trong `config/api.ts`
- CORS: chỉ whitelist domain cụ thể
- CSP: frame-ancestors whitelist (Strapi admin + FE domains)
- KHÔNG log token/bearer string
- Validate tất cả input ở API boundaries

### Code Style

- KHÔNG dùng emoji trong code/commit/comment
- Tiếng Việt chuẩn (PHẢI CÓ DẤU đầy đủ)
- KHÔNG `console.log` production → `strapi.log.*` (BE) hoặc `console.error` conditional (FE)
- KHÔNG `any` TypeScript — chỉ dùng khi ép kiểu với comment giải thích lý do
- `cn()` gộp className — KHÔNG string concatenation
- Tên biến/hàm tiếng Anh, comment tiếng Việt

### Pagination

- `BLOG_PAGE_SIZE: 20` — Trang blog
- `SEARCH_PAGE_SIZE: 20` — Trang tìm kiếm
- `CATEGORY_PAGE_SIZE: 24` — Trang danh mục
- `RELATED_BLOGS_LIMIT: 3` — Bài liên quan
- `MAX_VISIBLE_PAGES: 5` — Pagination bar
- `getPaginationRange(currentPage, totalPages)` — Tính range với ellipsis

---

## LUỒNG DỮ LIỆU CHÍNH

### Trang chủ

```
Server Component page.tsx
  strapiFetch('/setting', { populate: heroSlides, stats, phapBaoItems, ... })
  → HeroSection (carousel), ContentFeeds, ActionCards
  → PhaoBaoSection, VideoSection, AwardsSection, HallGallery
  → StickyBanner
```

### Niệm Kinh (luồng phức tạp nhất)

```
Client: GET /api/today-chant?date=YYYY-MM-DD&planSlug=...
  FE Route Handler today-chant/route.ts:
    → Tính ngày Asia/Bangkok
    → @forvn/vn-lunar-calendar → { lunarMonth, lunarDay }
    → strapiFetch('/chant-plans/today-chant?...')
  BE Strapi service chant-plan.todayChant():
    → findMany chant-plan (planItems → chant-item)
    → findMany lunar-event (ngày âm lịch hôm nay + isRecurring)
    → findMany lunar-event-chant-override (linked to today events)
    → Apply overrides: disable/activate/override-target/max-limit
    → Return: { date, planSlug, items[], todayEvents[] }
  ChantingRunner (Client):
    → Render interactive chanting UI
    → Progress: localStorage (guest) | PUT /api/practice-log (logged in user)
```

### Blog & Archive

```
/blog → fetchBlogPosts(page, category, tag)
/blog/[slug] → generateStaticParams + ISR
  → ViewTracker: POST /blog-posts/:documentId/view (atomic SQL)
  → CommentsSection → byPost/:slug
  → SeriesNav: seriesKey → fetchSeriesPosts(seriesKey)
/archive → fetchArchiveIndex() → archiveIndex endpoint
/archive/[year]/[month] → fetchArchivePosts(year, month) → archive endpoint
```

### Luồng Xác thực

```
Register/Login:
  User → POST /api/auth/login → Strapi /auth/local → JWT
  → Set-Cookie: auth_token (httpOnly, SameSite:lax, Secure:prod, 7d)
  → AuthContext.refresh() → GET /api/auth/me → /users/me → user

Google OAuth:
  /connect/google (Strapi) → Google → Google callback
  → FE /auth/google/callback → GET /api/auth/google-callback
  → Strapi /auth/google/callback?access_token=...
  → Set httpOnly cookie → redirect /

Route Protection (Edge Middleware):
  Request → middleware.ts checks cookie auth_token
  → No cookie: redirect /auth?redirect=originalPath
  → Has cookie: proceed

Logout:
  POST /api/auth/logout → Set-Cookie: auth_token=; maxAge=0 → redirect /auth
```

### Community Flow

```
Submit post: POST /community-posts/submit (no auth)
  → status: 'draft', chờ admin publish
Like: POST /community-posts/like/:documentId → atomic increment
View: POST /community-posts/:documentId/view → atomic increment
Comment: POST /community-comments/submit → status: 'draft'
  → parent_id (legacy) + parent (relation) cho nested comments
```

### Guestbook Flow

```
Submit: POST /guestbook-entries/submit → draft, chờ admin duyệt
List: GET /guestbook-entries/list?page=&pageSize=
Archive: GET /guestbook-entries/archive/:year/:month
```

### Hub Pages

```
/hub/[slug] → fetchHubPage(slug)
  → strapiFetch('/hub-pages?filters[slug]=$eq=...&populate=sections.links')
  → HubPageComponent → HubSection[] → HubLinkCard[]
```

---

## BIẾN MÔI TRƯỜNG (ENV VARIABLES)

### BE — `.env`

```env
HOST=0.0.0.0
PORT=1337
APP_KEYS=key1,key2,key3,key4
API_TOKEN_SALT=...
ADMIN_JWT_SECRET=...
JWT_SECRET=...
TRANSFER_TOKEN_SALT=...

# SQLite (dev)
DATABASE_CLIENT=sqlite
DATABASE_FILENAME=.tmp/data.db

# PostgreSQL (prod)
# DATABASE_CLIENT=postgres
# DATABASE_URL=postgresql://user:pass@host:5432/dbname
# DATABASE_SSL=true

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your@gmail.com
SMTP_PASS=app-password
SMTP_FROM=no-reply@phapmontamlinh.vn
SMTP_REPLY_TO=contact@phapmontamlinh.vn

# Frontend URL (OAuth callback)
FRONTEND_URL=http://localhost:3000

# Meilisearch
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=super-secret-key-12345
```

### FE — `.env.local`

```env
# Strapi
NEXT_PUBLIC_STRAPI_API_URL=http://localhost:1337
STRAPI_API_TOKEN=<server-side-only, TUYỆT ĐỐI KHÔNG NEXT_PUBLIC_>

# Revalidation webhook
REVALIDATE_SECRET=<random-secret>

# OAuth Google
NEXT_PUBLIC_GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com

# Meilisearch
NEXT_PUBLIC_MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_MASTER_KEY=super-secret-key-12345

# Analytics (PostHog — optional)
NEXT_PUBLIC_POSTHOG_KEY=phc_xxx
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com

# Push Notifications (VAPID)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=<public-key>
VAPID_PRIVATE_KEY=<private-key>
VAPID_EMAIL=admin@phapmontamlinh.vn
PUSH_SEND_SECRET=<cron-secret>

# Redis ISR (production)
REDIS_URL=rediss://default:xxx@xxx.upstash.io:6380
```

---

## SERVICES NGOÀI (External Services)

### Meilisearch

- Tích hợp: `strapi-plugin-meilisearch` auto-sync khi publish
- FE: `lib/meilisearch.ts` — filter: category, tags, dateFrom, dateTo
- Index: `blog-post`, sort: `publishedAt:desc`
- ⚠️ Xem xét: chỉ cần nếu blog > 20k bài — PostgreSQL fulltext là đủ cho scale nhỏ

### PostHog Analytics

- Lazy-load `app/providers.tsx` khi có `NEXT_PUBLIC_POSTHOG_KEY`
- Auto capture pageview, pageleave; autocapture off
- Free: 5000 events/tháng, EU region (GDPR ok)
- ⚠️ Thiếu `cookieless_mode: 'on_reject'` — cần thêm nếu có user EU yêu cầu GDPR strict

### Cloudflare R2 / AWS S3

- `@strapi/provider-upload-aws-s3` (R2 tương thích S3 API)
- R2 free: 10 GB + 1M read/tháng, global Cloudflare edge cache
- Setup: `MEDIA_STORAGE_SETUP.md`

### Redis ISR Cache

- `cache-handler.js`: khi `REDIS_URL` → Redis, không thì file system
- Upstash Redis free tier
- Packages: `@neshca/cache-handler`, `ioredis`
- ⚠️ Chỉ cần thiết khi deploy **multi-instance FE** — dự án 1 server thì file system cache đủ, không cần Redis

---

## SCRIPTS & COMMANDS

### Backend

```bash
npm run dev        # strapi develop (auto-reload, watch)
npm run start      # strapi start (production mode)
npm run build      # strapi build (admin UI bundle)
npm run upgrade    # npx @strapi/upgrade latest
npm run upgrade:dry  # dry run (kiểm tra trước khi upgrade)
```

### Frontend

```bash
npm run dev    # next dev (localhost:3000)
npm run build  # next build
npm run start  # next start
npm run lint   # next lint (ESLint)

# Tạo VAPID keys (chỉ cần 1 lần)
npx web-push generate-vapid-keys
```

---

## TÍNH NĂNG TRIỂN KHAI

| # | Tính năng | Mô tả | Status |
|---|-----------|-------|--------|
| 1 | HTTP-only Cookie Auth | JWT cookie, chống XSS, edge middleware | Hoàn thành |
| 2 | PWA | manifest.json, sw.js, iOS Add to Home | Hoàn thành |
| 3 | Push Notifications | VAPID, daily reminders, cron trigger | Hoàn thành |
| 4 | Meditation Timer | Countdown/countup, Web Audio, Vibration | Hoàn thành |
| 5 | Blog Comments | Nested, like, by-post, latest | Hoàn thành |
| 6 | Blog Archive | Archive năm/tháng, archive-index | Hoàn thành |
| 7 | Blog Series | seriesKey, seriesNumber, SeriesNav | Hoàn thành |
| 8 | Guestbook | Submit, list, archive theo tháng | Hoàn thành |
| 9 | Hub Pages | Dynamic CMS sections + links | Hoàn thành |
| 10 | Sidebar Config | SingleType sidebar từ CMS | Hoàn thành |
| 11 | Meilisearch | Full-text search với filter | Hoàn thành |
| 12 | Email SMTP | Nodemailer, Gmail, configurable | Hoàn thành |
| 13 | CDN Media R2/S3 | Setup guide hoàn chỉnh | Tài liệu xong |
| 14 | PostHog Analytics | Lazy-load, EU region | Config ready |
| 15 | Redis ISR Cache | Multi-instance scale | Hoàn thành |

---

## CÁC VẤN ĐỀ THƯỜNG GẶP & FIX

### EPERM unlink trên Windows
- `src/index.ts register()` — swallow EPERM unlink, re-throw errors khác

### User thiếu Role sau register
- `bootstrap()` auto-repair: query users có `role: null` → gán `authenticated`

### Custom route bị nhầm với `:documentId`
- Đặt tên file `02-archive.ts` (số trước) → load trước core router
- **community-post** và **community-comment** đã được đặt đúng prefix `01-`

### `populate: '*'` không lấy relations
- Khai báo rõ: `populate: ['categories', 'tags', 'thumbnail']`

### `strapi.entityService` deprecated
- Dùng `strapi.documents('api::uid.uid').findMany(...)`

### Import `strapiFetch` trong Client Component
- Dùng `clientFetch` trong `'use client'`, pass data qua props từ Server

### JWT cũ trong localStorage (đã fix)
- Migrated sang httpOnly cookie — `AuthContext` không còn dùng localStorage

### `next/image` thiếu `sizes` prop
- Luôn thêm `sizes="(max-width: 768px) 100vw, 50vw"` cho responsive

---

## ĐÁNH GIÁ & KHUYẾN NGHỊ

### Mâu thuẫn đã sửa

| Vấn đề | Trạng thái |
|--------|------------|
| Auth flow: localStorage ↔ httpOnly cookie (2 nơi mô tả khác nhau) | ✅ Đã sửa — chỉ còn httpOnly cookie |
| `populate: '*'` rule mô tả không chính xác | ✅ Đã sửa — lấy components & direct fields, KHÔNG lấy relations |
| Route `custom-community-post.ts` và `custom-community-comment.ts` không có numeric prefix | ✅ Đã sửa — đổi thành `01-custom-community-post.ts` và `01-custom-community-comment.ts` |
| `practice-log` controller dùng `strapi.db.query` cho tìm kiếm plan và entry | ✅ Đã sửa — dùng `strapi.documents` với `documentId` |
| `blog-post` archive count query trộn camelCase và snake_case | ✅ Đã sửa — dùng `published_at` snake_case nhất quán |
| `community-post findOne` populate `cover_image: true` | ✅ Đã sửa — populate explicit fields |
| `@studio-freight/react-lenis` còn trong package.json | ✅ Đã xóa — đã dùng `lenis/react` đúng cách |
| `lib/strapi.ts` default `populate = '*'` | ✅ Đã sửa — không có default, cần khai báo explicit |
| `checkDuplicatePost` filter theo field `source` không tồn tại | ✅ Đã sửa — filter theo `sourceUrl` |
| `app/library/page.tsx` và `downloads.ts` dùng `pageSize: 300/200` | ✅ Đã sửa — `pageSize: 100` (Strapi maxLimit) |
| `hub.ts getHubBySlug` dùng `noCache: true` mâu thuẫn với ISR 3600s | ✅ Đã sửa — dùng `next: { revalidate: 3600, tags: ['hub-pages'] }` |
| `ViewTracker.tsx` có `console.log` production | ✅ Đã xóa |
| `DownloadLinksWidget.tsx` import `Link` không dùng | ✅ Đã xóa |
| `app/api/revalidate/route.ts` có `@ts-nocheck` và console.log/warn/error | ✅ Đã xóa |
| `app/hub/[slug]/page.tsx` title thiếu dấu tiếng Việt | ✅ Đã sửa — "Pháp Môn Tịnh Lư" |
| `lib/strapi-client.ts` chứa fallback `data.attributes.url` (Strapi v4 format) | ✅ Đã xóa |
| `next.config.mjs` `typescript.ignoreBuildErrors: true` | ✅ Đã tắt — TypeScript chặt chẽ khi build |

### Dependencies — Cần chú ý

| Package | Vấn đề | Khuyến nghị |
|---------|--------|-------------|
| `better-sqlite3` | Build fail trên Node 22+ (đã xảy ra trên Windows) | Dùng `sqlite3` driver hoặc nâng lên PostgreSQL |
| `next` 14.2.35 | Ecosystem đang chuyển sang Next.js 15 | Nên nâng — caching minh bạch hơn, server actions stable, App Router cải thiện |
| `posthog-js` | Thiếu `cookieless_mode: 'on_reject'` | Thêm vào `app/providers.tsx` nếu có user EU (GDPR) |
| `public/sw.js` (viết tay) | Dễ bug, stale cache, khó maintain | Thay bằng `next-pwa` hoặc Workbox (auto-precache + update handling) |

### Kiến trúc — Xem xét với 1 FE server

| Thành phần | Vấn đề | Khuyến nghị |
|------------|--------|-------------|
| **Meilisearch** | Thêm infra + sync complexity | Chỉ cần nếu blog > 20k bài — PostgreSQL fulltext (`to_tsvector`) đủ cho scale nhỏ |
| **Redis ISR cache** | Chỉ có lợi khi multi-instance FE | Dự án 1 server → không cần `REDIS_URL`, tiết kiệm complexity |
| **`lib/api/` 16 files** | Quá fragmented — 1 file/content-type | Gộp theo domain: `blog.ts`, `community.ts`, `content.ts`, `user.ts`, `event.ts` |
| **`practice_log.itemProgress`** | JSON field khó query analytics/stats | Cân nhắc tách bảng `practice-log-item` (logId, itemSlug, progress, updatedAt) |
| **`blog-comment.parent_id`** | Integer legacy cùng tồn tại với `parent` relation | Migration: xoá `parent_id`, chỉ dùng `parent` (self-relation) để tránh inconsistent |

### Bảo mật — Cần cải thiện

| Vấn đề | Rủi ro | Fix |
|--------|--------|-----|
| `POST /community-posts/submit` không auth | Bot spam posts | Rate-limit trong `config/api.ts` + hCaptcha / Cloudflare Turnstile |
| `POST /guestbook-entries/submit` không auth | Bot spam | Tương tự trên |
| `POST /blog-posts/:id/view` không dedup | Bot inflate view count | IP hash + cooldown 1h (Redis key hoặc DB flag) |
| Push subscriptions trong `.push-subscriptions/*.json` | Mất khi server restart, không scale | Chuyển sang Strapi collection `push-subscription` |

### Cleanup — Nên làm

| Item | Lý do | Action |
|------|-------|--------|
| `components/AwardsSection.tsx` | Cảm giác marketing, không phù hợp website Phật pháp | Đổi thành "Đóng góp / Ủng hộ" hoặc xoá |
| Framer Motion trong `HallGallery` | Animation nặng trang không cần thiết | Thay bằng CSS grid + `transition` thuần |
| `data/mockContributions.ts` | Mock data — không dùng trong production | Xoá nếu đã có real API data |

### Next.js 15 — Roadmap nâng cấp

Breaking changes chính khi nâng từ 14.2 → 15:

| Change | Chi tiết | Impact |
|--------|----------|--------|
| `params` / `searchParams` | Async — cần `await params` trong page/layout | Cao — nhiều files |
| `headers()` / `cookies()` | Async — cần `await cookies()` | Cao — nhiều Route Handlers |
| `fetch()` cache | Không còn cache mặc định — thêm `{ cache: 'force-cache' }` | Trung bình |
| Server Actions | Stable (không cần `experimental: { serverActions: true }`) | Thấp |
| Turbopack | Stable cho `next dev` | Tốt |

```bash
# Bước 1: Codemod tự động fix đa số breaking changes
npx @next/codemod@canary upgrade latest

# Bước 2: Kiểm tra thủ công tất cả files dùng cookies()/headers()
# Bước 3: Kiểm tra Route Handlers có fetch với cache assumptions
# Bước 4: Test generateStaticParams() + ISR behavior
```
