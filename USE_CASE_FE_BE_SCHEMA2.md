# PMTL_VN - USE CASE TOAN BO FE DEN BE VA SCHEMA LOGIC

## 1. Muc tieu tai lieu

Tai lieu nay dung de chot nghiep vu cho du an PMTL_VN o muc san pham va ky thuat.

Muc tieu cua tai lieu nay la:
- Xac dinh ro he thong dang cung cap nhung gia tri nao cho nguoi dung.
- Liet ke day du actor, vai tro, quyen va pham vi thao tac.
- Map tung man hinh FE sang route handler Next.js va sang Strapi BE.
- Chot schema hien co va schema con thieu de du an full FE den BE.
- Lam tai lieu nen cho backlog, API contract, ERD va phan quyen admin sau nay.

Tai lieu nay tach thanh 2 lop:
- Lop 1 la hien trang da co trong code.
- Lop 2 la phan de xuat can bo sung de khop voi toan bo giao dien FE hien tai.

## 2. Tong quan san pham

PMTL_VN la cong thong tin va cong dong Phat phap, tap trung vao 4 truc gia tri:
- Noi dung va tri thuc: blog, huong dan so hoc, tai lieu, hub tong hop.
- Thuc hanh ca nhan: niem kinh hang ngay, lich am, practice log, nhac nho push.
- Tuong tac cong dong: chia se, binh luan, guestbook.
- Nhan dien va tai khoan: auth, profile, avatar, phan quyen, moderation.

Cac cum nghiep vu chinh cua san pham:
- Public content.
- Community va moderation.
- Identity va personal practice.
- CMS va system configuration.

## 3. Actors va quyen

### 3.1 Khach
- Xem trang chu, blog, archive, category, beginner guide, lunar calendar, events, library, hub, shares, guestbook.
- Gui blog comment neu bai cho comment.
- Gui community post, community comment, guestbook entry tren cac endpoint cong khai.
- Dang ky tai khoan hoac dang nhap.

### 3.2 Thanh vien da dang nhap
- Co tat ca quyen cua Khach.
- Quan ly profile va avatar.
- Luu practice log theo ngay.
- Dong bo tien do niem kinh vao tai khoan.
- Gui noi dung cong dong kem lien ket user.

### 3.3 Moderator
- Duyet va publish blog comment.
- Duyet va publish community post va community comment.
- Duyet guestbook entry pending sang approved.
- Khoa comment hoac an noi dung nhay cam qua Strapi Admin.

### 3.4 Content editor
- Quan ly blog post, category, blog tag, beginner guide, event, download item, hub page, homepage settings, sidebar config, chant data.
- Sap xep noi dung noi bat, menu, hero, featured video, curated post.

### 3.5 He thong
- Tinh ngay am lich va merge bai niem hom nay.
- Tang view va like theo rule server.
- Rate limit submit cong khai.
- Gui push notification va revalidate cache.
- Bao ve session bang httpOnly cookie.

## 4. Danh sach module va tinh trang

### 4.1 Module da co E2E trong code
- Trang chu.
- Blog va category.
- Blog archive va blog series.
- Blog comments.
- Beginner guide.
- Lunar calendar.
- Niem kinh hang ngay.
- Practice log.
- Events.
- Library downloads.
- Hub pages.
- Shares va community.
- Guestbook.
- Auth local va Google OAuth.
- Profile va avatar.
- Push subscription.
- Sidebar config.

### 4.2 Module da co FE nhung BE chua day du
- Videos.
- Radio.
- Directory.
- Donations.

### 4.3 Module da co mot phan
- Search: FE va helper da co, backend dua vao Meilisearch va indexing plugin.

## 5. Kien truc tong the FE den BE

Luong xu ly tong quat cua du an hien tai nhu sau:
- Nguoi dung thao tac tren man hinh FE cua Next.js App Router.
- FE co 2 cach lay du lieu: server component goi lib api hoac client goi app api route handler.
- app api route handler dong vai tro BFF nho, doc cookie, bo sung auth header, format lai request hoac tinh them du lieu nhu ngay am lich.
- Strapi BE la nguon su that cho content, moderation, auth, media va custom business logic.
- SQLite hoac PostgreSQL la tang luu tru du lieu cua Strapi.

