# Nihon e Ikitai

Nihon e Ikitai adalah sistem pembelajaran bahasa Jepang berbasis mobile dan web admin. Sistem ini terdiri dari aplikasi Flutter untuk pengguna, web admin Next.js untuk pengelolaan konten, dan backend API NestJS untuk data dinamis, autentikasi, role, dan integrasi database.

## Struktur Project

```txt
nihon/
  mobile/   Aplikasi Flutter untuk user dan admin preview
  admin/    Web admin Next.js untuk mengelola konten
  backend/  API NestJS, Prisma, MySQL, dan Firebase Auth
```

## Modul Utama

- Hiragana dan Katakana statis, termasuk halaman detail dan cara menulis.
- Kotoba dengan kanji, furigana, romaji, arti, dan contoh kalimat.
- Kumpulan soal JFT.
- Kumpulan soal JLPT.
- Modul SSW berisi kategori, materi, dan soal latihan.
- Jadwal ujian JFT, JLPT, dan SSW.
- Berita tentang Jepang.
- Admin panel untuk mengelola konten dinamis.

## Rekomendasi Arsitektur

- Mobile: Flutter.
- Admin web: Next.js.
- Backend: NestJS.
- Database: MySQL.
- ORM: Prisma.
- Auth: Firebase Auth untuk Google, email/password, dan nomor HP/OTP.

Backend akan memverifikasi Firebase ID token dari mobile dan admin web. Setelah token valid, backend membuat atau mengambil user lokal berdasarkan `firebaseUid`, lalu menerapkan role `user` atau `admin`.

## Cara Menjalankan

Instruksi end-to-end ada di [SETUP.md](D:/Project/nihon/SETUP.md).

Rencana command:

```bash
# Backend
cd backend
npm install
npm run start:dev

# Admin web
cd admin
npm install
npm run dev

# Mobile
cd mobile
flutter pub get
flutter run
```

## Auth dan Role

Panduan Firebase Auth, role `USER`/`ADMIN`, dan cara membuat admin pertama ada di [AUTH_SETUP.md](D:/Project/nihon/AUTH_SETUP.md).

## Phase Development

1. Setup monorepo dan dokumentasi awal.
2. Backend API dengan NestJS, Prisma, MySQL, Firebase Auth, dan schema awal.
3. Mobile Flutter dengan navigasi dan layar utama.
4. Admin web Next.js dengan dashboard dan CRUD.
5. Integrasi auth dan role.
6. Modul SSW lengkap dengan materi, kosakata Jepang, contoh kalimat, dan soal latihan.
7. Modul soal JLPT dan JFT dengan paket soal, skor akhir, review jawaban, dan dukungan teks Jepang penuh.
8. Jadwal ujian dan berita Jepang dengan filter, detail, dan kontrol publish/draft dari admin.
9. Polishing, validasi, testing, dan dokumentasi env.

## Teks Jepang

Dukungan kanji, hiragana, katakana, furigana, romaji, dan arti dijelaskan di [JAPANESE_TEXT_SUPPORT.md](D:/Project/nihon/JAPANESE_TEXT_SUPPORT.md).

## Design System

Palette visual Nihon e Ikitai memakai sage/mint dengan aksen merah Jepang. Detail token warna ada di [DESIGN_TOKENS.md](D:/Project/nihon/DESIGN_TOKENS.md).

## Validasi Admin

Backend memvalidasi payload admin sebelum menyimpan ke Prisma: field wajib, enum `status`/tipe ujian, tanggal, slug, pilihan jawaban, dan range jadwal dicek agar data dinamis tetap rapi.
