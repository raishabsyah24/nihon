# Nihon e Ikitai Setup

Panduan ini merangkum setup lokal end-to-end untuk backend, admin web, dan mobile.

## 1. Backend

Salin env:

```bash
cd backend
cp .env.example .env
```

Isi `DATABASE_URL` dengan MySQL lokal:

```txt
DATABASE_URL="mysql://root:password@localhost:3306/nihon_e_ikitai"
PORT=4000
```

Buat database dengan charset UTF-8 penuh agar kanji, hiragana, katakana, dan emoji aman:

```bash
mysql -u root -p -e "CREATE DATABASE nihon_e_ikitai CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

Jika password MySQL berisi karakter khusus seperti `@`, `#`, atau `/`, encode password di `DATABASE_URL`.

Siapkan schema dan data awal:

```bash
npm install
npm run prisma:generate
npm run prisma:migrate
npm run seed
npm run start:dev
```

Backend berjalan di `http://localhost:4000`.

## 2. Firebase Auth

Gunakan salah satu opsi Firebase Admin di `backend/.env`:

```txt
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
```

atau:

```txt
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

Untuk mobile, tambahkan file konfigurasi Firebase:

- Android: `mobile/android/app/google-services.json`
- iOS: `mobile/ios/Runner/GoogleService-Info.plist`

## 3. Admin Web

Salin env:

```bash
cd admin
cp .env.example .env.local
```

Isi konfigurasi Firebase web dan arahkan API:

```txt
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
```

Jalankan admin:

```bash
npm install
npm run dev
```

Admin berjalan di `http://localhost:3000`.

## 4. Mobile

Untuk emulator Android, gunakan `10.0.2.2` agar app bisa mengakses backend di komputer:

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Untuk device fisik, ganti `10.0.2.2` dengan IP lokal komputer.

## 5. Membuat Admin Pertama

Login sekali lewat Firebase Auth, ambil `uid` user dari Firebase Console, lalu promote dari backend:

```bash
cd backend
npm run admin:promote -- --firebaseUid=<firebase-uid> --email=admin@email.com --displayName="Admin Nihon e Ikitai"
```

Jika user sudah pernah tersimpan di database lokal, bisa promote berdasarkan email:

```bash
npm run admin:promote -- --email=admin@email.com
```

## 6. Checklist Verifikasi

```bash
# Backend
cd backend
npm run build

# Admin
cd admin
npm run lint
npm run build

# Mobile
cd mobile
flutter analyze
flutter test
flutter build apk --debug
```

Seed dan form admin mendukung kanji, hiragana, katakana, furigana, romaji, dan arti bahasa Indonesia dalam format UTF-8.
