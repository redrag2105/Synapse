import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { DevicesService } from '../devices/devices.service';
import { UsersService } from '../users/users.service';
import { AdminUser } from '../common/types/admin-user';
import { SendNotificationDto } from './notifications.dto';
import { AuditLogService } from '../audit-logs/audit-log.service';

@Injectable()
export class NotificationsService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly config: ConfigService,
    private readonly devices: DevicesService,
    private readonly users: UsersService,
    private readonly audit: AuditLogService
  ) {}

  async list(limit = 25) {
    const collection = this.config.get<string>('firebase.notificationCollection', 'notificationCampaigns');
    const snapshot = await this.firebase.firestore
      .collection(collection)
      .orderBy('createdAt', 'desc')
      .limit(Math.min(limit, 100))
      .get();
    return { items: snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })) };
  }

  async get(id: string) {
    const collection = this.config.get<string>('firebase.notificationCollection', 'notificationCampaigns');
    const doc = await this.firebase.firestore.collection(collection).doc(id).get();
    if (!doc.exists) throw new NotFoundException('Notification campaign not found');
    return { id: doc.id, ...doc.data() };
  }

  async send(dto: SendNotificationDto, adminUser: AdminUser, isTest = false) {
    const collection = this.config.get<string>('firebase.notificationCollection', 'notificationCampaigns');
    const campaignRef = this.firebase.firestore.collection(collection).doc();
    const data = this.stringifyData({ ...(dto.data ?? {}), type: dto.type });
    const campaign = {
      title: dto.title,
      body: dto.body,
      imageUrl: dto.imageUrl ?? null,
      data,
      targetType: isTest ? 'user' : dto.targetType,
      target: isTest ? adminUser.uid : dto.target ?? dto.targetUsers ?? null,
      createdBy: adminUser.uid,
      createdByEmail: adminUser.email ?? null,
      status: 'sending',
      successCount: 0,
      failureCount: 0,
      createdAt: this.firebase.serverTimestamp(),
      completedAt: null
    };
    await campaignRef.set(campaign);

    const messageBase = {
      notification: { title: dto.title, body: dto.body, imageUrl: dto.imageUrl },
      data
    };
    let successCount = 0;
    let failureCount = 0;

    try {
      if (dto.targetType === 'topic' || dto.targetType === 'all') {
        const topic = dto.targetType === 'all'
          ? this.config.get<string>('firebase.defaultTopic', 'all-users')
          : dto.target;
        if (!topic) throw new BadRequestException('Topic is required');
        const id = await this.firebase.messaging.send({ ...messageBase, topic });
        successCount = id ? 1 : 0;
      } else {
        const targetUsers = isTest ? [adminUser.uid] : dto.targetUsers ?? (dto.target ? [dto.target] : []);
        if (!targetUsers.length) throw new BadRequestException('At least one target user is required');
        for (const identifier of targetUsers) {
          const uid = await this.users.findUidByEmailOrUid(identifier);
          const tokens = await this.devices.getActiveTokensForUser(uid);
          for (const device of tokens) {
            try {
              await this.firebase.messaging.send({ ...messageBase, token: device.token });
              successCount += 1;
            } catch (error) {
              failureCount += 1;
              const code = typeof error === 'object' && error && 'code' in error ? String(error.code) : '';
              if (code.includes('registration-token-not-registered') || code.includes('invalid-registration-token')) {
                await this.devices.markTokenInactive(uid, device.id);
              }
            }
          }
        }
      }

      const status = failureCount === 0 ? 'sent' : successCount > 0 ? 'partially_failed' : 'failed';
      await campaignRef.set({ status, successCount, failureCount, completedAt: this.firebase.serverTimestamp() }, { merge: true });
      await this.audit.write(adminUser, {
        action: isTest ? 'send_test_notification' : 'send_notification',
        targetType: 'notificationCampaign',
        targetId: campaignRef.id,
        after: { status, successCount, failureCount },
        success: true
      });
      return { id: campaignRef.id, status, successCount, failureCount };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Notification send failed';
      await campaignRef.set({ status: 'failed', successCount, failureCount, completedAt: this.firebase.serverTimestamp() }, { merge: true });
      await this.audit.write(adminUser, {
        action: isTest ? 'send_test_notification' : 'send_notification',
        targetType: 'notificationCampaign',
        targetId: campaignRef.id,
        after: { successCount, failureCount },
        success: false,
        errorMessage: message
      });
      throw error;
    }
  }

  private stringifyData(data: Record<string, unknown>) {
    return Object.fromEntries(
      Object.entries(data)
        .filter(([, value]) => value !== undefined && value !== null)
        .map(([key, value]) => [key, String(value)])
    );
  }
}
