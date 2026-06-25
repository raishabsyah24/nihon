# Nihon e Ikitai Auth Setup

Phase 5 menghubungkan autentikasi mobile, admin web, dan backend dengan Firebase Auth.

## Alur Auth

1. User login di Flutter atau Next.js menggunakan Firebase Auth.
2. Client mengambil Firebase ID token.
3. Client mengirim token ke backend:

```txt
Authorization: Bearer <firebase-id-token>
```

4. Backend memverifikasi token dengan Firebase Admin SDK.
5. Backend membuat atau mengambil user lokal berdasarkan `firebaseUid`.
6. Role default user baru adalah `USER`.
7. Endpoint `/admin/*` hanya bisa diakses role `ADMIN`.

## Backend Env

Isi `backend/.env` dari `backend/.env.example`.

Gunakan salah satu opsi Firebase Admin:

```txt
FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
```

atau:

```txt
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

## Admin Web Env

Isi `admin/.env.local` dari `admin/.env.example`.

```txt
NEXT_PUBLIC_API_BASE_URL=http://localhost:4000
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
```

## Mobile Firebase

Tambahkan konfigurasi Firebase platform:

- Android: `mobile/android/app/google-services.json`
- iOS: `mobile/ios/Runner/GoogleService-Info.plist`

Jalankan mobile dengan:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

## Membuat Admin Pertama

Buat user di Firebase Auth, ambil `uid`, lalu jalankan:

```bash
cd backend
npm run admin:promote -- --firebaseUid=<firebase-uid> --email=admin@email.com --displayName="Admin Nihon e Ikitai"
```

Jika user sudah pernah login dan tersimpan di database lokal:

```bash
npm run admin:promote -- --email=admin@email.com
```

