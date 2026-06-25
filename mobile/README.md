# Nihon e Ikitai Mobile

Aplikasi mobile Flutter untuk pengguna Nihon e Ikitai.

## Fitur Phase 3-8

- Login menggunakan Google dan email/password melalui Firebase Auth.
- App selalu membuka halaman login/register terlebih dahulu.
- Login dan register memakai email/password, dengan opsi login Google.
- Dashboard utama memakai bottom navigation: Beranda, Belajar, Ujian, Info, dan Profil.
- Menu utama: Hiragana, Katakana, Kotoba, Soal JFT, Soal JLPT, SSW, Jadwal Ujian, Berita Jepang, dan Profil.
- Hiragana dan Katakana memiliki halaman detail dan area cara menulis.
- Konten dinamis diambil dari backend API.
- Admin dapat login melalui app dan melihat akses khusus sesuai role.
- Data lokal demo tersedia untuk beberapa layar saat backend belum berjalan.
- App mengirim Firebase ID token ke backend melalui header `Authorization`.
- Role admin dibaca dari backend `GET /me`.
- Soal JLPT dan JFT memakai daftar paket, halaman latihan, skor akhir, dan review jawaban.
- Jadwal ujian mendukung filter JFT/JLPT/SSW dan halaman detail.
- Berita Jepang mendukung filter kategori dan halaman detail.

## Menjalankan

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://192.168.0.101:4000
```

Untuk device fisik, gunakan IP lokal komputer yang menjalankan backend. IP komputer saat ini adalah `192.168.0.101`.

Untuk emulator Android, gunakan:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Jika IP Wi-Fi komputer berubah, ganti nilai `API_BASE_URL` saat menjalankan Flutter atau update default di `lib/src/config/app_config.dart`.

Untuk login Google di Android, tambahkan Web client ID Firebase:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.101:4000 --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID_FIREBASE
```

Saat build APK release:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api-domain-kamu.vercel.app --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID_FIREBASE
```

## Firebase

Firebase dikonfigurasi menggunakan FlutterFire CLI dan file konfigurasi platform:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Role Admin di Mobile

User yang login dari mobile tetap dibuat sebagai role `USER` secara default. Agar menu admin muncul:

1. Login sekali dari mobile atau admin web.
2. Promote user tersebut dari backend:

```bash
npm run admin:promote -- --firebaseUid=<firebase-uid> --email=admin@email.com
```

3. Login ulang di mobile.

## Teks Jepang

Mobile menampilkan kanji, hiragana, katakana, furigana, romaji, dan arti untuk Kotoba, soal, dan modul SSW. Detail dukungan teks Jepang ada di [../JAPANESE_TEXT_SUPPORT.md](D:/Project/nihon/JAPANESE_TEXT_SUPPORT.md).
