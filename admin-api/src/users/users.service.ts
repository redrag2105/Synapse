import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { AdminUser } from '../common/types/admin-user';
import { AuditLogService } from '../audit-logs/audit-log.service';

@Injectable()
export class UsersService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly audit: AuditLogService
  ) {}

  async list(maxResults = 25, pageToken?: string, search?: string) {
    const users = await this.firebase.auth.listUsers(Math.min(maxResults, 1000), pageToken);
    let items = users.users.map((user) => this.serialize(user));
    if (search) {
      const needle = search.toLowerCase();
      items = items.filter((user) =>
        user.uid.toLowerCase().includes(needle) ||
        (user.email ?? '').toLowerCase().includes(needle)
      );
    }
    return { items, pageToken: users.pageToken ?? null };
  }

  async get(uid: string) {
    try {
      return this.serialize(await this.firebase.auth.getUser(uid));
    } catch {
      throw new NotFoundException('User not found');
    }
  }

  async setStatus(uid: string, disabled: boolean, adminUser: AdminUser, ipAddress?: string) {
    if (uid === adminUser.uid) throw new ForbiddenException('Admins cannot disable themselves');
    const before = await this.get(uid);
    const updated = await this.firebase.auth.updateUser(uid, { disabled });
    const after = this.serialize(updated);
    await this.audit.write(adminUser, {
      action: disabled ? 'disable_user' : 'enable_user',
      targetType: 'user',
      targetId: uid,
      before,
      after,
      success: true,
      ipAddress
    });
    return after;
  }

  async setAdmin(uid: string, admin: boolean, adminUser: AdminUser, ipAddress?: string) {
    const beforeRecord = await this.firebase.auth.getUser(uid);
    const beforeClaims = beforeRecord.customClaims ?? {};
    const claims: Record<string, unknown> = { ...beforeClaims, admin };
    if (!admin) delete claims.admin;
    await this.firebase.auth.setCustomUserClaims(uid, claims);
    const after = await this.firebase.auth.getUser(uid);
    await this.audit.write(adminUser, {
      action: admin ? 'grant_admin' : 'revoke_admin',
      targetType: 'user',
      targetId: uid,
      before: { customClaims: beforeClaims },
      after: { customClaims: after.customClaims ?? {} },
      success: true,
      ipAddress
    });
    return this.serialize(after);
  }

  async delete(uid: string, adminUser: AdminUser, ipAddress?: string) {
    if (uid === adminUser.uid) throw new ForbiddenException('Admins cannot delete themselves');
    const before = await this.get(uid);
    await this.firebase.auth.deleteUser(uid);
    await this.audit.write(adminUser, {
      action: 'delete_user',
      targetType: 'user',
      targetId: uid,
      before,
      after: null,
      success: true,
      ipAddress
    });
    return { deleted: true };
  }

  async findUidByEmailOrUid(identifier: string) {
    if (!identifier) throw new BadRequestException('User identifier is required');
    if (identifier.includes('@')) return (await this.firebase.auth.getUserByEmail(identifier)).uid;
    return identifier;
  }

  serialize(user: import('firebase-admin/auth').UserRecord) {
    const providerIds = user.providerData.map((provider) => provider.providerId);
    return {
      uid: user.uid,
      email: user.email ?? null,
      displayName: user.displayName ?? null,
      photoURL: user.photoURL ?? null,
      emailVerified: user.emailVerified,
      disabled: user.disabled,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime ?? null,
      providerIds,
      customClaims: user.customClaims ?? {},
      role: user.customClaims?.admin === true ? 'admin' : 'user'
    };
  }
}
