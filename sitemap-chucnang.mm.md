---
title: "Lujunhong VN Clone - Markmap Chi Tiết Theo Từng Trang (Quy trình FE/BE/Admin)"
markmap:
  colorFreezeLevel: 2
---

## Quy ước chung

- FE (Next.js App Router)
  - Trang phía Server: lấy dữ liệu + SEO
  - Giao diện phía Client: lọc/tìm kiếm/biểu mẫu + cập nhật lạc quan (optimistic update)
- BE (Strapi v5 + Postgres)
  - Truy cập công khai: blog/hướng dẫn/phương tiện/sự kiện (tùy chỉnh)
  - Yêu cầu xác thực: hồ sơ/nhật ký tu tập/cộng đồng/kế hoạch niệm kinh
- Chuẩn dữ liệu
  - Slug chuẩn VN (không dấu) + tính duy nhất (unique)
  - Document ID (Strapi v5): FE luôn lưu cả { documentId, id } nếu cần
  - Ảnh/phương tiện: dùng trình tải lên/cung cấp của Strapi
- Kiểm duyệt (Moderation)
  - Nội dung công khai: biên tập (bản nháp/đã xuất bản)
  - Nội dung người dùng: chờ duyệt/đã duyệt/rác (bình luận cộng đồng, bài đăng cộng đồng nếu cần)

## / (Trang chủ)

- Dữ liệu cần có (BE)
  - Cài đặt (setting): cấu hình các thành phần trang chủ (homeSections)
  - Sự kiện (events): danh sách ghim + sắp tới
  - Sự kiện âm lịch (lunar-event): sắp tới (7-30 ngày)
  - Bài viết blog (blog-post): nổi bật + mới nhất
  - Video/radio/thư viện (videos/radio/library): mới nhất (tùy chọn)
- Giao diện bố cục (FE)
  - Ảnh bìa (Hero) + Nút kêu gọi (CTA): Niệm Kinh / Lịch Âm / Đăng nhập
  - Thành phần: Sự kiện & Thông báo (events)
  - Thành phần: Lịch khóa lễ sắp tới (lunar)
  - Thành phần: Bài viết nổi bật (blog featured)
  - Thành phần: Mới cập nhật (blog/phương tiện)
- Quy trình quản trị
  - Quản trị viên chọn bài viết nổi bật (flag hoặc quan hệ)
  - Quản trị viên ghim sự kiện (pinned)
  - Quản trị viên chỉnh thứ tự các khối thông qua setting.homeSections

## /auth (Đăng nhập/Đăng ký)

- Dữ liệu cần có (BE)
  - Người dùng + nhà cung cấp xác thực (JWT/phiên)
  - Cài đặt: các tùy chọn xác thực (tùy chọn)
- Giao diện bố cục (FE)
  - Các thẻ: Đăng nhập / Đăng ký
  - Đăng nhập mạng xã hội (tùy chọn)
  - Quên mật khẩu (tùy chọn)
- Quy trình quản trị
  - Vai trò/quyền hạn: đăng ký/đăng nhập công khai
  - Giới hạn tần suất (Rate limit) + mã xác thực (captcha) (tùy chọn)

## /profile (Hồ sơ)

- Dữ liệu cần có (BE)
  - Các trường thông tin hồ sơ người dùng
  - Nhật ký tu tập (practice-log): theo người dùng
  - Kế hoạch niệm kinh (chant-plan): theo người dùng
- Giao diện bố cục (FE)
  - Tóm tắt hồ sơ
  - Các thẻ:
    - Nhật ký tu tập
    - Kế hoạch niệm kinh
    - Cài đặt cá nhân
- Quy trình quản trị
  - Người dùng tự chỉnh sửa các trường hồ sơ (trong danh sách cho phép)
  - Nhật ký kiểm soát (Audit logs - tùy chọn)

## /profile (Nhật ký tu tập - Practice Logs)

- Các trường dữ liệu (practice-log)
  - Người dùng (quan hệ)
  - Ngày dương lịch (dateGregorian)
  - Khóa ngày âm lịch (lunarDateKey - chuỗi YYYY-MM-DD âm hoặc khóa chuỗi)
  - Các mục nhập[] (thành phần)
    - Bài niệm kinh (quan hệ)
    - Số lượng
    - Ghi chú
  - Tâm trạng/điểm số (tùy chọn)
