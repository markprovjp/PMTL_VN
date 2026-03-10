# Ke Hoach Toi Uu Strapi Backend (PMTL_VN)

Sau khi kiem ke toan bo 13 API collections, 11 components, cac custom controller va config, duoi day la danh sach day du cac van de phat hien va ke hoach toi uu. Muc tieu: giam no code, tang do ben vung, de bao tri, an toan hon.

---

## Ket Qua Kiem Ke — Van De Phat Hien

### A. Code Quality (can lam ngay)

| Muc | Van de | File |
|-----|--------|------|
| A1 | Dung `console.log` trong controller production (co the lo thong tin nhay cam) | `chant-plan/controllers`, `blog-post/controllers`, `community-post/controllers`, [src/index.ts](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/index.ts) |
| A2 | `practice-log/controllers` van dung `strapi.entityService` (bi deprecated Strapi v5) | [practice-log/controllers/practice-log.ts](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/practice-log/controllers/practice-log.ts) |
| A3 | `blog-post/controllers` goi [findOne](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/community-post/controllers/community-post.ts#137-162) 2 lan (published + draft) de incrementView — du thua | [blog-post/controllers/blog-post.ts](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/blog-post/controllers/blog-post.ts) |
| A4 | `community-post` like endpoint nhan ca `documentId` lan `id int` — logic phan nhanh phuc tap, de loi | `community-post/controllers` |
| A5 | Thieu shared utility function — moi controller tu viet logic `findOne + update` rieng | Nhieu controllers |

### B. Data Model (de nghi cap nhat schema)

| Muc | Van de | Giai phap |
|-----|--------|-----------|
| B1 | `community-post.tags` va `community-post.category` dung kieu primitive ([json](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/out.json), `enumeration`) thay vi relation — khong the filter/search theo tag | Giu nguyen (chuyen sang relation ton nhieu cong, rui ro migration) — bo sung index |
| B2 | `community-comment.parent_id` dung `integer` thay vi relation tu tham chieu — khong dam bao toan ven du lieu | **Migrate sang `parent` relation tu tham chieu** |
| B3 | `practice-log.planSlug` dung `string` thay vi `relation` sang `chant-plan` — chi join bang ten, de bi loi khi doi ten plan | **Bo sung relation field `plan` (optional) de join chinh xac, giu `planSlug` lam cache** |
| B4 | `beginner-guide` va `beginner-guide-file` la 2 collection hoat dong doc lap nhung khong co lien ket — admin kho quan ly | **Bo sung relation `files` trong `beginner-guide` tro den `beginner-guide-file`** |
| B5 | `community-post.author_avatar` dung `string` (URL thu cong) — kho kiem soat, khong dung Strapi Media | Giu nguyen (khong the nen thay doi, FE da dung) — them `maxLength` validation |
| B6 | `blog-post` thieu field `reading_time` (tu dong tinh tu content length) — FE hien chay frontend estimate | **Them computed field `readingTime` (integer, minutes, auto-fill lia lifecycle hook)** |
| B7 | `setting` (SingleType) chua `heroSlides`, `stats`, `phapBao`, `actionCards`,... qua lon 1 schema | Giu nguyen vi day la data trang chu (chinh dang), khong chia nho de tranh over-engineering |

### C. Security / Performance

| Muc | Van de | Giai phap |
|-----|--------|-----------|
| C1 | `blog-post.incrementView` goi [findOne](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/community-post/controllers/community-post.ts#137-162) x2 + `update` x2 per request — 4 DB queries/view | **Giam xuong 1 raw SQL `UPDATE ... SET views = views + 1`** |
| C2 | `community-post.like` khong co rate limiting — co the spam like | **Them response cache / middleware chong spam don gian (dung Strapi middleware)** |
| C3 | [src/index.ts](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/index.ts) bo qua `uncaughtException` tren Windows — hien dung `console.warn`, can dung logger | **Chuyen sang `strapi.log.warn`** |
| C4 | `community-post/createPost` khong sanitize HTML trong `content` — XSS neu render HTML | **Them sanitize middleware or input clean** |
| C5 | Bootstrap tren index.ts tu dong grant permissions cho public — neu chay lai co the bi race condition | **Them kiem tra idempotent — da co, nhung can them log ro rang hon** |

### D. Co the Gop / Tai Su Dung (DRY)

| Muc | Giai phap |
|-----|-----------|
| D1 | Tao `src/utils/strapi-helpers.ts`: cac ham dung chung nhu `atomicIncrement(collection, documentId, field)` |
| D2 | Tao `src/utils/logger.ts`: wrapper nho cho `strapi.log.*` thay vi console.* |
| D3 | Gop logic [findOne(published) + findOne(draft)](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/community-post/controllers/community-post.ts#137-162) trong `blog-post.incrementView` thanh 1 ham |

---

## User Review Required

> [!WARNING]
> **B2 — Migrate `community-comment.parent_id` thanh relation**: Can migration data. Hien tai `parent_id` la integer (luu `id` cot). Sau migration phai convert tat ca gia tri cu sang `documentId` cua comment. **Khuyen nghi: chi lam neu so luong comments hien tai it (< 1000 cai), neu khong giu nguyen de tranh mat data.**

> [!IMPORTANT]
> **B3 — Bo sung relation `plan` trong `practice-log`**: Thay doi schema se yeu cau Strapi restart va co the anh huong migration SQLite/PostgreSQL. Can kiem tra truoc khi lam production.

> [!NOTE]
> **B6 — `readingTime` lifecycle hook**: Dam bao FE khong bi break do truoc day FE tu tinh. Sau opt-in nay, FE chi can dung field tu BE.

---

## Proposed Changes

### Component 1: Shared Utilities (moi, DRY)

#### [NEW] src/utils/strapi-helpers.ts
- Ham `atomicIncrementField(strapi, uid, documentId, field)`: dung raw SQL atomic `UPDATE ... SET field = field + 1 WHERE documentId = ?` — giam 4 DB queries xuong 1.
- Ham `findPublished(strapi, uid, documentId)`: shorthand [findOne](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/community-post/controllers/community-post.ts#137-162) voi `status: published`.

#### [NEW] src/utils/logger.ts
- Wrapper `strapiLogger(prefix)`: tra ve object `{ info, warn, error }` dung `strapi.log.*` thay vi `console.*`.

---

### Component 2: src/index.ts — Code Quality

#### [MODIFY] src/index.ts
- Thay tat ca `console.log/warn/error` bang `strapi.log.info/warn/error`.
- Bo sung comment giai thich ro hon cho phan bootstrap permission.

---

### Component 3: blog-post Controller — Toi Uu incrementView

#### [MODIFY] src/api/blog-post/controllers/blog-post.ts
- Thay 4 DB queries (findOne x2, update x2) bang 1 ham `atomicIncrementField` dung raw SQL.
- Xoa console.log, dung logger wrapper.

---

### Component 4: community-post Controller — Cleanup + Security

#### [MODIFY] src/api/community-post/controllers/community-post.ts
- [like()](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/community-post/controllers/community-post.ts#45-86): Xoa nhanh fallback `db.query` + `isNaN(Number(id))`. Chuan hoa chi nhan `documentId`. Update route `/like/:documentId`.
- [createPost()](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/community-post/controllers/community-post.ts#8-44): Them sanitize cho field `content` (loai bo HTML tags neu content type la `text` khong phai `richtext`).
- [incrementView()](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/blog-post/controllers/blog-post.ts#8-66): Dung `atomicIncrementField` utility.
- Xoa `console.error`, dung logger.

#### [MODIFY] src/api/community-post/routes/custom-community-post.ts
- Doi path `/like/:id` thanh `/like/:documentId` de nhat quan.

---

### Component 5: practice-log Controller — Sua entityService Deprecated

#### [MODIFY] src/api/practice-log/controllers/practice-log.ts
- Thay `strapi.entityService.findMany` bang `strapi.documents(...).findMany`.
- Thay `strapi.entityService.update/create` bang `strapi.documents(...).update/create`.

---

### Component 6: chant-plan Controller — Xoa Console.log

#### [MODIFY] src/api/chant-plan/controllers/chant-plan.ts
- Xoa tat ca `console.log` debug (dang log planRes, allPlans, fallback...).
- Dung logger wrapper voi prefix `[today-chant]`.
- Extract `EVENT_PRIORITY` map va [getEventPriority](file:///c:/Users/ADMIN/DEV2/THINKLABS/PMTL_VN/BE_PMTL/src/api/chant-plan/controllers/chant-plan.ts#28-32) thanh module rieng hoac dat gan dau file co comment ro rang.

---

### Component 7: Schema — community-comment.parent_id

#### [MODIFY] src/api/community-comment/content-types/community-comment/schema.json
- Them field `parent` (relation oneToOne tu tham chieu sang chinh no, optional).
- Giu field `parent_id` (integer) nhu backup / legacy de khong break FE cu.

---

### Component 8: Schema — practice-log.plan relation

#### [MODIFY] src/api/practice-log/content-types/practice-log/schema.json
- Them field `plan` (relation manyToOne sang `api::chant-plan.chant-plan`, optional).
- Giu field `planSlug` (string) nhu fallback legacy.

---

### Component 9: Schema — beginner-guide + beginner-guide-file lien ket

#### [MODIFY] src/api/beginner-guide/content-types/beginner-guide/schema.json
- Them field `downloads` (relation oneToMany sang `api::beginner-guide-file.beginner-guide-file`).

#### [MODIFY] src/api/beginner-guide-file/content-types/beginner-guide-file/schema.json
- Them field `guide` (relation manyToOne nguoc lai sang `api::beginner-guide.beginner-guide`).

---

### Component 10: Schema — blog-post readingTime lifecycle

#### [MODIFY] src/api/blog-post/content-types/blog-post/schema.json
- Them field `readingTime` (integer, default 0, min 0, description "Phan tinh tu so tu content").

#### [NEW] src/api/blog-post/content-types/blog-post/lifecycles.ts
- Hook `beforeCreate` va `beforeUpdate`: neu `content` co thay doi, tinh `readingTime = Math.ceil(wordCount / 200)` (200 WPM).

---

## Verification Plan

### Khong co automated tests hien tai
> [!NOTE]
> Du an hien tai khong co thu muc `tests/` hoac cac file `*.test.ts`. Neu anh muon them tests, can setup jest hoac vitest rieng. De nghi: sau khi deploy staging, kiem tra bang manual test.

### Manual Verification — Chia theo tung component

**Sau moi thay doi: `npm run develop` trong `BE_PMTL/` de dam bao khong loi compile.**

**1. Kiem tra incrementView (A3/C1):**
```
POST /api/blog-posts/{documentId}/view
Ket qua mong doi: { ok: true, newViews: N }
```
- Goi 5 lan, kiem tra views tang chinh xac 5.

**2. Kiem tra community-post like (A4):**
```
POST /api/community-posts/like/{documentId}
Ket qua mong doi: { likes: N }
```
- Goi bang documentId hop le.

**3. Kiem tra today-chant khong con log:**
```
GET /api/chant-plans/today-chant?date=2026-03-05&lunarMonth=2&lunarDay=6
```
- Kiem tra console Strapi khong con in [today-chant] debug.

**4. Kiem tra practice-log upsert:**
```
PUT /api/practice-logs/my  (voi Bearer token)
Body: { date: "2026-03-05", planSlug: "daily-newbie", itemsProgress: {...} }
Ket qua mong doi: object log duoc update.
```

**5. Kiem tra beginner-guide + file lien ket:**
- Vao Strapi Admin → Beginner Guide → Mo 1 guide → Kiem tra co hien dropdown chon downloads.

**6. Kiem tra blog readingTime:**
- Tao bai viet moi, luu → Kiem tra field `readingTime` tu dong duoc set (> 0 neu content dai).
