import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import configuration from './config/configuration';
import { envValidationSchema } from './config/env.validation';
import { FirebaseAdminModule } from './firebase/firebase-admin.module';
import { FirebaseAuthGuard } from './common/guards/firebase-auth.guard';
import { AdminGuard } from './common/guards/admin.guard';
import { AuthenticationModule } from './authentication/authentication.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { UsersModule } from './users/users.module';
import { DevicesModule } from './devices/devices.module';
import { NotificationsModule } from './notifications/notifications.module';
import { RemoteConfigModule } from './remote-config/remote-config.module';
import { ReportsModule } from './reports/reports.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { CrashlyticsModule } from './crashlytics/crashlytics.module';
import { AuditLogsModule } from './audit-logs/audit-logs.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: envValidationSchema
    }),
    ThrottlerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => [
        {
          ttl: config.get<number>('throttle.ttl', 60000),
          limit: config.get<number>('throttle.limit', 100)
        }
      ]
    }),
    FirebaseAdminModule,
    AuthenticationModule,
    DashboardModule,
    UsersModule,
    DevicesModule,
    NotificationsModule,
    RemoteConfigModule,
    ReportsModule,
    AnalyticsModule,
    CrashlyticsModule,
    AuditLogsModule
  ],
  controllers: [HealthController],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: FirebaseAuthGuard },
    { provide: APP_GUARD, useClass: AdminGuard }
  ]
})
export class AppModule {}