- Giao diện bố cục (FE)
  - Danh sách kiểu lịch theo tuần/tháng
  - Biểu mẫu thêm/sửa theo ngày
  - Thêm nhanh: +1 / +3 / +7
- Quy trình quản trị
  - Không cần duyệt (riêng tư)
  - Giữ lại/xuất dữ liệu (tùy chọn)

## /niem-kinh (Niệm kinh)

- Dữ liệu cần có (BE)
  - Bài niệm kinh (chant-item)
    - Tiêu đề, slug, ngôn ngữ (vi/zh), văn bản (rich/markdown)
    - Đường dẫn âm thanh (tùy chọn), thứ tự, là bài kinh cốt lõi (isCore)
  - Kế hoạch niệm kinh (chant-plan)
    - Người dùng, tên, ngày bắt đầu, ngày kết thúc (tùy chọn)
    - Các mục kế hoạch[]: bài niệm kinh + số lượng mục tiêu + lịch trình (quy tắc)
  - Ghi đè niệm kinh theo sự kiện âm lịch (lunar-event-chant-override)
    - Người dùng, sự kiện âm lịch (quan hệ), khóa ngày (dateKey)
    - Các mục ghi đè[]: bài niệm kinh + số lượng mục tiêu ghi đè
- Giao diện bố cục (FE)
  - Thẻ 1: Thư viện kinh
    - Danh sách bài niệm kinh (tìm kiếm + lọc)
    - Chi tiết: văn bản + trình phát + cỡ chữ + chế độ tối + đánh dấu
  - Thẻ 2: Kế hoạch
    - Tạo/sửa kế hoạch
    - Tiến độ hôm nay
  - Thẻ 3: Hôm nay (theo âm lịch)
    - Gợi ý kinh theo sự kiện âm lịch + ghi đè
- Quy trình quản trị
  - Quản trị viên quản lý bài niệm kinh (biên tập)
  - Người dùng quản lý kế hoạch/ghi đè (riêng tư)
  - Cài đặt: gợi ý kinh mặc định theo sự kiện âm lịch

## /lunar-calendar (Lịch âm)

- Các trường dữ liệu (lunar-event)
  - Tiêu đề, slug
  - Quy tắc âm lịch (ví dụ: mùng 1, rằm, lễ đặc biệt)
  - Khoảng ngày (tùy chọn)
  - Mô tả
  - Gợi ý tụng niệm[] (bài kinh + số lượng khuyến nghị)
- Giao diện bố cục (FE)
  - Chế độ xem lịch (tháng)
  - Danh sách các sự kiện sắp tới
  - Chi tiết sự kiện: mô tả + gợi ý tụng niệm
- Quy trình quản trị
  - Quản trị viên tạo sự kiện âm lịch + quy tắc
  - Quản trị viên cập nhật gợi ý tụng niệm
  - Nhập/khởi tạo dữ liệu âm lịch (script/cron, tùy chọn)

## /beginner-guide (Hướng dẫn sơ học)

- Các trường dữ liệu
  - Hướng dẫn sơ học (beginner-guide)
    - Tiêu đề, slug, nội dung, thứ tự
    - Các phần[] (thành phần): tiêu đề + nội dung + liên kết/tệp
  - Tệp hướng dẫn (beginner-guide-file)
    - Tiêu đề, tệp/phương tiện, loại (pdf/doc/audio), thứ tự
- Giao diện bố cục (FE)
  - Mục lục ở thanh bên (Sidebar)
  - Bảng nội dung
  - Tải xuống tệp đính kèm
- Quy trình quản trị
  - Xem xét biên tập: bản nháp -> đã xuất bản
  - Lịch sử phiên bản (tùy chọn): giữ các bản sửa đổi cũ

## /blog

