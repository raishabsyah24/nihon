# Nihon e Ikitai Admin

Web admin Next.js untuk mengelola konten dinamis Nihon e Ikitai.

## Fitur Phase 4-8

- Login Firebase Auth menggunakan Google dan email/password.
- Dashboard admin dengan sidebar.
- CRUD Kotoba.
- CRUD Soal JFT.
- CRUD Soal JLPT.
- CRUD paket soal JFT.
- CRUD paket soal JLPT.
- CRUD kategori, modul, dan soal SSW.
- CRUD jadwal ujian JFT, JLPT, dan SSW.
- CRUD berita Jepang.
- Tombol cepat publish/draft untuk konten yang punya status.
- Halaman users.
- Validasi role admin lewat backend `GET /me`.
- Semua request admin mengirim `Authorization: Bearer <firebase-id-token>`.

## Menjalankan

```bash
cp .env.example .env.local
npm install
npm run dev
```

Default admin berjalan di `http://localhost:3000`.

## Env Firebase

Isi `.env.local` dari `.env.example`:

```txt
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
```

Admin hanya bisa masuk jika user Firebase sudah punya role `ADMIN` di database backend.

## Membuat Admin Pertama

1. Login atau daftar user lewat Firebase Auth.
2. Ambil Firebase `uid` user tersebut dari Firebase Console.
3. Jalankan dari folder `backend`:

```bash
npm run admin:promote -- --firebaseUid=<firebase-uid> --email=admin@email.com
```

Setelah itu login ulang di admin web.

## Input Teks Jepang

Admin web mendukung input kanji, hiragana, katakana, furigana, romaji, dan arti. Format khusus kosakata dan contoh kalimat SSW ada di [../JAPANESE_TEXT_SUPPORT.md](D:/Project/nihon/JAPANESE_TEXT_SUPPORT.md).
