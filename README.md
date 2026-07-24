# SYNAPSE

SYNAPSE is a Flutter research/news reading app backed directly by Firebase client SDKs. This repository now also includes an admin dashboard:

- `admin-web`: Next.js App Router, Tailwind CSS, shadcn-style UI, Firebase Web Auth.
- `admin-api`: NestJS API, Firebase Admin SDK, Swagger, audit logs, notification sending, user/admin operations.

The Flutter app continues to call Firebase and OpenAlex directly. NestJS only performs privileged admin operations.

## Local Setup

Admin API:

```bash
cd admin-api
npm install
npm run start:dev
```

Admin Web:

```bash
cd admin-web
npm install
npm run dev
```

Flutter:

```bash
flutter pub get
flutter run
```

## Firebase Setup

1. Use the existing Firebase project `synapse-prm393`.
2. Create a Firebase Web App for `admin-web`.
3. Copy `admin-web/.env.example` to `admin-web/.env.local` and fill `NEXT_PUBLIC_FIREBASE_*`.
4. Create a Firebase service account for `admin-api`.
5. Base64 encode the service account JSON and set `FIREBASE_SERVICE_ACCOUNT_BASE64` in `admin-api/.env`, or use Google Application Default Credentials in production.
6. Grant the first admin:

```bash
cd admin-api
npm run admin:set -- --email=admin@example.com
```

7. Deploy Firestore and Storage rules after review:

```bash
firebase deploy --only firestore:rules,storage
```

## Environment Variables

See:

- `admin-api/.env.example`
- `admin-web/.env.example`

Do not commit `.env`, `.env.local`, service account JSON, private keys, Firebase ID tokens, access tokens, or FCM tokens.

## Admin URLs

- Admin Web: `http://localhost:3000`
- Admin API: `http://localhost:4000/api`
- Swagger: `http://localhost:4000/api/docs`
- Health: `http://localhost:4000/api/health`

## Docker

```bash
docker compose -f docker-compose.admin.yml up --build
```

`NEXT_PUBLIC_API_BASE_URL` must be a browser-reachable API URL, not an internal Docker hostname.

## Flutter FCM Device Tokens

After Google sign-in, Flutter stores the device token at:

```text
users/{uid}/devices/{deviceId}
```

It listens to FCM token refresh, subscribes to `all-users`, and marks the current device inactive before Firebase sign-out.