- Các trường dữ liệu
  - Bài viết blog (blog-post)
    - Tiêu đề, slug, mô tả ngắn, nội dung
    - Ngày xuất bản, nổi bật, ảnh đại diện
    - Danh mục (nhiều-nhiều), thẻ (nhiều-nhiều)
    - Đường dẫn nguồn (tùy chọn)
  - Thẻ blog: tên, slug
  - Danh mục: tên, slug, cha (tùy chọn), thứ tự, nhóm trình đơn
- Giao diện bố cục (FE)
  - Danh sách + phân trang
  - Lọc: danh mục, thẻ, từ khóa tìm kiếm
  - Dải bài viết nổi bật
- Quy trình quản trị
  - Bản nháp -> xem xét -> xuất bản
  - Đặt bài viết nổi bật + ghim (tùy chọn)
  - Tự động tạo mô tả ngắn + kiểm tra tính duy nhất của slug

## /category/:slug (Danh mục)

- Dữ liệu cần có
  - Danh mục theo slug
  - Bài viết blog được lọc theo danh mục
- Giao diện bố cục (FE)
  - Tiêu đề danh mục (tên/mô tả)
  - Danh sách bài viết + phân trang
  - Các danh mục con (nếu có)
- Quy trình quản trị
  - Quản trị viên quản lý phân loại: thứ tự + cấp cha

## /blog/:slug (Chi tiết bài viết)

- Dữ liệu cần có
  - Bài viết blog theo slug
  - Các bài viết liên quan (cùng danh mục/thẻ)
  - Bài trước/sau (theo ngày xuất bản trong cùng danh mục, tùy chọn)
- Giao diện bố cục (FE)
  - Tiêu đề + ngày + thời gian đọc (tùy chọn)
  - Mục lục (tự động từ các tiêu đề)
  - Bài liên quan + bài trước/sau
  - (Nếu cho phép bình luận blog) mô-đun bình luận (tùy chọn)
- Quy trình quản trị
  - Danh mục kiểm tra SEO: tiêu đề/mô tả meta
  - Chế độ xem trước (tùy chọn)

## /videos (Video)

- Các trường dữ liệu
  - Mục video (video-item)
    - Tiêu đề, slug, mô tả
    - Đường dẫn video (youtube/vimeo/tệp)
    - Ảnh đại diện, thời lượng, ngày xuất bản
    - Danh mục/thẻ (tùy chọn)
- Giao diện bố cục (FE)
  - Lưới các thẻ video + lọc/tìm kiếm
  - Trang chi tiết: trình phát + nội dung liên quan
- Quy trình quản trị
  - Thêm đường dẫn video + kiểm tra tính hợp lệ nhúng
  - Tuyển chọn danh sách phát/loạt video (tùy chọn)

## /radio

- Các trường dữ liệu
  - Mục radio (radio-item)
    - Tiêu đề, slug, đường dẫn âm thanh/tệp
    - Mô tả, thời lượng, ngày xuất bản
    - Loạt chương trình, số tập (tùy chọn)
- Giao diện bố cục (FE)
  - Danh sách + trình phát thu nhỏ
  - Chi tiết: trình phát + bản ghi văn bản (tùy chọn)
- Quy trình quản trị
  - Tải lên âm thanh + tự động lấy thời lượng (tùy chọn)

## /library (Thư viện)

- Các trường dữ liệu
  - Mục thư viện (library-item)
    - Tiêu đề, slug
    - Loại: pdf/epub/doc
    - Tệp/đường dẫn
    - Ảnh bìa, mô tả, ngày xuất bản
- Giao diện bố cục (FE)
  - Lưới + lọc theo loại
  - Chi tiết + tải xuống
- Quy trình quản trị
  - Quét virus (tùy chọn) + giới hạn kích thước tệp

## /events (Sự kiện)

- Các trường dữ liệu
  - Sự kiện (event)
    - Tiêu đề, slug, nội dung
    - Thời điểm bắt đầu, kết thúc, địa điểm, người tổ chức
    - Được ghim, ngày xuất bản
- Giao diện bố cục (FE)
  - Danh sách sự kiện sắp tới + lưu trữ sự kiện cũ
  - Chi tiết: dòng thời gian + thêm vào lịch (ics)
