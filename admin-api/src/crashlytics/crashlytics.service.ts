import {
  BadRequestException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { AdminUser } from '../common/types/admin-user';
import { AuditLogService } from '../audit-logs/audit-log.service';

const ALLOWED_STATUSES = new Set(['open', 'closed', 'muted']);

type CrashlyticsEventDoc = {
  title?: string;
  exception?: string;
  type?: string;
  source?: string;
  status?: string;
  platform?: string;
  uid?: string | null;
  email?: string | null;
  createdAt?: { toDate?: () => Date } | null;
  updatedAt?: { toDate?: () => Date } | null;
};

@Injectable()
export class CrashlyticsService {
  constructor(
    private readonly config: ConfigService,
    private readonly firebase: FirebaseAdminService,
    private readonly audit: AuditLogService
  ) {}

  private collectionName() {
    return this.config.get<string>(
      'firebase.crashlyticsEventsCollection',
      'crashlyticsEvents'
    );
  }

  async issues(limit = 50) {
    const snapshot = await this.firebase.firestore
      .collection(this.collectionName())
      .orderBy('createdAt', 'desc')
      .limit(Math.min(Math.max(limit, 1), 100))
      .get();

    const items = snapshot.docs.map((doc) => this.serialize(doc.id, doc.data() as CrashlyticsEventDoc));
    return {
      configured: true,
      integrationStatus:
        'Showing Crashlytics events mirrored from the mobile Profile demo (Firestore). Events are also sent to Firebase Crashlytics.',
      items,
      count: items.length
    };
  }

  async issue(issueId: string) {
    const doc = await this.firebase.firestore
      .collection(this.collectionName())
      .doc(issueId)
      .get();
    if (!doc.exists) throw new NotFoundException('Crashlytics event not found');
    return {
      configured: true,
      item: this.serialize(doc.id, doc.data() as CrashlyticsEventDoc)
    };
  }

  async updateStatus(issueId: string, status: string, adminUser: AdminUser) {
    if (!ALLOWED_STATUSES.has(status)) {
      throw new BadRequestException('Status must be open, closed, or muted');
    }
    const ref = this.firebase.firestore.collection(this.collectionName()).doc(issueId);
    const doc = await ref.get();
    if (!doc.exists) throw new NotFoundException('Crashlytics event not found');
    const before = this.serialize(doc.id, doc.data() as CrashlyticsEventDoc);
    await ref.update({
      status,
      updatedAt: this.firebase.serverTimestamp()
    });
    const afterDoc = await ref.get();
    const after = this.serialize(afterDoc.id, afterDoc.data() as CrashlyticsEventDoc);
    await this.audit.write(adminUser, {
      action: 'update_crashlytics_status',
      targetType: 'crashlyticsEvent',
      targetId: issueId,
      before,
      after,
      success: true
    });
    return { configured: true, item: after };
  }

  private serialize(id: string, data: CrashlyticsEventDoc) {
    return {
      id,
      title: data.title ?? 'Untitled event',
      exception: data.exception ?? null,
      type: data.type ?? 'nonfatal',
      source: data.source ?? null,
      status: data.status ?? 'open',
      platform: data.platform ?? null,
      uid: data.uid ?? null,
      email: data.email ?? null,
      createdAt: data.createdAt?.toDate?.()?.toISOString?.() ?? null,
      updatedAt: data.updatedAt?.toDate?.()?.toISOString?.() ?? null
    };
  }
}