Nguyen tac map lop:
- FE page la noi hien thi use case.
- lib api va app api la gateway hop dong ky thuat.
- Strapi content type va controller la noi chot business rule.

## 6. Use case chi tiet theo tung cum nghiep vu

### 6.1 Cum Public Content

#### UC-PC-01 Xem trang chu
- Actor: Khach.
- Muc dich: xem tong quan website, noi dung noi bat, loi dan huong chinh.
- FE lien quan: app page, HeaderServer, HeroSection, PhaoBaoSection, ActionCards, ContentFeeds, StickyBanner.
- BFF va helper: lib api homepage.
- BE lien quan: single type setting.
- Du lieu dau vao: heroSlides, stats, phapBao, actionCards, featuredVideos, awards, gallerySlides, stickyBanner.
- Luong chinh: FE request setting, BE tra setting, FE render theo layout trang chu.
- Ngoai le: neu CMS rong thi FE dung fallback constants de trang chu van render duoc.
- Du lieu ghi: khong co.

#### UC-PC-02 Xem danh sach blog
- Actor: Khach.
- Muc dich: doc danh sach bai viet, loc theo category hoac tag, phan trang.
- FE lien quan: slash blog, BlogListClient, BlogPagination, CategoryNav.
- BFF va helper: lib api blog, categories, blog-tags neu can.
- BE lien quan: blog-post, category, blog-tag.
- Luong chinh: FE lay list blog-post published, populate category, tag, thumbnail, sau do client filter va phan trang tiep.
- Rule: chi lay published, khong expose draft cho FE cong khai.
- Du lieu ghi: khong co.

#### UC-PC-03 Xem chi tiet blog
- Actor: Khach.
- Muc dich: doc noi dung day du cua bai viet va noi dung lien quan.
- FE lien quan: slash blog slug, ShareButtons, SeriesNav, ViewTracker, CommentsSection.
- BFF va helper: lib api blog, series, blogComments.
- BE lien quan: blog-post va custom controller incrementView, series.
- Luong chinh: FE lay bai theo slug, render content, goi view tracker sau khi vao bai, hien series neu co seriesKey, hien comments neu allowComments.
- Rule: view chi tang 1 lan tren moi IP va moi bai trong 1 gio. Bai chi tiet chi lay published.
- Du lieu ghi: tang views o blog-post qua raw SQL atomic increment.

#### UC-PC-04 Xem archive blog
- Actor: Khach.
- Muc dich: duyet bai viet theo nam va thang.
- FE lien quan: slash archive, slash archive year month.
- BFF va helper: lib api archive.
- BE lien quan: custom endpoint archiveIndex va archive trong blog-post controller.
- Luong chinh: FE lay index nam thang co bai, sau do lay list bai cua thang duoc chon.
- Rule: backend gom theo publishedAt va phan trang ket qua.
- Du lieu ghi: khong co.

#### UC-PC-05 Xem category page
- Actor: Khach.
- Muc dich: doc bai viet theo chuyen muc.
- FE lien quan: slash category slug.
- BE lien quan: category self relation va relation category den blog-post.
- Rule: category co parent va children de tao category tree.

#### UC-PC-06 Xem beginner guide
- Actor: Khach, Editor.
- Muc dich: hoc lo trinh so hoc va tai tai lieu huong dan.
- FE lien quan: slash beginner-guide va cac component client ben trong.
- BE lien quan: beginner-guide content type.
- Luong chinh: FE lay danh sach huong dan, sap xep theo step_number va order, render content va attached_files.
- Rule: guide_type phan biet so-hoc va kinh-bai-tap.

#### UC-PC-07 Xem lunar calendar
- Actor: Khach, Editor.
- Muc dich: xem ngay le va su kien am lich lien quan den viec tu hoc.
- FE lien quan: slash lunar-calendar.
- BFF va helper: lib api lunar-calendar.
- BE lien quan: lunar-event va relation relatedBlogs.
- Luong chinh: FE lay list lunar-event, hien lich thang va noi dung lien quan.
- Rule: su kien co the la recurring theo am lich hoac chi dinh solarDate. eventType duoc dung cho rule uu tien nghiep vu niem kinh.

