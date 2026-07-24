import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';

@Injectable()
export class DevicesService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly config: ConfigService
  ) {}

  async getActiveTokensForUser(uid: string) {
    const usersCollection = this.config.get<string>('firebase.usersCollection', 'users');
    const snapshot = await this.firebase.firestore
      .collection(usersCollection)
      .doc(uid)
      .collection('devices')
      .where('active', '==', true)
      .get();

    return snapshot.docs
      .map((doc) => ({ id: doc.id, token: doc.data().token as string | undefined }))
      .filter((device): device is { id: string; token: string } => Boolean(device.token));
  }

  async markTokenInactive(uid: string, deviceId: string) {
    const usersCollection = this.config.get<string>('firebase.usersCollection', 'users');
    await this.firebase.firestore
      .collection(usersCollection)
      .doc(uid)
      .collection('devices')
      .doc(deviceId)
      .set({ active: false, updatedAt: this.firebase.serverTimestamp() }, { merge: true });
  }
}
