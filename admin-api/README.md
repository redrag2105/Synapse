# SYNAPSE Admin API

NestJS API dùng Firebase Admin SDK để quản trị SYNAPSE.

## Local

1. Copy `.env.example` thành `.env`.
2. Điền `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`.
3. Local có thể dùng `FIREBASE_SERVICE_ACCOUNT_BASE64`; production có thể dùng Google Application Default Credentials.
4. Cài và chạy:

```bash
npm install
npm run start:dev
```

Swagger ở `http://localhost:4000/api/docs` khi `NODE_ENV` không phải production.

## First Admin

```bash
npm run admin:set -- --email=admin@example.com
npm run admin:remove -- --email=admin@example.com
```

Script giữ nguyên custom claims hiện có và không in secret.