#### UC-PC-08 Xem events
- Actor: Khach, Editor.
- Muc dich: theo doi su kien, phap hoi, khoa tu, livestream.
- FE lien quan: slash events va slash events slug.
- BFF va helper: lib api event.
- BE lien quan: event content type.
- Luong chinh: FE lay events published va render theo eventStatus.
- Rule: event luu type, eventStatus, date, location, speaker, coverImage, gallery, files.

#### UC-PC-09 Xem library downloads
- Actor: Khach, Editor.
- Muc dich: tai kinh sach, audio, video, tep huong dan.
- FE lien quan: slash library va LibraryClient.
- BFF va helper: lib api downloads.
- BE lien quan: download-item content type.
- Luong chinh: FE lay list download-item, loc theo fileType va category, cho phep mo link tai xuong.
- Rule: url co the tro toi Google Drive, CDN hoac internal path. groupYear, groupLabel, sortOrder phuc vu nhom hien thi.

#### UC-PC-10 Xem hub page tong hop
- Actor: Khach, Editor.
- Muc dich: gom cac bai viet, tai lieu, rich text thanh mot landing page theo chu de.
- FE lien quan: slash hub slug, HubPageComponent, HubBlockRenderer.
- BFF va helper: lib api hub.
- BE lien quan: hub-page content type.
- Luong chinh: FE lay hub-page theo slug, render sections va dynamic blocks.
- Rule: hub-page co curated_posts, downloads, visualTheme, showInMenu, menuIcon, dynamic zone blocks.

### 6.2 Cum Community va Moderation

#### UC-CM-01 Gui blog comment
- Actor: Khach hoac Thanh vien.
- Muc dich: dong gop y kien vao bai viet.
- FE lien quan: CommentForm, CommentsClient, CommentsSection, app api blog-comments submit.
- BE lien quan: blog-comment controller custom submit.
- Tien dieu kien: phai co postSlug hop le va bai dang cho phep comment.
- Luong chinh: FE gui form len app api, route handler chuyen qua Strapi, Strapi validate bang Zod, strip HTML, tao blog-comment moi o draft.
- Rule: rate limit 1 phut moi IP. reply dung parentDocumentId. Neu user dang nhap thi co the lien ket user.
- Du lieu ghi: blog-comment moi.

#### UC-CM-02 Like blog comment
- Actor: Khach hoac Thanh vien.
- Muc dich: tang muc tuong tac cua binh luan.
- FE lien quan: nut like trong comment item.
- BE lien quan: custom route like tren blog-comment.
- Rule: chi like comment published. Tang like bang atomic increment.

#### UC-CM-03 Xem blog comments theo bai
- Actor: Khach.
- Muc dich: doc thao luan ben duoi bai viet.
- BE lien quan: by-post route trong blog-comment controller.
- Rule: backend tra ve thread da sap xep, top level co phan trang, replies gan vao parent.

#### UC-CM-04 Gui community post
- Actor: Khach hoac Thanh vien.
- Muc dich: chia se cau chuyen, phan hoi, video cong dong.
- FE lien quan: slash shares, form submit community post, app api community-posts submit.
- BE lien quan: community-post controller createPost.
- Luong chinh: FE gui title, content, type, category, author snapshot, tags, media. BE strip HTML, set likes va views bang 0, neu co user dang nhap thi lien ket user, luu o draft.
- Rule: rate limit 5 phut moi IP. Noi dung khong len cong khai ngay, phai qua moderation.
- Du lieu ghi: community-post moi o draft.

#### UC-CM-05 Xem community post va comments
- Actor: Khach.
- Muc dich: doc bai chia se cong dong va comment lien quan.
- FE lien quan: shares list va bai chi tiet.
- BE lien quan: community-post find va findOne da override de tranh vong lap populate, va fetch comments thu cong.
- Rule: chi hien bai published. Comments cung chi lay published.

#### UC-CM-06 Like va view community post
- Actor: Khach hoac Thanh vien.
- Muc dich: tang tuong tac tren bai cong dong.
- BE lien quan: custom route like va incrementView trong community-post controller.
- Rule: chi thao tac tren bai published. Tang bang atomic increment.

#### UC-CM-07 Gui community comment
- Actor: Khach hoac Thanh vien.
- Muc dich: phan hoi duoi bai cong dong.
- FE lien quan: app api community-comments submit.
- BE lien quan: community-comment createComment.
- Luong chinh: FE gui postDocumentId, content, author_name, co the co parentDocumentId. BE check post ton tai, strip HTML, tao comment draft.
- Rule: rate limit 1 phut moi IP. Co nested relation parent va replies.

