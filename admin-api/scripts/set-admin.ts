import admin from 'firebase-admin';
import { initializeAdminApp, readIdentifier, resolveUser } from './admin-script-utils';

async function main() {
  initializeAdminApp();
  const auth = admin.auth();
  const user = await resolveUser(auth, readIdentifier());
  await auth.setCustomUserClaims(user.uid, { ...(user.customClaims ?? {}), admin: true });
  const updated = await auth.getUser(user.uid);
  console.log(`Admin claim granted: uid=${updated.uid} email=${updated.email ?? 'unknown'}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : 'Failed to grant admin claim');
  process.exit(1);
});
