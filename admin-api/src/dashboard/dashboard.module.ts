import { Module } from '@nestjs/common';
import { AnalyticsModule } from '../analytics/analytics.module';
import { CrashlyticsModule } from '../crashlytics/crashlytics.module';
import { ReportsModule } from '../reports/reports.module';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

@Module({
  imports: [AnalyticsModule, CrashlyticsModule, ReportsModule],
  controllers: [DashboardController],
  providers: [DashboardService]
})
export class DashboardModule {}