#### UC-CM-08 Gui guestbook entry
- Actor: Khach.
- Muc dich: de lai loi nhan hoac cau hoi cho website.
- FE lien quan: GuestbookForm, GuestbookList, archive pages, app api guestbook submit va list.
- BE lien quan: guestbook-entry submit, list, archive, archiveList.
- Luong chinh: FE gui authorName, country, message, entryType. BE strip HTML, luu pending, moderator duyet sau.
- Rule: rate limit 2 phut moi IP. guestbook-entry khong dung draft/publish ma dung approvalStatus pending va approved.
- Du lieu ghi: guestbook-entry moi voi approvalStatus pending.

### 6.3 Cum Identity va Personal Practice

#### UC-ID-01 Dang ky tai khoan local
- Actor: Khach.
- FE lien quan: slash auth tab register, app api auth register.
- BE lien quan: Strapi auth local register, user schema mo rong.
- Luong chinh: FE gui username, email, password toi app api, route handler goi Strapi auth local register, nhan JWT, set auth_token httpOnly cookie, tra thong tin user cho client.
- Rule: JWT khong luu localStorage. Cookie co SameSite lax va thoi han 7 ngay.

#### UC-ID-02 Dang nhap local
- Actor: Khach.
- FE lien quan: slash auth tab login, app api auth login.
- BE lien quan: Strapi auth local.
- Luong chinh: FE gui email va password, route handler doi sang identifier cua Strapi, nhan JWT, set cookie, AuthContext cap nhat user.

#### UC-ID-03 Dang nhap Google
- Actor: Khach.
- FE lien quan: nut dang nhap Google, slash auth google callback, app api auth google-callback.
- BE lien quan: provider Google trong users-permissions va file config Google.
- Luong chinh: user di qua flow OAuth cua Google, callback tra JWT Strapi, Next route set auth_token cookie va redirect ve FE.

#### UC-ID-04 Phuc hoi session va bao ve route
- Actor: Thanh vien.
- FE lien quan: AuthContext, middleware, app api auth me, logout.
- Luong chinh: middleware check auth_token ton tai tren slash profile, AuthContext goi auth me de xac minh token that su hop le voi Strapi, neu token hong thi xoa cookie.
- Rule: middleware la lop chan nhanh. auth me la lop xac minh that.

#### UC-ID-05 Cap nhat profile va avatar
- Actor: Thanh vien.
- FE lien quan: slash profile, app api user update, app api user avatar.
- BE lien quan: user schema mo rong trong users-permissions.
- Luong chinh: user sua fullName, dharmaName, phone, address, bio. FE goi update route, route handler dung JWT cookie de proxy den Strapi. Avatar upload qua endpoint upload roi gan media vao user.
- Rule: user chi sua field whitelist. avatar_url la media field.

#### UC-PR-01 Xem bai niem hom nay
- Actor: Khach hoac Thanh vien.
- FE lien quan: slash niem-kinh, app api today-chant, ChantingRunner.
- BE lien quan: chant-plan controller getTodayChant.
- Luong chinh: FE xac dinh ngay theo Asia Bangkok, tinh lunarMonth va lunarDay, goi Strapi aggregator, nhan ve list item can niem trong ngay.
- Rule merge quan trong: base plan la nguon goc. lunar-event-chant-override co 4 mode la enable, disable, override_target, cap_max. Uu tien event la holiday lon nhat, normal nho nhat.

#### UC-PR-02 Luu practice log
- Actor: Thanh vien.
- FE lien quan: app api practice-log GET va PUT.
- BE lien quan: practice-log controller findMyLog va upsertMyLog.
- Luong chinh: FE gui date, planSlug va itemsProgress. BE tim plan theo slug, tim log theo user + date + plan. Neu da co thi update, neu chua co thi create moi.
- Rule: isCompleted bat len khi tat ca item done. completedAt chi set khi da xong het. startedAt set o lan tao dau tien.
- Du lieu ghi: practice-log.