- Quy trình quản trị
  - Ghim sự kiện
  - Tự động chuyển sang mục lưu trữ sau ngày kết thúc

## /testimonials & /shares (Cảm nhận & Chia sẻ)

- Các trường dữ liệu
  - Cảm nhận/chia sẻ (tùy tách hay chung)
    - Tiêu đề, slug
    - Nội dung
    - Tên tác giả (tùy chọn)
    - Trạng thái: chờ duyệt/đã duyệt/đã xuất bản (nếu người dùng gửi)
- Giao diện bố cục (FE)
  - Danh sách + các danh mục (nếu có)
  - Chi tiết: định dạng câu chuyện
  - Nút hành động: “Chia sẻ trải nghiệm” (nếu mở)
- Quy trình quản trị
  - Nếu người dùng gửi: chờ duyệt -> duyệt -> xuất bản
  - Nếu biên tập: bản nháp -> xuất bản

## /directory (Danh bạ)

- Các trường dữ liệu
  - Mục danh bạ (directory-entry)
    - Tên, vai trò
    - Vùng/thành phố
    - Các phương thức liên hệ (điện thoại/email/zalo) (tùy chọn)
    - Chế độ hiển thị (công khai/riêng tư)
- Giao diện bố cục (FE)
  - Tìm kiếm theo vùng
  - Danh sách dạng thẻ
- Quy trình quản trị
  - Quyền hạn: có thể chỉ người dùng đã đăng nhập mới xem được
  - Ẩn thông tin liên hệ theo vai trò (tùy chọn)

## /donations (Ủng hộ)

- Các trường dữ liệu
  - Chiến dịch ủng hộ (donation-campaign)
    - Tiêu đề, slug, mô tả
    - Thông tin thanh toán (ngân hàng/QR), miễn trừ trách nhiệm
    - Trạng thái kích hoạt/ngưng hoạt động
- Giao diện bố cục (FE)
  - Thông tin chiến dịch
  - Mã QR + sao chép thông tin ngân hàng
  - Những câu hỏi thường gặp (FAQ)
- Quy trình quản trị
  - Cập nhật thông tin thanh toán qua cài đặt (có kiểm soát)
  - Bật/tắt chiến dịch

## /community (Cộng đồng)

- Các trường dữ liệu
  - Bài đăng cộng đồng (community-post)
    - Người dùng, tiêu đề, nội dung
    - Trạng thái: chờ duyệt/đã duyệt/rác
    - Ngày tạo
    - Các chỉ số: số lượt thích (tùy chọn)
  - Bình luận cộng đồng (community-comment)
    - Bài đăng, người dùng, nội dung
    - Trạng thái: chờ duyệt/đã duyệt/rác
- Giao diện bố cục (FE)
  - Luồng bài viết: mới nhất / xu hướng
  - Tạo bài viết (phải đăng nhập)
  - Chi tiết bài viết + bình luận
  - Nút báo cáo
- Quy trình quản trị
  - Hàng đợi kiểm duyệt: chờ duyệt -> duyệt/từ chối/rác
  - Quy tắc chống rác tự động: số lượng liên kết, từ cấm, giới hạn tần suất
  - Chặn/đình chỉ người dùng (tùy chọn)

## Tổng quát (quan trọng)

- Tìm kiếm toàn trang
  - Blog + phương tiện + hướng dẫn
  - FE: /search?q=
  - BE: điểm cuối tìm kiếm thống nhất hoặc truy vấn từng mô-đun
- SEO & lập chỉ mục
  - Tự động tạo sitemap.xml
  - robots.txt
  - Đường dẫn chuẩn (canonical) cho các trang chi tiết
- Ma trận phân quyền
  - Danh cho khách: đọc blog/phương tiện/hướng dẫn/sự kiện
  - Người dùng đã đăng nhập: nhật ký tu tập, kế hoạch niệm kinh, ghi đè, tạo bài đăng cộng đồng
  - Quản trị viên: toàn quyền + kiểm duyệt
- Tính nhất quán dữ liệu (Strapi v5 docId)
  - FE lưu trữ: documentId là chính
  - Các bộ chuyển đổi API: ánh xạ thống nhất { documentId <-> id }
