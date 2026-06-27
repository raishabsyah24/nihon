# Agent Handoff - Nihon e Ikitai

Dokumen ini adalah ringkasan cepat untuk agent berikutnya yang akan melanjutkan project `Nihon e Ikitai`.

## Ringkasan Project

`Nihon e Ikitai` adalah learning center bahasa Jepang dengan tiga aplikasi utama:

- `mobile/`: aplikasi Flutter untuk user.
- `admin/`: web admin Next.js untuk mengelola konten, paket, order, promo, voucher, dan user.
- `backend/`: API NestJS + Prisma untuk data dinamis, auth Firebase, role, commerce, progress, dan akses konten berbayar.

Backend memakai database MySQL-compatible. Saat ini production memakai TiDB Cloud dan deploy backend/admin di Vercel.

## Prinsip Produk

- Kana dan Kotoba adalah fitur gratis untuk semua user.
- Produk yang dijual:
  - Materi JFT.
  - Soal JFT.
  - Materi JLPT.
  - Soal JLPT.
  - Soal SSW.
- Beranda mobile hanya preview semua menu.
- Tab Belajar menampilkan progress belajar, Kana/Kotoba/SSW, dan materi JFT/JLPT yang sudah dibeli.
- Tab Ujian menampilkan soal JFT/JLPT/SSW yang sudah dibeli.
- Tab Info menampilkan berita Jepang dan countdown jadwal ujian pilihan user.
- Tab Profil untuk edit profile, ganti password via Firebase reset email, nomor HP, alamat, loyalty point, dan progress.

## Status Terakhir

Phase 1 sampai Phase 10 sudah dikerjakan.

Yang baru selesai di Phase 8 sampai Phase 10:

- Backend punya model `StudyMaterial` untuk materi JFT/JLPT.
- Admin punya menu `Materi JFT/JLPT`.
- Mobile bisa membuka materi JFT/JLPT dari paket yang dibeli.
- Seed sudah berisi materi JFT A1, A2, B1, B2 dan JLPT N5 sampai N1.
- Seed sudah berisi question set nyata untuk JFT A1, A2, B1, B2 dan JLPT N5 sampai N1.
- Placeholder paket soal JLPT N3/N2/N1 sudah diganti ke question set nyata.
- Mobile Profile punya `Riwayat Order`, layar semua order, dan detail order dengan status, ringkasan pembayaran, item paket, serta catatan kapan paket terbuka.
- User sudah menjalankan:

```powershell
npx prisma migrate deploy
npm run seed
```

Jadi database production/TiDB seharusnya sudah terisi sampai Phase 9.

## Kondisi Git

Working tree saat dokumen ini dibuat masih banyak perubahan dan file baru yang belum dicommit. Agent berikutnya wajib mulai dengan:

```powershell
git status --short
```

Jangan melakukan `git reset`, `git checkout --`, atau revert file tanpa izin user.

File/folder penting yang baru atau berubah:

- `backend/prisma/schema.prisma`
- `backend/prisma/seed.ts`
- `backend/prisma/migrations/20260626010000_commerce_foundation/`
- `backend/prisma/migrations/20260626030000_study_materials/`
- `backend/src/content/commerce.controller.ts`
- `backend/src/content/commerce.service.ts`
- `backend/src/content/study-materials.controller.ts`
- `admin/src/components/packages-page.tsx`
- `admin/src/components/orders-page.tsx`
- `admin/src/components/promotions-page.tsx`
- `admin/src/app/packages/`
- `admin/src/app/orders/`
- `admin/src/app/promotions/`
- `admin/src/app/study-materials/`
- `mobile/lib/src/ui/packages/package_screens.dart`
- `mobile/lib/src/ui/home/home_screen.dart`
- `mobile/lib/src/ui/auth/profile_screen.dart`
- `mobile/lib/src/services/api_client.dart`
- `mobile/lib/src/models/app_models.dart`

## Arsitektur Backend

Stack:

- NestJS
- Prisma
- MySQL/TiDB
- Firebase Admin SDK untuk verifikasi ID token

Script penting:

```powershell
cd backend
npm run build
npx prisma validate
npx prisma migrate deploy
npm run seed
npm run admin:promote -- --firebaseUid=<uid> --email=<email> --displayName="<name>"
```

Catatan:

- Untuk development lokal, `npm run prisma:migrate` memakai `prisma migrate dev`.
- Untuk production/Vercel/TiDB, gunakan `npx prisma migrate deploy`.
- Jangan commit isi `.env`.
- Jika schema atau seed berubah, setelah deploy minta user menjalankan:

```powershell
cd D:\Project\nihon\backend
npx prisma migrate deploy
npm run seed
```

Endpoint penting:

- `GET /health`
- `GET /catalog/home`
- `GET /packages`
- `GET /me/packages/:idOrSlug`
- `GET /me/entitlements`
- `GET /me/progress`
- `POST /me/progress`
- `GET /me/profile`
- `PATCH /me/profile`
- `POST /orders`
- `GET /me/orders`
- `GET /me/exam-schedule`
- `POST /me/exam-schedule`
- `GET /study-materials/:idOrSlug`
- `GET /me/study-materials/:idOrSlug`
- `GET /me/jft/question-sets/:id`
- `GET /me/jlpt/question-sets/:id`
- `GET /me/ssw/modules/:id`
- Admin CRUD routes: `/admin/packages`, `/admin/orders`, `/admin/promos`, `/admin/vouchers`, `/admin/study-materials`, `/admin/kotoba`, `/admin/jft`, `/admin/jlpt`, `/admin/ssw`, `/admin/exam-schedules`, `/admin/japan-news`, `/admin/users`.

## Database dan Konten

Database harus memakai charset/collation UTF-8 penuh:

```sql
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
```

Seed sengaja berisi teks Jepang. PowerShell kadang menampilkan huruf Jepang sebagai mojibake seperti `ã...`, tetapi byte file sebenarnya UTF-8. Jangan ubah encoding file seed sembarangan.

Konten seed saat ini mencakup:

- Kana hiragana/katakana dasar, dakuten, handakuten.
- Kotoba awal.
- SSW category/module/soal awal.
- JFT question set A1, A2, B1, B2.
- JLPT question set N5, N4, N3, N2, N1.
- Materi JFT/JLPT.
- Paket jualan dan package contents.
- Promo/voucher/loyalty/order foundation.
- Jadwal ujian contoh dan berita Jepang contoh.

## Auth dan Role

Auth memakai Firebase:

- Mobile: email/password dan Google.
- Admin web: email/password dan Google.
- Phone OTP sedang tidak dipakai di UI terbaru.

Backend melakukan:

1. Verifikasi Firebase ID token.
2. Sinkron user lokal berdasarkan `firebaseUid`.
3. Role guard untuk admin.

Jika admin login tapi tidak bisa masuk dashboard:

1. Cek user di Firebase Authentication.
2. Cek row `User` di database dengan `firebaseUid` yang sama.
3. Pastikan `role = 'ADMIN'`.
4. Pastikan backend env Firebase Admin sudah benar.

Contoh query TiDB:

```sql
USE nihon_e_ikitai;

SELECT id, firebaseUid, email, displayName, role
FROM `User`
WHERE email = 'email-admin@example.com';
```

## Env Production

Jangan masukkan secret asli ke dokumen atau commit.

Backend Vercel env minimal:

```txt
DATABASE_URL=
FIREBASE_SERVICE_ACCOUNT_JSON=
```

Alternatif Firebase Admin:

```txt
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
```

Admin Vercel env minimal:

```txt
NEXT_PUBLIC_API_BASE_URL=
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
```

Mobile:

- Firebase config ada di `mobile/lib/firebase_options.dart`.
- Android config ada di `mobile/android/app/google-services.json`.
- API base URL ada di `mobile/lib/src/config/app_config.dart`.
- Build APK production sebaiknya eksplisit:

```powershell
cd mobile
flutter build apk --release --dart-define=API_BASE_URL=https://<backend-vercel-url> --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>
```

Default saat dokumen ini dibuat masih mengarah ke `https://nihon-phi.vercel.app`. Verifikasi selalu dengan:

```txt
https://<backend-url>/health
```

## Admin Web

Stack:

- Next.js
- Firebase Web SDK
- lucide-react

Script:

```powershell
cd admin
npm run build
npm run lint
```

Catatan:

- Halaman resource yang memakai `ResourcePage` harus menjadi Client Component dengan `"use client"`.
- Menu admin ada di `admin/src/components/admin-shell.tsx`.
- Config resource CRUD ada di `admin/src/lib/resources.ts`.
- Form paket khusus ada di `admin/src/components/packages-page.tsx`.
- Form order ada di `admin/src/components/orders-page.tsx`.
- Form promo/voucher ada di `admin/src/components/promotions-page.tsx`.

## Mobile App

Stack:

- Flutter
- Firebase Auth
- Google Sign-In
- HTTP API client

Script umum:

```powershell
cd mobile
flutter pub get
flutter analyze
flutter build apk --debug
```

Catatan penting:

- `flutter analyze` dan `dart format` pernah timeout karena proses Dart lama menggantung di Windows. Jika terjadi lagi, jangan langsung anggap error kode. Cek proses `dart` di Task Manager atau dengan PowerShell, lalu minta izin user sebelum menghentikan proses.
- User pernah meminta backend tidak dijalankan otomatis. Jangan start dev server backend/admin kecuali user minta.
- Mobile fallback demo masih ada di beberapa layar untuk kondisi backend gagal. Untuk production polish, fallback demo bisa dikurangi atau diberi pesan offline yang lebih jelas.

## Verifikasi Terakhir

Sebelum dokumen ini dibuat, hasil verifikasi terakhir:

- `backend`: `npm run build` berhasil.
- `backend`: `npx prisma validate` berhasil.
- `backend`: typecheck `prisma/seed.ts` berhasil.
- `admin`: `npm run build` berhasil pada Phase 8.
- `mobile`: `flutter analyze` pernah timeout karena Dart process menggantung.

Jika agent berikutnya menyentuh admin, ulang:

```powershell
cd admin
npm run build
```

Jika menyentuh backend:

```powershell
cd backend
npm run build
npx prisma validate
```

Jika menyentuh mobile:

```powershell
cd mobile
flutter analyze
flutter build apk --debug
```

## Hal yang Perlu Dilanjutkan

Prioritas lanjut yang masuk akal:

1. Verifikasi end-to-end mobile setelah seed Phase 9: user beli paket, admin approve order, user membuka materi/soal, progress tersimpan.
2. Buat flow pembayaran lebih nyata. Saat ini order dibuat dan admin dapat mengubah status agar entitlement aktif.
3. Tambah konten SSW bidang lain, bukan hanya Kaigo.
4. Tambah bank soal lebih banyak untuk JFT/JLPT per level.
5. Jadwal ujian masih seed/manual admin. User sebelumnya ingin data publik JFT/JLPT/SSW, ini belum diintegrasikan ke sumber publik otomatis.
6. Rapikan fallback demo mobile untuk mode production.
7. Tambah test backend untuk auth, entitlement, order, promo/voucher, progress, dan access control materi.
8. Finalisasi build APK release dengan Firebase/Google Sign-In production.

## Gaya Kerja dengan User

- User ingin instruksi step-by-step dan sering menjalankan sendiri command deploy/seed.
- Jangan menjalankan backend server otomatis tanpa diminta.
- Untuk Vercel, biasanya cukup push ke GitHub lalu Vercel auto deploy.
- Setelah perubahan database/seed, beri command singkat yang perlu user jalankan.
- Jawab dalam Bahasa Indonesia.