#### UC-PR-03 Dang ky push notification
- Actor: Thanh vien hoac nguoi dung cai PWA.
- FE lien quan: nut push, app api push subscribe va send.
- BE lien quan: push-subscription content type.
- Luong chinh: browser cap subscription, FE gui len backend, backend luu lai de he thong co the gui nhac sau do.
- Rule: endpoint send can secret rieng.

## 7. Schema logic hien co theo domain

### 7.1 Noi dung
- blog-post: content type trung tam cho bai viet. Chua title, slug, content, excerpt, thumbnail, gallery, video_url, audio_url, featured, views, unique_views, likes, seo, related_posts, lunarEvents, seriesKey, seriesNumber, sourceName, sourceUrl, sourceTitle, allowComments, commentCount, eventDate, location.
- category: chuyen muc co name, slug, color, order, is_active va self relation parent children.
- blog-tag: nhom the cho blog-post.
- beginner-guide: huong dan so hoc va bai tap hang ngay. Chua title, description, content, details, duration, order, step_number, guide_type, icon, pdf_url, video_url, images, attached_files.
- event: su kien voi title, slug, description, content, date, timeString, location, type, eventStatus, speaker, language, link, youtubeId, coverImage, gallery, files.
- download-item: title, description, url, fileType, category, groupYear, groupLabel, notes, isUpdating, isNew, sortOrder, thumbnail, fileSizeMB.
- hub-page: title, slug, description, coverImage, sections, curated_posts, downloads, sortOrder, showInMenu, menuIcon, visualTheme, blocks.

### 7.2 Cong dong
- blog-comment: relation toi post, user, parent. Field authorName, authorAvatar, userId, content, likes, isOfficialReply, badge, ipHash.
- community-post: title, slug, content, type, category, cover_image, video_url, author_name, author_avatar, author_country, user, likes, views, comments, tags, rating, pinned.
- community-comment: content, author_name, author_avatar, user, post, likes, parent, replies.
- guestbook-entry: authorName, country, avatar, message, adminReply, approvalStatus, isOfficialReply, badge, year, month, entryType, questionCategory, isAnswered.

### 7.3 Niem kinh va thuc hanh
- chant-item: title, slug, kind, content, openingPrayer, timeRules, recommendedPresets, audio.
- chant-plan: title, slug, planType, planItems.
- lunar-event: title, isRecurringLunar, lunarMonth, lunarDay, solarDate, eventType, relatedBlogs.
- lunar-event-chant-override: lunarEvent, item, mode, target, max, priority, note.
- practice-log: user, plan, date, itemsProgress, startedAt, completedAt, isCompleted.

### 7.4 Tai khoan va system config
- user mo rong: username, email, provider, confirmed, blocked, role, fullName, avatar_url, phone, address, bio, dharmaName.
- setting single type: siteTitle, siteDescription, logo, socialLinks, contactEmail, contactPhone, address, footerText, heroSlides, stats, phapBao, actionCards, featuredVideos, awards, gallerySlides, stickyBanner.
- sidebar-config single type: showSearch, showCategoryTree, showArchive, showLatestComments, showDownloadLinks, downloadLinks, socialLinks, qrImages.

## 8. Rule nghiep vu va state machine can chot

### 8.1 Moderation state
- blog-post, blog-comment, community-post, community-comment, event, beginner-guide, download-item, hub-page, chant-item, chant-plan, lunar-event, lunar-event-chant-override dung Draft va Publish cua Strapi.
- guestbook-entry dung enum approvalStatus gom pending va approved.

### 8.2 Rate limit va anti spam hien co
- Blog comment submit: 1 phut moi IP.
- Community comment submit: 1 phut moi IP.
- Community post submit: 5 phut moi IP.
- Guestbook submit: 2 phut moi IP.
- Blog view: 1 lan moi IP moi bai trong 1 gio.

### 8.3 Access control hien co
- Noi dung cong khai chi doc published hoac approved.
- Practice log chi user dang nhap cua chinh no moi duoc doc ghi.
- Profile va avatar chi thao tac qua cookie auth_token.
- Push send can secret rieng.

## 9. Ban do API contract o muc nghiep vu

