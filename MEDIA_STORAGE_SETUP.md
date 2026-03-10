# Cấu hình Media Storage cho Production

## Hiện tại (Dev)
Strapi lưu file upload vào `BE_PMTL/public/uploads/` — **KHÔNG dùng cho production**.

---

## Lựa chọn 1: Cloudflare R2 (Khuyến nghị — miễn phí 10GB/tháng)

### 1. Cài plugin
```bash
cd BE_PMTL
npm install @strapi/provider-upload-aws-s3
```
R2 tương thích S3 API — dùng provider `aws-s3` với endpoint R2.

### 2. Cấu hình `BE_PMTL/config/plugins.ts`
```typescript
export default ({ env }) => ({
  upload: {
    config: {
      provider: 'aws-s3',
      providerOptions: {
        s3Options: {
          credentials: {
            accessKeyId: env('R2_ACCESS_KEY_ID'),
            secretAccessKey: env('R2_SECRET_ACCESS_KEY'),
          },
          region: 'auto',
          endpoint: env('R2_ENDPOINT'), // https://<account_id>.r2.cloudflarestorage.com
          forcePathStyle: true,
        },
        params: {
          Bucket: env('R2_BUCKET_NAME'),
        },
        baseUrl: env('R2_PUBLIC_URL'), // https://cdn.phapmontamlinh.vn
      },
    },
  },
})
```

### 3. Biến môi trường BE (`BE_PMTL/.env`)
```env
R2_ACCESS_KEY_ID=<lấy từ Cloudflare dashboard>
R2_SECRET_ACCESS_KEY=<lấy từ Cloudflare dashboard>
R2_ENDPOINT=https://<account_id>.r2.cloudflarestorage.com
R2_BUCKET_NAME=pmtl-media
R2_PUBLIC_URL=https://cdn.phapmontamlinh.vn
```

### 4. Cập nhật `fe-pmtl/next.config.mjs`
Uncomment dòng R2 trong `images.remotePatterns`:
```js
{ protocol: 'https', hostname: 'cdn.phapmontamlinh.vn', pathname: '/**' },
```

---

## Lựa chọn 2: Cloudinary (Miễn phí 25 credit/tháng, có transform ảnh)

### 1. Cài plugin
```bash
cd BE_PMTL
npm install @strapi/provider-upload-cloudinary
```

### 2. Cấu hình `BE_PMTL/config/plugins.ts`
```typescript
export default ({ env }) => ({
  upload: {
    config: {
      provider: 'cloudinary',
      providerOptions: {
        cloud_name: env('CLOUDINARY_NAME'),
        api_key: env('CLOUDINARY_KEY'),
        api_secret: env('CLOUDINARY_SECRET'),
      },
      actionOptions: {
        upload: {},
        delete: {},
      },
    },
  },
})
```

### 3. Biến môi trường BE
```env
CLOUDINARY_NAME=<cloud name>
CLOUDINARY_KEY=<api key>
CLOUDINARY_SECRET=<api secret>
```

### 4. Cập nhật `fe-pmtl/next.config.mjs`
```js
{ protocol: 'https', hostname: 'res.cloudinary.com', pathname: '/**' },
```

---

## Lựa chọn 3: AWS S3 (Có phí)

```bash
npm install @strapi/provider-upload-aws-s3
```

```typescript
// config/plugins.ts
export default ({ env }) => ({
  upload: {
    config: {
      provider: 'aws-s3',
      providerOptions: {
        s3Options: {
          credentials: {
            accessKeyId: env('AWS_ACCESS_KEY_ID'),
            secretAccessKey: env('AWS_ACCESS_SECRET'),
          },
          region: env('AWS_REGION', 'ap-southeast-1'),
          params: {
            Bucket: env('AWS_BUCKET'),
          },
        },
      },
    },
  },
})
```

---

## Lưu ý quan trọng

- Sau khi cấu hình provider mới, **toàn bộ file upload cũ** vẫn ở local.
  Cần migrate thủ công hoặc dùng script để copy lên CDN.
- Kiểm tra `middleware.ts` của Strapi: cần tăng `maxFileSize` nếu upload file PDF lớn.
- Các URL file trong DB Strapi sẽ tự động trỏ về CDN sau khi đổi provider.
- Backup bucket thường xuyên.
