import { Module } from '@nestjs/common';
import { AuditLogsModule } from '../audit-logs/audit-logs.module';
import { CrashlyticsController } from './crashlytics.controller';
import { CrashlyticsService } from './crashlytics.service';

@Module({
  imports: [AuditLogsModule],
  controllers: [CrashlyticsController],
  providers: [CrashlyticsService],
  exports: [CrashlyticsService]
})
export class CrashlyticsModule {}
