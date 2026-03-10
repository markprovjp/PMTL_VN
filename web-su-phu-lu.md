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