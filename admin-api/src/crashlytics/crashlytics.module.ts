import { Module } from '@nestjs/common';
import { CrashlyticsController } from './crashlytics.controller';
import { CrashlyticsService } from './crashlytics.service';

@Module({
  controllers: [CrashlyticsController],
  providers: [CrashlyticsService],
  exports: [CrashlyticsService]
})
export class CrashlyticsModule {}
