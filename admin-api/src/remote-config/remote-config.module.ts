import { Module } from '@nestjs/common';
import { AuditLogsModule } from '../audit-logs/audit-logs.module';
import { RemoteConfigController } from './remote-config.controller';
import { RemoteConfigService } from './remote-config.service';

@Module({
  imports: [AuditLogsModule],
  controllers: [RemoteConfigController],
  providers: [RemoteConfigService]
})
export class RemoteConfigModule {}
