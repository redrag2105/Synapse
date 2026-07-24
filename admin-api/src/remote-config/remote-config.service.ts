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
      version: template.version,
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
      before: { etag: current.etag, version: current.version },
      after: { etag: published.etag, version: published.version },
      success: true
    });
    return { etag: published.etag, version: published.version };
  }

  async versions() {
    const versions = await this.firebase.remoteConfig.listVersions({ pageSize: 20 });
    return { items: versions.versions };
  }

  async rollback(versionNumber: string, adminUser: AdminUser) {
    const result = await this.firebase.remoteConfig.rollback(versionNumber);
    await this.audit.write(adminUser, {
      action: 'rollback_remote_config',
      targetType: 'remoteConfig',
      targetId: versionNumber,
      after: { etag: result.etag, version: result.version },
      success: true
    });
    return { etag: result.etag, version: result.version };
  }

  private normalizeParameters(parameters: Record<string, unknown>) {
    return Object.fromEntries(
      Object.entries(parameters).map(([key, value]) => {
        if (typeof value === 'object' && value !== null) return [key, value];
        return [key, { defaultValue: { value: String(value) } }];
      })
    );
  }
}
