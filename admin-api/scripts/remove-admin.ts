import admin from 'firebase-admin';
import { initializeAdminApp, readIdentifier, resolveUser } from './admin-script-utils';

async function main() {
  initializeAdminApp();
  const auth = admin.auth();
  const user = await resolveUser(auth, readIdentifier());
  const claims = { ...(user.customClaims ?? {}) };
  delete claims.admin;
  await auth.setCustomUserClaims(user.uid, claims);
  const updated = await auth.getUser(user.uid);
  console.log(`Admin claim removed: uid=${updated.uid} email=${updated.email ?? 'unknown'}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : 'Failed to remove admin claim');
  process.exit(1);
});
