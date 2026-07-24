import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { AdminUser } from '../common/types/admin-user';

export type AuditAction = {
  action: string;
  targetType: string;
  targetId?: string | null;
  before?: Record<string, unknown> | null;
  after?: Record<string, unknown> | null;
  success: boolean;
  errorCode?: string | null;
  errorMessage?: string | null;
  ipAddress?: string | null;
};

@Injectable()
export class AuditLogService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly config: ConfigService
  ) {}

  async write(adminUser: AdminUser, action: AuditAction) {
    const collection = this.config.get<string>('firebase.auditLogCollection', 'adminAuditLogs');
    await this.firebase.firestore.collection(collection).add({
      adminUid: adminUser.uid,
      adminEmail: adminUser.email ?? null,
      action: action.action,
      targetType: action.targetType,
      targetId: action.targetId ?? null,
      before: action.before ?? null,
      after: action.after ?? null,
      success: action.success,
      errorCode: action.errorCode ?? null,
      errorMessage: action.errorMessage ?? null,
      ipAddress: action.ipAddress ?? null,
      createdAt: this.firebase.serverTimestamp()
    });
  }
}
