import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { AdminUser } from '../common/types/admin-user';
import { AuditLogService } from '../audit-logs/audit-log.service';

@Injectable()
export class ReportsService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly config: ConfigService,
    private readonly audit: AuditLogService
  ) {}

  async list(limit = 50, pageToken?: string, search?: string, uid?: string) {
    const prefix = this.prefix(uid);
    const [files, nextQuery] = await this.firebase.storage.bucket().getFiles({
      prefix,
      maxResults: Math.min(limit, 100),
      pageToken
    });
    const items = files
      .filter((file) => file.name.endsWith('.pdf'))
      .filter((file) => !search || file.name.toLowerCase().includes(search.toLowerCase()))
      .map((file) => ({
        name: file.name.split('/').pop(),
        fullPath: file.name,
        ownerUid: this.ownerFromPath(file.name),
        contentType: file.metadata.contentType ?? null,
        size: Number(file.metadata.size ?? 0),
        created: file.metadata.timeCreated ?? null,
        updated: file.metadata.updated ?? null,
        metadata: file.metadata.metadata ?? {}
      }));
    return { items, pageToken: nextQuery?.pageToken ?? null };
  }

  async signedUrl(path: string, inline = false) {
    this.assertReportPath(path);
    const file = this.firebase.storage.bucket().file(path);
    const [exists] = await file.exists();
    if (!exists) throw new NotFoundException('Report not found');
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 15 * 60 * 1000,
      ...(inline
        ? {
            responseDisposition: 'inline',
            responseType: 'application/pdf'
          }
        : {})
    });
    return { url, expiresInSeconds: 900 };
  }

  async delete(path: string, adminUser: AdminUser) {
    this.assertReportPath(path);
    const file = this.firebase.storage.bucket().file(path);
    const [metadata] = await file.getMetadata();
    await file.delete();
    await this.audit.write(adminUser, {
      action: 'delete_report',
      targetType: 'storageReport',
      targetId: path,
      before: { path, size: metadata.size, contentType: metadata.contentType },
      after: null,
      success: true
    });
    return { deleted: true };
  }

  async summarize() {
    const { items } = await this.list(100);
    return {
      count: items.length,
      totalBytes: items.reduce((sum, item) => sum + item.size, 0)
    };
  }

  private configuredPrefix() {
    return this.config.get<string>('firebase.reportsPrefix', 'reports').replace(/^\/+|\/+$/g, '');
  }

  private prefix(uid?: string) {
    return uid ? `${this.configuredPrefix()}/${uid}/` : `${this.configuredPrefix()}/`;
  }

  private assertReportPath(path: string) {
    const normalized = path.replace(/\\/g, '/');
    if (normalized !== path || normalized.includes('..') || normalized.startsWith('/') || !normalized.startsWith(`${this.configuredPrefix()}/`)) {
      throw new BadRequestException('Invalid report path');
    }
  }

  private ownerFromPath(path: string) {
    const parts = path.split('/');
    return parts[0] === this.configuredPrefix() ? parts[1] ?? null : null;
  }
}
