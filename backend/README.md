# Nihon e Ikitai Backend

Backend API untuk Nihon e Ikitai menggunakan NestJS, Prisma, MySQL, dan Firebase Auth.

## Setup

Panduan lengkap end-to-end tersedia di [../SETUP.md](D:/Project/nihon/SETUP.md).

```bash
cp .env.example .env
npm install
npm run prisma:generate
npm run prisma:migrate
npm run seed
npm run start:dev
```

Default API berjalan di `http://localhost:4000`.

## Auth

Client mobile dan admin web login menggunakan Firebase Auth. Setiap request yang butuh login harus mengirim header:

```txt
Authorization: Bearer <firebase-id-token>
```

Backend memverifikasi token melalui Firebase Admin SDK, lalu membuat atau mengambil user lokal berdasarkan `firebaseUid`.

Role default adalah `USER`. Admin awal tersedia dari seed dengan `firebaseUid` `seed-admin` untuk kebutuhan development. Pada produksi, user admin sebaiknya dibuat melalui script khusus atau update database yang terkontrol.

## Membuat Admin Pertama

Cara yang disarankan:

1. Buat user lewat Firebase Auth dari mobile/admin web.
2. Ambil `uid` user dari Firebase Console.
3. Jalankan script backend:

```bash
npm run admin:promote -- --firebaseUid=<firebase-uid> --email=admin@email.com --displayName="Admin Nihon e Ikitai"
```

Jika user sudah pernah login dan tersimpan di database lokal, bisa promote berdasarkan email:

```bash
npm run admin:promote -- --email=admin@email.com
```

Endpoint API tidak menyediakan fitur membuat admin baru. Role admin hanya dibuat dari seed atau script CLI ini.

## Teks Jepang

Backend menerima dan menyimpan JSON UTF-8 untuk kanji, hiragana, katakana, furigana, romaji, dan arti. Detail field dan format admin ada di [../JAPANESE_TEXT_SUPPORT.md](D:/Project/nihon/JAPANESE_TEXT_SUPPORT.md).

## Endpoint Publik

- `GET /health`
- `GET /kana/hiragana`
- `GET /kana/katakana`
- `GET /kotoba`
- `GET /kotoba/:id`
- `GET /jlpt/questions?level=N5`
- `GET /jlpt/question-sets?level=N5`
- `GET /jlpt/question-sets/:id`
- `GET /jft/questions?category=basic`
- `GET /jft/question-sets?category=daily`
- `GET /jft/question-sets/:id`
- `GET /ssw/categories`
- `GET /ssw/modules/:id`
- `GET /exam-schedules?type=JFT`
- `GET /exam-schedules/:id`
- `GET /japan-news?category=karier`
- `GET /japan-news/:idOrSlug`

## Endpoint Login

- `GET /me`

## Endpoint Admin

Semua endpoint admin membutuhkan token Firebase dari user dengan role `ADMIN`.

- `GET|POST /admin/kotoba`
- `PATCH|DELETE /admin/kotoba/:id`
- `GET|POST /admin/jlpt/questions`
- `PATCH|DELETE /admin/jlpt/questions/:id`
- `GET|POST /admin/jlpt/question-sets`
- `PATCH|DELETE /admin/jlpt/question-sets/:id`
- `GET|POST /admin/jft/questions`
- `PATCH|DELETE /admin/jft/questions/:id`
- `GET|POST /admin/jft/question-sets`
- `PATCH|DELETE /admin/jft/question-sets/:id`
- `GET|POST /admin/ssw/categories`
- `PATCH|DELETE /admin/ssw/categories/:id`
- `GET|POST /admin/ssw/modules`
- `PATCH|DELETE /admin/ssw/modules/:id`
- `GET|POST /admin/ssw/questions`
- `PATCH|DELETE /admin/ssw/questions/:id`
- `GET|POST /admin/exam-schedules`
- `PATCH|DELETE /admin/exam-schedules/:id`
- `GET|POST /admin/japan-news`
- `PATCH|DELETE /admin/japan-news/:id`

## Status Phase 2

Phase 2 menyiapkan schema database, seed data demo, Firebase auth guard, role guard, dan endpoint CRUD awal untuk konten dinamis.

## Validasi Payload Admin

CRUD admin memvalidasi field wajib, `status`, tipe soal/ujian, slug, tanggal, opsi jawaban, dan rentang jadwal sebelum data dikirim ke Prisma. Field yang tidak dikenal akan diabaikan.
