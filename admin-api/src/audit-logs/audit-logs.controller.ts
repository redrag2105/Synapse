import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';

@ApiTags('audit-logs')
@ApiBearerAuth()
@Controller('admin/audit-logs')
export class AuditLogsController {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly config: ConfigService
  ) {}

  @Get()
  async list(
    @Query('limit') limit = '25',
    @Query('adminUid') adminUid?: string,
    @Query('action') action?: string
  ) {
    const collection = this.config.get<string>('firebase.auditLogCollection', 'adminAuditLogs');
    let query: FirebaseFirestore.Query = this.firebase.firestore
      .collection(collection)
      .orderBy('createdAt', 'desc')
      .limit(Math.min(Number(limit) || 25, 100));

    if (adminUid) query = query.where('adminUid', '==', adminUid);
    if (action) query = query.where('action', '==', action);

    const snapshot = await query.get();
    return {
      items: snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
    };
  }
}
