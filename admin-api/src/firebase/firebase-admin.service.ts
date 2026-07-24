import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import admin from 'firebase-admin';

@Injectable()
export class FirebaseAdminService {
  readonly app: admin.app.App;

  constructor(private readonly config: ConfigService) {
    if (admin.apps.length) {
      this.app = admin.app();
      return;
    }

    const projectId = this.config.get<string>('firebase.projectId');
    const storageBucket = this.config.get<string>('firebase.storageBucket');
    const serviceAccountBase64 = this.config.get<string>('firebase.serviceAccountBase64');
    const options: admin.AppOptions = { projectId, storageBucket };

    if (serviceAccountBase64) {
      const serviceAccount = JSON.parse(Buffer.from(serviceAccountBase64, 'base64').toString('utf8')) as admin.ServiceAccount;
      options.credential = admin.credential.cert(serviceAccount);
    } else {
      options.credential = admin.credential.applicationDefault();
    }

    this.app = admin.initializeApp(options);
  }

  get auth() {
    return admin.auth(this.app);
  }

  get firestore() {
    return admin.firestore(this.app);
  }

  get messaging() {
    return admin.messaging(this.app);
  }

  get storage() {
    return admin.storage(this.app);
  }

  get remoteConfig() {
    return admin.remoteConfig(this.app);
  }

  serverTimestamp() {
    return admin.firestore.FieldValue.serverTimestamp();
  }
}