- Auth local: app api auth login, register, me, logout map sang Strapi auth va users me.
- Auth Google: app api auth google-callback map sang provider Google cua Strapi.
- User profile: app api user update va avatar map sang update user va upload media.
- Blog comments: submit, by-post, latest, like.
- Community: community-posts submit, like, view, findOne va community-comments submit, like.
- Guestbook: submit, list, archive, archive-list.
- Niem kinh: app api today-chant map sang chant-plans today-chant.
- Practice log: app api practice-log map sang practice-logs my.
- Revalidate: app api revalidate theo tag va secret.
- Push: subscribe va send.

## 10. Khoang trong can bo sung de full voi FE hien tai

### 10.1 Videos
Hien tai slash videos la du lieu hardcode trong FE, chua co content type rieng. Neu muon day du FE den BE thi nen bo sung:
- Content type video-item.
- Field de xuat: title, slug, titleCn, description, youtubeId, category, duration, viewsLabel, publishedAt, featured, thumbnail, sortOrder.
- API can co: list videos, find one by slug, filter by category, featured videos.
- Use case editor: tao video, doi thu tu, an hien, gan featured.

### 10.2 Radio
Hien tai slash radio la hardcode. Nen bo sung:
- Content type radio-episode cho tung bai audio hoac tap phat thanh.
- Single type radio-config cho luong live, hotline, platformLinks, stats, hot topics.
- Field radio-episode de xuat: title, slug, description, audioUrl, category, duration, listenerCount, publishedAt, tags, isFeatured.
- Use case editor: cap nhat live stream, danh sach bai hot, chu de hot tuan nay.

### 10.3 Directory
Hien tai slash directory la hardcode. Nen bo sung:
- Content type directory-region.
- Content type directory-entry relation toi directory-region.
- Field de xuat: name, address, phone, hours, country, city, mapUrl, isFeatured, visibility, sortOrder.
- Use case editor: quan ly Quang Am Duong theo quoc gia va khu vuc, cap nhat gio mo cua va lien he.

### 10.4 Donations
Hien tai slash donations la static content. Nen bo sung:
- Single type donation-config.
- Components cho expense categories, transparency items, faq items, support items, volunteer items.
- Field de xuat: heroTitle, heroBody, zaloUrl, importantNotice, expenseCategories, transparencyItems, donationSupportItems, faqItems, volunteerItems.
- Luu y nghiep vu: neu website giu nguyen tac khong nhan tien thi khong can payment transaction schema, chi can CMS content schema.

## 11. Schema de xuat de bo sung

### 11.1 video-item
- title, slug, titleCn, description, youtubeId, category, duration, viewsLabel, publishedAt, featured, thumbnail, seo.

### 11.2 radio-episode
- title, slug, description, audioUrl, platform, category, duration, listenerCount, publishedAt, tags, isFeatured, transcript.

### 11.3 radio-config
- liveStreamUrl, hotline, heroTitle, heroDescription, externalPlatformLinks, stats, hotTopics.

### 11.4 directory-region va directory-entry
- directory-region: name, slug, sortOrder.
- directory-entry: region, name, address, phone, hours, country, city, mapUrl, isFeatured, visibility, notes.

### 11.5 donation-config
- heroTitle, heroBody, zaloUrl, importantNotice, transparencyItems, expenseCategories, supportItems, faqItems, volunteerItems.

## 12. Thu tu implement de hop ly

Giai doan 1 nen chot:
- Actors va quyen.
- Moderation states.
- API contract cho cac module da co.
- Chuan documentId va relation rules Strapi v5.

Giai doan 2 nen bo sung:
- video-item.
- radio-episode va radio-config.
- directory-region va directory-entry.
- donation-config.

Giai doan 3 nen chot tiep:
- OpenAPI hoac bang contract FE BE.
- ERD chi tiet.
- Backlog tung story cho FE, BE, Admin.
- Phan quyen Public, Authenticated, Moderator, Editor, Super Admin.

## 13. Ket luan

- Hien trang du an da co xuong song san pham kha ro cho noi dung, cong dong, niem kinh va tai khoan.
- Phan thieu lon nhat de goi la full FE den BE nam o 4 module static cua FE la videos, radio, directory va donations.
- Neu muon di tiep dung thu tu, tai lieu nay nen duoc dung lam ban chot nghiep vu goc, sau do tach ra thanh ERD va backlog implement.
- Cum du lieu trung tam cua he thong hien nay la blog-post, community-post, community-comment, guestbook-entry, chant-item, chant-plan, lunar-event, practice-log, user, setting va sidebar-config.
