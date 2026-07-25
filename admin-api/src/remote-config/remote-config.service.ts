import { Injectable, PreconditionFailedException } from '@nestjs/common';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { AdminUser } from '../common/types/admin-user';
import { AuditLogService } from '../audit-logs/audit-log.service';
import { RemoteConfigTemplateDto } from './remote-config.dto';

@Injectable()
export class RemoteConfigService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly audit: AuditLogService
  ) {}

  async getTemplate() {
    const template = await this.firebase.remoteConfig.getTemplate();
    return {
      etag: template.etag,
      parameters: template.parameters,
      parameterGroups: template.parameterGroups,
      conditions: template.conditions,
      version: this.serializeVersion(template.version),
      requiredLabKeys: ['max_journals_display', 'max_keywords_display']
    };
  }

  async validate(dto: RemoteConfigTemplateDto) {
    const template = this.firebase.remoteConfig.createTemplateFromJSON(JSON.stringify({
      conditions: dto.conditions ?? [],
      parameters: this.normalizeParameters(dto.parameters),
      parameterGroups: dto.parameterGroups ?? {},
      etag: dto.etag
    }));
    const validated = await this.firebase.remoteConfig.validateTemplate(template);
    return { valid: true, etag: validated.etag };
  }

  async publish(dto: RemoteConfigTemplateDto, adminUser: AdminUser) {
    const current = await this.firebase.remoteConfig.getTemplate();
    if (current.etag !== dto.etag) {
      throw new PreconditionFailedException('Remote Config template ETag conflict');
    }
    const template = this.firebase.remoteConfig.createTemplateFromJSON(JSON.stringify({
      conditions: dto.conditions ?? [],
      parameters: this.normalizeParameters(dto.parameters),
      parameterGroups: dto.parameterGroups ?? {},
      etag: dto.etag
    }));
    const published = await this.firebase.remoteConfig.publishTemplate(template);
    await this.audit.write(adminUser, {
      action: 'publish_remote_config',
      targetType: 'remoteConfig',
      before: { etag: current.etag, version: this.serializeVersion(current.version) },
      after: { etag: published.etag, version: this.serializeVersion(published.version) },
      success: true
    });
    return {
      etag: published.etag,
      version: this.serializeVersion(published.version)
    };
  }

  async versions() {
    const versions = await this.firebase.remoteConfig.listVersions({ pageSize: 20 });
    return {
      items: (versions.versions ?? []).map((version) => this.serializeVersion(version))
    };
  }

  async rollback(versionNumber: string, adminUser: AdminUser) {
    const result = await this.firebase.remoteConfig.rollback(versionNumber);
    await this.audit.write(adminUser, {
      action: 'rollback_remote_config',
      targetType: 'remoteConfig',
      targetId: versionNumber,
      after: { etag: result.etag, version: this.serializeVersion(result.version) },
      success: true
    });
    return {
      etag: result.etag,
      version: this.serializeVersion(result.version)
    };
  }

  private normalizeParameters(parameters: Record<string, unknown>) {
    return Object.fromEntries(
      Object.entries(parameters).map(([key, value]) => {
        if (typeof value === 'object' && value !== null) return [key, value];
        return [key, { defaultValue: { value: String(value) } }];
      })
    );
  }

  /** Remote Config VersionImpl is not Firestore-serializable — convert to plain data. */
  private serializeVersion(version: unknown) {
    if (version == null) return null;
    const record = version as Record<string, unknown>;
    const updateUser = record.updateUser as Record<string, unknown> | undefined;
    return {
      versionNumber:
        record.versionNumber != null ? String(record.versionNumber) : null,
      updateTime: record.updateTime != null ? String(record.updateTime) : null,
      updateOrigin: record.updateOrigin != null ? String(record.updateOrigin) : null,
      updateType: record.updateType != null ? String(record.updateType) : null,
      description: record.description != null ? String(record.description) : null,
      rollbackSource:
        record.rollbackSource != null ? String(record.rollbackSource) : null,
      isLegacy: typeof record.isLegacy === 'boolean' ? record.isLegacy : null,
      updateUser: updateUser
        ? {
            email: updateUser.email != null ? String(updateUser.email) : null,
            imageUrl:
              updateUser.imageUrl != null ? String(updateUser.imageUrl) : null
          }
        : null
    };
  }
}
