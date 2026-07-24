# SYNAPSE Admin Web

Next.js App Router dashboard cho quản trị SYNAPSE.

## Local

1. Tạo Firebase Web App trong Firebase project hiện tại.
2. Copy `.env.example` thành `.env.local`.
3. Điền các biến `NEXT_PUBLIC_FIREBASE_*` của Web App và `NEXT_PUBLIC_API_BASE_URL`.
4. Chạy:

```bash
npm install
npm run dev
```

Web chạy tại `http://localhost:3000`.

## Security

- Chỉ dùng Firebase Web SDK để đăng nhập.
- Mọi request gửi Firebase ID token qua `Authorization: Bearer`.
- Không chứa Firebase Admin SDK, service account hoặc secret.
