import admin from 'firebase-admin';
import 'dotenv/config';

export function initializeAdminApp() {
  if (admin.apps.length) return admin.app();
  const serviceAccountBase64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

  if (!projectId) throw new Error('FIREBASE_PROJECT_ID is required');

  const options: admin.AppOptions = { projectId, storageBucket };
  if (serviceAccountBase64) {
    options.credential = admin.credential.cert(
      JSON.parse(Buffer.from(serviceAccountBase64, 'base64').toString('utf8')) as admin.ServiceAccount
    );
  } else {
    options.credential = admin.credential.applicationDefault();
  }
  return admin.initializeApp(options);
}

export function readIdentifier() {
  const email = process.argv.find((arg) => arg.startsWith('--email='))?.slice('--email='.length);
  const uid = process.argv.find((arg) => arg.startsWith('--uid='))?.slice('--uid='.length);
  if (!email && !uid) throw new Error('Provide --email=user@example.com or --uid=firebaseUid');
  return { email, uid };
}

export async function resolveUser(auth: admin.auth.Auth, identifier: { email?: string; uid?: string }) {
  return identifier.email
    ? auth.getUserByEmail(identifier.email)
    : auth.getUser(identifier.uid as string);
}
