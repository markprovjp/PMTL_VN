# Báo cáo phân tích toàn site lujunhong2or.com và blueprint FE/BE theo cấu trúc thực tế quan sát được

## Executive summary

lujunhong2or.com vận hành như một **cổng nội dung (content portal)** xoay quanh bài viết/giảng giải/chi sẻ theo chuyên mục, kết hợp nhiều **trang “hub” (mục lục curated)** trong menu (ví dụ: *礼佛常识*, *白话佛法*, *玄艺综述*, *弟子开示*…) và các **trang archive theo taxonomy** (*category*, *tag*), theo **thời gian** (*/YYYY/*, */YYYY/MM/*). citeturn42view0turn22view0turn26view1turn31search0turn32search6turn32search9

Hệ thống **bình luận (comments)** là một cấu phần quan trọng: nhiều bài có form bình luận với các trường *Tên/Email/Website*; bình luận có **trả lời theo thread** (“回复”); và có **phân trang bình luận** theo pattern `comment-page-n`. citeturn27view0turn35view1turn36view0 Một số trang có bình luận được **đóng** (“评论已关闭”). citeturn35view1

Các “download hubs” (*经文和整理稿*, *音频下载*, *视频下载*, *书籍下载*) chủ yếu là **danh sách liên kết ra hosting bên ngoài** (nhiều domain khác nhau), có cả file nén (zip) và các gói theo năm/series. citeturn13view7turn37view0turn13view9turn13view10turn20view1

Về crawler: robots.txt cho phép thu thập rộng rãi (chỉ disallow `/cgi-bin/` cho user-agent `*`, đồng thời nêu crawl-delay 20 giây). citeturn4search2 Tuy nhiên **không truy cập được** sitemap.xml (lỗi fetch/400) và sitemap_index.xml (404) trong quá trình kiểm tra, vì vậy cần dựa vào menu/hub pages/category/tag/archive để khám phá URL. citeturn5view2turn5view3 Ngoài ra, một số URL có thể trả về trang chặn “One moment, please…” (anti-bot), tác động đến crawling tự động. citeturn27view1

## Kiến trúc site và URL patterns

Về mặt trải nghiệm, site có **header menu** đa tầng và một **sidebar/khối phụ** lặp lại ở rất nhiều trang (thể hiện qua các block “书籍和资料下载”, “搜索”, “分类目录”, “初学者须知”, “文章存档”, “最新评论”, QR *erweima*…). citeturn42view0turn37view5turn22view3turn27view0

```mermaid
graph TD
  A[Trang chủ /] --> B[Danh sách bài viết + phân trang /page/n/]
  A --> C[Trang hub trong menu: /礼佛常识/, /白话佛法/, /玄艺综述/ ...]
  A --> D[Archive theo Category: /category/<slug>/page/n/]
  A --> E[Archive theo Tag: /tag/<slug>/page/n/]
  A --> F[Archive theo thời gian: /YYYY/ và /YYYY/MM/]
  C --> G[Download hubs: /jingwe/, /音频下载/, /视频下载/, /书籍下载/]
  C --> H[Trang hướng dẫn: /初学者须知/]
  C --> I[Trang album: /相本/ (shortcode)]
  A --> J[Guestbook: /留言板/ + /以往的留言/ + /留言板YYYYMM/]
  B --> K[Chi tiết bài: /<post-slug>/]
  K --> L[Bình luận: /<post-slug>/comment-page-n/]
```

Các pattern URL quan trọng (đều quan sát được từ site):

- **Trang chủ (首页)**: `/` là list bài mới, mỗi item thường có tiêu đề + ngày + số bình luận. citeturn1view3 Có phân trang theo ` /page/{n}/` (ví dụ `/page/20/` xuất hiện trong kết quả crawl). citeturn2view0  
- **Chi tiết bài viết**: `/{post_slug}/` (slug thường là tiêu đề tiếng Trung được URL-encode). Trang bài hiển thị tiêu đề, ngày đăng dạng `YYYY-MM-DD`, nội dung và khu vực bình luận. citeturn27view0  
- **Archive theo category**: `/category/{category_slug}/` và phân trang `/category/{category_slug}/page/{n}/`. citeturn25search0turn25search5turn25search7 Category có thể **lồng cấp** (ví dụ nhánh 网友反馈 có subcategory theo năm). citeturn25search2  
- **Archive theo tag**: `/tag/{tag_slug}/page/{n}/` (ví dụ `lujunhong`). citeturn31search0turn32search4  
- **Archive theo thời gian**: `/YYYY/` và `/YYYY/MM/`. citeturn32search6turn32search9  
- **Phân trang bình luận**: `/{page_or_post_slug}/comment-page-{n}/`. citeturn36view0turn36view2  
- **Guestbook theo tháng**: có trang lịch sử `/以往的留言/` liệt kê nhiều tháng/năm; các trang tháng có pattern dạng `/留言板YYYYMM/` và đôi khi phân chia “-上/-下” theo tháng (dữ liệu liệt kê trực tiếp). citeturn21view0turn21view3turn20view2  
- **Trang album ảnh**: `/相本/` dùng shortcode `[nak_google_picasa_album_images]` (nguồn album cụ thể không hiển thị trong bản text trích xuất). citeturn39view3  
- **Hai ngày trên một số trang/bài**: một số trang hiển thị **2 mốc ngày** trên cùng dòng (ví dụ `2021-04-29 2021-04-28` trên archive hoặc `2016-07-16 2009-02-07` ở “心灵法门注意事项”), phù hợp với mô hình có *published date* và *updated date* (site không ghi nhãn rõ, chỉ hiển thị). citeturn26view0turn39view1

Hành vi hiển thị ngày/giờ bình luận: bình luận thường ghi theo format tiếng Trung như `2026年3月2日 周一 02:44` (có thứ trong tuần và giờ phút). citeturn27view0

## Markmap

Markmap dưới đây được dựng dựa trên menu chính, các trang hub trong menu, các archive taxonomy (category/tag) và các trang đặc biệt như guestbook và download hubs. citeturn42view0turn37view0turn26view1turn31search0turn21view0turn13view7

```markdown
---
title: "lujunhong2or.com - Sitemap + FE/BE Blueprint + Data Model (Quan sát từ site)"
markmap:
  colorFreezeLevel: 2
---

## Tổng quan
- Domain: lujunhong2or.com
- Kiểu site: Cổng bài viết + hub pages + archive taxonomy + guestbook + download hubs
- Điểm nhấn:
  - Bình luận/guestbook là luồng chính (comment threads + comment paging)
  - Download chủ yếu là external links (nhiều domain)
  - Có archive theo category/tag/năm/tháng

## Điều hướng chính (Header menu)
- 首页 (/)
  - Loại trang: Blog Index (list bài mới)
  - URL pattern:
    - / (page 1)
    - /page/{n}/ (phân trang)
  - UI (FE layout blocks)
    - Header (menu đa cấp)
    - Main: danh sách PostCard
      - Title
      - Date line (có thể 1 hoặc 2 ngày)
      - Trích đoạn + “继续阅读”
      - CommentCount
    - Sidebar (global widgets, lặp lại nhiều trang)
      - Search + dropdown category
      - 分类目录 (các hub pages chính)
      - 文章存档 (dropdown tháng/năm)
      - 最新评论
      - 书籍和资料下载 + download links
      - QR/erweima
  - Dữ liệu cần có
    - Query posts: sort theo mới nhất (publish/modified)
    - Include: comment_count, excerpt, date_published/date_modified

- 全部文章 (/全部文章/)
  - Loại trang: Hub “toàn bộ bài” (ít nhất có nhóm theo năm hiện tại quan sát được)
  - UI
    - Main: heading theo năm (ví dụ 2026年) + list link bài
    - Sidebar: giống global widgets
  - Ghi chú dữ liệu
    - Có thể là page hub (curated) hơn là archive tự động (cần xác minh thêm nếu triển khai clone)

- 心灵法门 (submenu)
  - 小房子常识 (/小房子常识/)
    - Loại trang: Hub page (curated links) + nhiều block tài liệu/download
    - UI
      - Main: sections (heading + list link bài)
      - Blocks phụ: “博文资源导读”, “初学者须知”, các download links theo nhóm
  - 礼佛常识 (/礼佛常识/)
    - Loại trang: Hub page (list bài trong chuyên đề)
    - UI
      - Main: list link bài (ví dụ “学佛的理念…”)
      - Sidebar/global widgets

- 白话佛法 (submenu)
  - 白话佛法 (/白话佛法/)
    - Loại trang: Hub page (curated index cho nhiều bài thuộc nhóm 白话佛法/开示摘要/广播讲座…)
    - UI: list link bài (rất dài), không có excerpt
  - 弟子开示 (/弟子开示/)
    - Loại trang: Hub page (curated list), tiêu đề thường gắn “卢台长给全世界弟子的开示”
  - 佛言佛语 (/佛言佛语/)
    - Loại trang: Hub page
    - Pattern nội dung thường gặp:
      - chuỗi “师父涅槃前未发布的金言（n）”
      - chuỗi “2021年师父每日白话佛法（YYYY年MM月DD日）”

- 玄艺综述 (submenu)
  - 法会文章 (/法会文章/)
    - Loại trang: Hub page (curated list) + cuối trang có download links (external)
  - 佛学问答 (/佛学问答/)
    - Loại trang: Hub page (mục lục dạng đánh số 1..n)
    - Có các link tải sách/资料 external
  - 精彩专题 (/精彩专题/)
    - Loại trang: Hub page (curated专题合集)
  - 玄艺综述 (/玄艺综述/)
    - Loại trang: Hub page (curated list dài)
    - Pattern thường gặp: “弟子提问 师父回答——<sự kiện>(<phần>)”
  - 玄艺问答 (/玄艺问答/)
    - Loại trang: Hub page (curated list)
    - Pattern thường gặp: “卢台长开示解答来信疑惑（<số>）（开示于YYYY年MM月DD日）”

- 精彩反馈 (submenu)
  - 网友反馈 (/网友反馈/)
    - Loại trang: Index theo năm (2026, 2025, …; có thể link sang các year pages)
    - Main có thể chứa:
      - list bài mới nhất (ở đầu)
      - nhóm link theo năm (ở cuối)
      - block download links (external)
  - 评论回复 (/评论回复/)
    - Loại trang: Hub page (list “网友评论回复…” theo kỳ/tuần/ngày)
  - 听众感悟 (/听众感悟/)
    - Loại trang: Hub page (list bài + download/audio bundles + nhiều block tài liệu)

- 下载 (submenu)
  - 经文和整理稿 (/jingwe/)
    - Loại trang: Download hub page
    - Nội dung: danh sách link external (经文/经书/样板/资料)
  - 音频下载 (/音频下载/)
    - Loại trang: Download hub page
    - Pattern: theo năm (2008-2009, 2010, …) có:
      - “全年打包下载” (external)
      - “按日期分类下载” (internal page hoặc hub) 
  - 视频下载 (/视频下载/)
    - Loại trang: Download hub page
    - Pattern:
      - 白话佛法广播讲座 (1–68) external
      - 69集后持续更新 (internal page)
      - 历年法会完整版 (持续更新)
  - 书籍下载 (/书籍下载/)
    - Loại trang: Download hub (đi ra một “合集” external)

- 最新通知 (/最新通知/)
  - Loại trang: Hub page dạng bullet list (thông báo/纪念/通知)
  - Có thể trộn:
    - thông báo theo năm (2025/2024/…)
    - các bài “讣告/直播链接/声明/通知”
    - block download links (external) ở phần dưới/side

- 联系方式 (/联系方式/)
  - Loại trang: Thông tin liên hệ + (lịch sử) Q&A thông qua comment thread rất lớn
  - Thành phần nội dung:
    - Thông tin chuyển khoản/助印 + điện thoại + email + địa chỉ
    - Comment thread (nhiều trang) có reply từ “东方台”
    - Có thể đóng bình luận (read-only)

- 留言板 (/留言板/)
  - Loại trang: Guestbook index
  - Thành phần:
    - Link tới “留言板（tháng hiện dùng)” (thực tế là 1 page riêng)
    - Link tới “以往的留言” (danh sách lịch sử)
    - Comment thread + reply + paging

## Các trang quan trọng ngoài menu (từ sidebar/links nội bộ)
- 初学者须知 (/初学者须知/)
  - Loại trang: Guide page (hướng dẫn nhập môn + link sang các bài/资料)
  - Có thêm: lịch phát sóng theo giờ Sydney và quy đổi mùa hè/mùa đông
- 心灵法门注意事项 (có URL canonical dạng /心灵法门注意事项/; cũng truy cập được qua query id ?p=1386)
  - Loại trang: Bài viết “chính sách/điều khoản/hướng dẫn”, nhiều bình luận
- 相本 (/相本/)
  - Loại trang: Album/gallery
  - Kỹ thuật: shortcode [nak_google_picasa_album_images] (nguồn album không hiển thị)
- 以往的留言 (/以往的留言/)
  - Loại trang: Directory page liệt kê guestbook theo tháng/năm
  - Pattern: “留言板（YYYY年MM月）”, có thể chia “-上/-下”
- Trang tháng guestbook: /留言板YYYYMM/
  - Loại trang: GuestbookMonth
  - Khối: navigation tháng trước/sau + comment thread

## Archive theo taxonomy và thời gian
- Category archive
  - /category/{slug}/
  - /category/{slug}/page/{n}/
  - Có thể có hierarchy: /category/{parent}/{child}/
- Tag archive
  - /tag/{slug}/
  - /tag/{slug}/page/{n}/
- Date archive
  - /YYYY/
  - /YYYY/MM/
- Comment paging
  - /{post_or_page_slug}/comment-page-{n}/

## Content model cấp trường (để clone lại hành vi site)
- Post (Bài viết)
  - fields (core)
    - id (string/int)
    - title (string)
    - slug (string; url-encoded khi hiển thị URL)
    - content_html (rich text)
    - excerpt (string; dùng cho list page)
    - published_at (date)
    - updated_at (date, optional)
    - comment_status (open/closed)
    - comment_count (int)
  - fields (series/metadata – đề xuất parse từ title/format)
    - series_key (string, optional) --- ví dụ: 开示解答来信疑惑 / 精彩感言摘录 / 佛学问答 / …
    - series_number (int, optional) --- ví dụ: 六百九十六 / 一千一百七十九
    - source_event_date (date, optional) --- ví dụ: “开示于2015年7月27日”
    - source_event_place (string, optional) --- ví dụ: 新加坡/香港/印尼…
  - relations
    - categories[] -> Category
    - tags[] -> Tag
    - prev_post / next_post -> Post (optional)

- Page (Trang tĩnh / hub / download / guide)
  - fields
    - id
    - title
    - slug
    - template_type (enum: hub_list | download_hub | guide | gallery | guestbook_index | generic)
    - content_html (có thể chứa shortcode)
    - sections[] (optional, nếu tách cấu trúc)
      - heading
      - links[] (LinkItem)
    - comment_status (open/closed)
    - comment_count
  - relations
    - curated_posts[] -> Post (optional, nếu chuyển từ list link sang relation)

- Category (taxonomy)
  - fields
    - id
    - name
    - slug
    - parent_id (optional)
    - description (optional)
    - post_count
  - relations
    - children[] -> Category

- Tag (taxonomy)
  - fields
    - id
    - name
    - slug
    - post_count

- Comment
  - fields
    - id
    - target_type (post|page)
    - target_id
    - parent_comment_id (optional)
    - author_name
    - author_email (optional/required tuỳ chính sách)
    - author_url (optional)
    - content_html
    - created_at (datetime)
    - status (approved|pending|spam|trash)
  - relations
    - replies[] -> Comment

- GuestbookMonth (có thể là Page specialized)
  - fields
    - id
    - title (ví dụ “留言板（2025年10月）”)
    - year (int)
    - month (int)
    - slug (pattern: 留言板YYYYMM hoặc 留言板YYYYMM-上/下)
    - comment_status
    - comment_count
    - prev_month_slug / next_month_slug (optional)
  - relations
    - comments[] -> Comment

- DownloadItem (đề xuất hoá cấu trúc link)
  - fields
    - id
    - title
    - url
    - host_domain
    - file_type (zip|pdf|mp3|mp4|html|unknown)
    - grouping (year|series|book|template|general)
    - notes (optional) --- ví dụ “持续更新”“更新”“只限北美使用”
  - relations
    - belongs_to_page -> Page

## FE templates (block-by-block)
- GlobalLayout (mọi trang)
  - Header: logo/title + Menu đa cấp
  - MainContent (theo template)
  - Sidebar:
    - SearchForm + category dropdown
    - 分类目录 (quick links tới hub pages)
    - 文章存档 (dropdown tháng/năm)
    - 最新评论
    - Download blocks (书籍和资料下载 / 视频下载 / 节目录音下载 ...)
    - QR/erweima
  - Footer: copyright + tracker (nếu có)

- ListPage template (Home / Category / Tag / Date archive)
  - PageTitle (nếu có)
  - PostCardList
    - PostCard: title, date_line, excerpt, read_more, comment_count
  - Pagination: /page/{n}/

- HubPage template (礼佛常识 / 白话佛法 / 玄艺综述 / …)
  - PageTitle
  - SectionList (headings)
  - CuratedLinkList
  - (Optional) “Back/Prev/Next” nội bộ

- PostDetail template
  - Title
  - Published date (có thể hiển thị thêm updated date)
  - Content body (Q&A, headings, quotes…)
  - Prev/Next post nav
  - Comments
    - CommentForm (name/email/url/content)
    - CommentList (threaded)
    - CommentPaging: /comment-page-{n}/

- DownloadHub template (jingwe / 音频下载 / 视频下载 / 书籍下载)
  - PageTitle
  - DownloadSections
    - group_title
    - link list (external/internal)
  - (Optional) chú thích “持续更新/更新/合集”

- GuestbookIndex template (/留言板/ + /以往的留言/)
  - Current month link
  - History directory
  - (Nếu /留言板/ có comment): comment thread + paging

- Gallery template (/相本/)
  - GalleryEmbedRenderer (shortcode → gallery)
  - Fallback: hiển thị “gallery unavailable” nếu không load được nguồn

## BE admin workflow/permissions (mẫu để triển khai clone)
- Roles
  - Admin: full access + cấu hình site/sidebar/widgets
  - Editor: CRUD Post/Page + publish + taxonomy
  - Moderator: quản lý Comment/Guestbook + reply official + spam control
  - Contributor: create draft Post/Page, không publish
- Workflows
  - Post/Page: Draft → Review → Publish → Update (ghi updated_at)
  - Taxonomy: tạo category/tag (hỗ trợ parent-child)
  - Comment:
    - Default: pending hoặc approved (tuỳ policy)
    - Tools: approve/reject/spam, khóa bình luận theo trang
    - Paging: bảo đảm query theo created_at
  - GuestbookMonth:
    - Tạo page theo tháng (slug chuẩn)
    - Đặt comment_status=open
    - Link prev/next tháng
  - External downloads:
    - Quản lý link theo nhóm + thử link healthcheck định kỳ
    - Gắn nhãn “持续更新/更新/new”
```

## Content types và data model

Bảng dưới đây gom các **content types chính** (đủ để tái tạo sitemap + hành vi FE/BE của site). Các field “series_* / source_*” là **đề xuất chuẩn hoá** để implement sạch; chúng phản ánh pattern tiêu đề/số thứ tự/ngày nguồn xuất hiện dày đặc trên site. citeturn27view0turn26view4turn31search0turn39view1turn21view0

| Content type | Slug / URL pattern | Fields (kiểu; bắt buộc/tuỳ chọn) | Relations chính |
|---|---|---|---|
| Post (Bài viết) | `/<post-slug>/` | `id` (string/int; bắt buộc), `title` (string; bắt buộc), `slug` (string; bắt buộc), `content_html` (richtext; bắt buộc), `excerpt` (string; tuỳ chọn), `published_at` (date; bắt buộc), `updated_at` (date; tuỳ chọn), `comment_status` (enum open/closed; tuỳ chọn), `comment_count` (int; tuỳ chọn), `series_key` (string; tuỳ chọn), `series_number` (int; tuỳ chọn), `source_event_date` (date; tuỳ chọn) | `categories[]`, `tags[]`, `prev_post`, `next_post`, `comments[]` citeturn27view0turn26view1 |
| Page (Trang tĩnh/hub) | `/<page-slug>/` hoặc slug ASCII như `/jingwe/` | `id` (bắt buộc), `title` (bắt buộc), `slug` (bắt buộc), `template_type` (enum; bắt buộc), `content_html` (tuỳ chọn nếu tách sections), `sections[]` (tuỳ chọn), `comment_status`/`comment_count` (tuỳ chọn) | `curated_posts[]` (tuỳ chọn), `download_items[]` (tuỳ chọn), `comments[]` (tuỳ chọn) citeturn42view0turn13view7turn37view0turn38view0turn39view3 |
| Category (Taxonomy) | `/category/<slug>/` + `/page/n/` | `id` (bắt buộc), `name` (bắt buộc), `slug` (bắt buộc), `parent_id` (tuỳ chọn), `description` (tuỳ chọn), `post_count` (tuỳ chọn) | `posts[]`, `children[]` citeturn25search2turn26view4turn37view5 |
| Tag (Taxonomy) | `/tag/<slug>/page/n/` | `id` (bắt buộc), `name` (bắt buộc), `slug` (bắt buộc), `post_count` (tuỳ chọn) | `posts[]` citeturn31search0turn32search4 |
| ArchiveTime (Năm/Tháng) | `/YYYY/`, `/YYYY/MM/` | `year` (int; bắt buộc), `month` (int; tuỳ chọn), `page` (int; tuỳ chọn) | `posts[]` citeturn32search6turn32search9 |
| Comment (Bình luận) | `/comment-page-n/` (paging) | `id` (bắt buộc), `target_type` (post/page; bắt buộc), `target_id` (bắt buộc), `parent_comment_id` (tuỳ chọn), `author_name` (string; bắt buộc), `author_email` (string; không xác định bắt buộc hay không), `author_url` (string; tuỳ chọn), `content_html` (bắt buộc), `created_at` (datetime; bắt buộc), `status` (enum; bắt buộc) | `replies[]` citeturn27view0turn36view0turn35view1 |
| GuestbookMonth (留言板 theo tháng) | `/留言板YYYYMM/` và trong directory `/以往的留言/` | `id` (bắt buộc), `title` (bắt buộc), `year`/`month` (int; bắt buộc), `slug` (bắt buộc), `comment_status` (bắt buộc), `comment_count` (tuỳ chọn), `prev_month`/`next_month` (tuỳ chọn) | `comments[]` citeturn21view0turn20view2 |
| DownloadItem (liên kết tải) | Thường là external URL từ các hub pages | `id` (bắt buộc), `title` (bắt buộc), `url` (bắt buộc), `host_domain` (bắt buộc), `file_type` (tuỳ chọn), `grouping` (tuỳ chọn), `notes` (tuỳ chọn) | `belongs_to_page` citeturn13view7turn37view0turn13view9turn20view1 |

## API contract mẫu

Lưu ý: site gốc **không công bố** API trong các trang quan sát; phần dưới là **API contract mẫu** để dev dựng FE/BE theo sitemap và content model đã phân tích. Các endpoint được thiết kế để support đúng các pattern `page/`, `category/tag archives`, `comment-page-n`, và các hub pages. citeturn26view4turn31search0turn36view0turn37view0turn21view0

| Content type | Endpoint | Method | Query params chính | Response shape (JSON Schema rút gọn) |
|---|---|---|---|---|
| Post | `/api/posts` | GET | `page`, `per_page`, `sort` (`published_at`/`updated_at`), `order`, `category`, `tag`, `year`, `month`, `q` | `{"type":"object","required":["data","meta"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/Post"}},"meta":{"$ref":"#/definitions/PaginationMeta"}}}` |
| Post | `/api/posts/{id_or_slug}` | GET | `include` (ví dụ: `comments_summary`) | `{"type":"object","required":["data"],"properties":{"data":{"$ref":"#/definitions/PostDetail"},"meta":{"$ref":"#/definitions/Meta"}}}` |
| Page | `/api/pages` | GET | `template_type`, `slug`, `page`, `per_page` | `{"type":"object","required":["data","meta"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/Page"}},"meta":{"$ref":"#/definitions/PaginationMeta"}}}` |
| Page | `/api/pages/{id_or_slug}` | GET | `include` (ví dụ: `sections,download_items`) | `{"type":"object","required":["data"],"properties":{"data":{"$ref":"#/definitions/PageDetail"},"meta":{"$ref":"#/definitions/Meta"}}}` |
| Category | `/api/categories` | GET | `parent_id`, `tree` (bool), `q` | `{"type":"object","required":["data"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/Category"}}}}` |
| Tag | `/api/tags` | GET | `q`, `page`, `per_page` | `{"type":"object","required":["data","meta"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/Tag"}},"meta":{"$ref":"#/definitions/PaginationMeta"}}}` |
| ArchiveTime | `/api/archives` | GET | `year`, `month`, `page`, `per_page` | `{"type":"object","required":["data","meta"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/Post"}},"meta":{"$ref":"#/definitions/PaginationMeta"}}}` |
| Comment | `/api/comments` | GET | `target_type`, `target_id`, `page` (comment-page), `per_page`, `order` | `{"type":"object","required":["data","meta"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/Comment"}},"meta":{"$ref":"#/definitions/PaginationMeta"}}}` |
| Comment | `/api/comments` | POST | body: `target_type`, `target_id`, `author_name`, `author_email`, `author_url`, `content`, `parent_comment_id` | `{"type":"object","required":["data"],"properties":{"data":{"$ref":"#/definitions/CommentCreateResult"},"meta":{"$ref":"#/definitions/Meta"}}}` |
| GuestbookMonth | `/api/guestbook-months` | GET | `year`, `month`, `page`, `per_page` | `{"type":"object","required":["data","meta"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/GuestbookMonth"}},"meta":{"$ref":"#/definitions/PaginationMeta"}}}` |
| DownloadItem | `/api/download-items` | GET | `page_slug`, `grouping`, `year`, `q` | `{"type":"object","required":["data"],"properties":{"data":{"type":"array","items":{"$ref":"#/definitions/DownloadItem"}}}}` |

JSON Schema definitions (đủ để FE/BE code, có thể chuyển thành OpenAPI nếu cần):

```json
{
  "definitions": {
    "Meta": {
      "type": "object",
      "properties": {
        "generated_at": { "type": "string", "format": "date-time" }
      }
    },
    "PaginationMeta": {
      "type": "object",
      "required": ["page", "per_page"],
      "properties": {
        "page": { "type": "integer", "minimum": 1 },
        "per_page": { "type": "integer", "minimum": 1 },
        "total_items": { "type": "integer", "minimum": 0 },
        "total_pages": { "type": "integer", "minimum": 0 },
        "has_next": { "type": "boolean" },
        "has_prev": { "type": "boolean" }
      }
    },
    "Category": {
      "type": "object",
      "required": ["id", "name", "slug"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "name": { "type": "string" },
        "slug": { "type": "string" },
        "parent_id": { "type": ["string", "integer", "null"] },
        "description": { "type": ["string", "null"] },
        "post_count": { "type": ["integer", "null"] }
      }
    },
    "Tag": {
      "type": "object",
      "required": ["id", "name", "slug"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "name": { "type": "string" },
        "slug": { "type": "string" },
        "post_count": { "type": ["integer", "null"] }
      }
    },
    "Post": {
      "type": "object",
      "required": ["id", "title", "slug", "published_at"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "title": { "type": "string" },
        "slug": { "type": "string" },
        "excerpt": { "type": ["string", "null"] },
        "published_at": { "type": "string", "format": "date" },
        "updated_at": { "type": ["string", "null"], "format": "date" },
        "comment_status": { "type": ["string", "null"], "enum": ["open", "closed", null] },
        "comment_count": { "type": ["integer", "null"], "minimum": 0 },
        "series_key": { "type": ["string", "null"] },
        "series_number": { "type": ["integer", "null"] },
        "source_event_date": { "type": ["string", "null"], "format": "date" },
        "categories": { "type": "array", "items": { "$ref": "#/definitions/Category" } },
        "tags": { "type": "array", "items": { "$ref": "#/definitions/Tag" } }
      }
    },
    "PostDetail": {
      "allOf": [
        { "$ref": "#/definitions/Post" },
        {
          "type": "object",
          "required": ["content_html"],
          "properties": {
            "content_html": { "type": "string" },
            "prev_post": { "anyOf": [{ "$ref": "#/definitions/Post" }, { "type": "null" }] },
            "next_post": { "anyOf": [{ "$ref": "#/definitions/Post" }, { "type": "null" }] }
          }
        }
      ]
    },
    "Page": {
      "type": "object",
      "required": ["id", "title", "slug", "template_type"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "title": { "type": "string" },
        "slug": { "type": "string" },
        "template_type": {
          "type": "string",
          "enum": ["hub_list", "download_hub", "guide", "gallery", "guestbook_index", "generic"]
        },
        "comment_status": { "type": ["string", "null"], "enum": ["open", "closed", null] },
        "comment_count": { "type": ["integer", "null"] }
      }
    },
    "PageDetail": {
      "allOf": [
        { "$ref": "#/definitions/Page" },
        {
          "type": "object",
          "properties": {
            "content_html": { "type": ["string", "null"] },
            "sections": {
              "type": "array",
              "items": {
                "type": "object",
                "required": ["heading", "links"],
                "properties": {
                  "heading": { "type": "string" },
                  "links": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "required": ["title", "url"],
                      "properties": {
                        "title": { "type": "string" },
                        "url": { "type": "string" },
                        "kind": { "type": ["string", "null"], "enum": ["internal", "external", null] }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ]
    },
    "Comment": {
      "type": "object",
      "required": ["id", "target_type", "target_id", "author_name", "content_html", "created_at", "status"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "target_type": { "type": "string", "enum": ["post", "page"] },
        "target_id": { "type": ["string", "integer"] },
        "parent_comment_id": { "type": ["string", "integer", "null"] },
        "author_name": { "type": "string" },
        "author_email": { "type": ["string", "null"], "format": "email" },
        "author_url": { "type": ["string", "null"] },
        "content_html": { "type": "string" },
        "created_at": { "type": "string", "format": "date-time" },
        "status": { "type": "string", "enum": ["approved", "pending", "spam", "trash"] }
      }
    },
    "CommentCreateResult": {
      "type": "object",
      "required": ["comment_id", "status"],
      "properties": {
        "comment_id": { "type": ["string", "integer"] },
        "status": { "type": "string", "enum": ["approved", "pending"] },
        "message": { "type": ["string", "null"] }
      }
    },
    "GuestbookMonth": {
      "type": "object",
      "required": ["id", "title", "year", "month", "slug", "comment_status"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "title": { "type": "string" },
        "year": { "type": "integer" },
        "month": { "type": "integer", "minimum": 1, "maximum": 12 },
        "slug": { "type": "string" },
        "comment_status": { "type": "string", "enum": ["open", "closed"] },
        "comment_count": { "type": ["integer", "null"] },
        "prev_month_slug": { "type": ["string", "null"] },
        "next_month_slug": { "type": ["string", "null"] }
      }
    },
    "DownloadItem": {
      "type": "object",
      "required": ["id", "title", "url", "host_domain"],
      "properties": {
        "id": { "type": ["string", "integer"] },
        "title": { "type": "string" },
        "url": { "type": "string" },
        "host_domain": { "type": "string" },
        "file_type": { "type": ["string", "null"] },
        "grouping": { "type": ["string", "null"] },
        "notes": { "type": ["string", "null"] }
      }
    }
  }
}
```

## Ví dụ trang chi tiết

Các ví dụ dưới đây chọn đúng “shape” đã quan sát trên site: một bài series dạng Q&A, một download hub, và một bài “feedback/testimonial”. citeturn27view0turn37view0turn41view0

Ví dụ bài giảng series dạng Q&A (PostDetail)

- URL pattern: `/<post-slug>/` (slug URL-encode), ví dụ bài “开示解答来信疑惑（…）” hiển thị ngày đăng `YYYY-MM-DD`. citeturn27view0  
- FE wireframe (block order):
  - Header menu
  - Title (H1)
  - Published date (1 dòng)
  - Content body (thường cấu trúc theo “问/答” + ghi chú)
  - Prev/Next links (nút điều hướng sang bài trước/sau)
  - Comments
    - Form: 名称 / 电子邮箱地址 / 网站地址 + textarea
    - CommentList (threaded)
    - Reply action (“回复”) trên từng comment
  - Sidebar/global widgets (download links + QR, v.v.)
- Required API calls (mẫu):
  - `GET /api/posts/{slug}` (include content_html + prev/next + comment_status)
  - `GET /api/comments?target_type=post&target_id={id}&page=1&per_page=...`
  - (khi user reply) `POST /api/comments` body `{target_type, target_id, parent_comment_id, author_name, author_email, author_url, content}`  
- Chi tiết hành vi comment cần replicate:
  - Comment có timestamp dạng “YYYY年M月D日 周X HH:MM”. citeturn27view0
  - Có thể có comment paging theo `comment-page-n` nếu nhiều comment. citeturn36view0

Ví dụ trang download audio (DownloadHub)

- URL pattern: `/音频下载/`  
- FE wireframe:
  - Header menu
  - Title
  - Section: “节目录音每年分类下载（可按日期下载）”
    - Mỗi năm: link “全年打包下载” (external) + link “按日期分类下载” (internal/hub)
  - (Dưới/Sidebar) các block tài liệu và link tải khác (经文、样板、合集…)
- Required API calls (mẫu):
  - `GET /api/pages/{slug=音频下载}` (include sections + download_items)
  - (Nếu “按日期分类下载” là page nội bộ) `GET /api/pages/{slug=...}`  
- Điểm kỹ thuật:
  - Có các gói năm từ 2008-2009 trở đi và link trỏ sang hosting ngoài như `download.richardxl.xyz`. citeturn37view0

Ví dụ testimonial/feedback (PostDetail dạng chia sẻ)

- URL pattern: `/<post-slug>/` (thường tiêu đề chứa “——心灵法门网友反馈”) citeturn41view0  
- FE wireframe:
  - Header menu
  - Title
  - Published/Updated date (nếu có)
  - Content body (thường dài; có heading phụ kiểu “分享一/分享二” hoặc các tiêu đề con)
  - (Optional) Related posts theo cùng category/tag
  - Comments (mở/đóng tuỳ bài)
- Required API calls (mẫu):
  - `GET /api/posts/{slug}`
  - `GET /api/comments?...` (nếu comment_status=open)
- Ghi chú:
  - Dạng bài “feedback” có thể chứa nhiều đoạn chia sẻ và nhiều heading con trong 1 post. citeturn41view0

## Patterns cần crawl và ưu tiên nguồn

Các pattern dưới đây được sắp theo mức ưu tiên “nguồn gốc/chính thống trên site”, ưu tiên các index/hub giúp khám phá phần lớn URL mà không cần sitemap.xml. citeturn42view0turn21view0turn25search5turn31search0turn4search2turn5view3

Nguồn ưu tiên cao trên site

- robots.txt: kiểm tra allow/disallow và crawl-delay. robots.txt của site cho phép đa số bot với user-agent `*` (disallow `/cgi-bin/`) và nêu crawl-delay 20. citeturn4search2  
- sitemap.xml / sitemap_index.xml:
  - `/sitemap.xml` không fetch được trong kiểm tra (lỗi). citeturn5view2  
  - `/sitemap_index.xml` trả 404. citeturn5view3  
  ⇒ Nếu viết crawler, cần fallback sang các hub/menu/category/tag/date archives.
- Trang chủ `/` và phân trang `/page/{n}/`: crawl list page để lấy link bài mới và phát hiện taxonomy/widgets. citeturn1view3turn2view0  
- Các hub pages trong menu (rất giàu link nội bộ):
  - `/礼佛常识/`, `/白话佛法/`, `/玄艺综述/`, `/玄艺问答/`, `/佛学问答/`, `/精彩专题/`, `/弟子开示/`, `/佛言佛语/`, `/网友反馈/`, `/评论回复/`, `/听众感悟/`, `/最新通知/`. citeturn42view0turn12view1turn12view3turn12view5turn12view7turn14view7turn14view1turn14view4turn16view6turn13view4turn16view0turn17view0  
- Download hubs:
  - `/jingwe/`, `/音频下载/`, `/视频下载/`, `/书籍下载/` (đồng thời lưu lại các external host domains). citeturn13view7turn37view0turn13view9turn13view10  
- Guestbook:
  - `/留言板/` (entry), `/以往的留言/` (directory), các trang tháng (`/留言板YYYYMM/`, có cả “-上/-下”). citeturn19view0turn21view0turn21view3turn20view2  
- Trang hướng dẫn nhập môn:
  - `/初学者须知/` (nhiều link sang bài và tài liệu; có lịch chương trình theo giờ Sydney và quy đổi DST). citeturn38view0  

Patterns archive để crawl toàn bộ bài theo taxonomy và thời gian

- Category archives:
  - `/category/<slug>/`
  - `/category/<slug>/page/<n>/` (quan trọng để lấy “đuôi” của kho bài). citeturn25search5turn25search7turn26view4  
  - Lưu ý hierarchy: có thể là `/category/<parent>/<child>/` cho subcategory theo năm (ví dụ nhánh 网友反馈). citeturn25search2  
- Tag archives:
  - `/tag/<slug>/page/<n>/`. citeturn31search0turn31search1  
- Time archives:
  - `/YYYY/`
  - `/YYYY/MM/` citeturn32search6turn32search9  

Comment-related patterns

- Comment paging: `/<post-or-page>/comment-page-<n>/` (cần crawl nếu muốn đủ lịch sử bình luận, ví dụ những trang có hàng nghìn comment). citeturn36view0turn39view1  
- Trạng thái comment:
  - Có trang đóng bình luận (“评论已关闭”) nhưng vẫn có comment paging để đọc lịch sử. citeturn35view1turn36view0  
  - Có trang mở bình luận với form và “回复” cho thread. citeturn27view0turn20view2  
- Endpoint submit comment: **không xác định** từ bản trích xuất text (không thấy form action); khi implement clone nên thiết kế endpoint POST riêng (như phần API mẫu).

Media hosting và rủi ro kỹ thuật khi crawl

- External hosting xuất hiện dày đặc:
  - `jmp.sh` (tài liệu kinh/biểu mẫu) citeturn13view7turn37view2  
  - `download.richardxl.xyz` (audio/video/book bundles) citeturn37view0turn13view9turn12view8  
  - `riccharddlujunhong.info` (book bundles/nhạc) citeturn13view10turn16view3  
  - `mastervideoinfo.com` (video/feature links) citeturn34view2turn22view2  
  - `files.chant-info.xyz` (một số link zip; có trường hợp 502/không đọc được content-type zip trong tool) citeturn20view0turn20view1  
- Một số URL có thể bị anti-bot/challenge (“One moment, please…”), crawler cần cơ chế retry/throttling và tuân thủ robots/crawl-delay. citeturn27view1turn4search2