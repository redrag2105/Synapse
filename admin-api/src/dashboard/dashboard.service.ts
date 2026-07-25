import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { ReportsService } from '../reports/reports.service';
import { AnalyticsService } from '../analytics/analytics.service';
import { CrashlyticsService } from '../crashlytics/crashlytics.service';

@Injectable()
export class DashboardService {
  constructor(
    private readonly firebase: FirebaseAdminService,
    private readonly config: ConfigService,
    private readonly reports: ReportsService,
    private readonly analytics: AnalyticsService,
    private readonly crashlytics: CrashlyticsService
  ) {}

  async overview() {
    const userPage = await this.firebase.auth.listUsers(1000);
    const now = Date.now();
    const sevenDays = 7 * 24 * 60 * 60 * 1000;
    const reportSummary = await this.reports.summarize();
    const notificationCollection = this.config.get<string>('firebase.notificationCollection', 'notificationCampaigns');
    const notificationSnapshot = await this.firebase.firestore.collection(notificationCollection).limit(1000).get();
    const notifications = notificationSnapshot.docs.map((doc) => doc.data());

    return {
      users: {
        total: userPage.users.length,
        active: userPage.users.filter((user) => !user.disabled).length,
        disabled: userPage.users.filter((user) => user.disabled).length,
        newIn7Days: userPage.users.filter((user) => now - Date.parse(user.metadata.creationTime) <= sevenDays).length,
        newByDay: this.countUsersByDay(userPage.users)
      },
      notifications: {
        campaigns: notifications.length,
        successCount: notifications.reduce((sum, item) => sum + Number(item.successCount ?? 0), 0),
        failureCount: notifications.reduce((sum, item) => sum + Number(item.failureCount ?? 0), 0)
      },
      reports: reportSummary,
      analytics: await this.analytics.overview(),
      crashlytics: await this.crashlytics.issues()
    };
  }

  private countUsersByDay(users: import('firebase-admin/auth').UserRecord[]) {
    const map = new Map<string, number>();
    for (const user of users) {
      const day = user.metadata.creationTime.slice(0, 10);
      map.set(day, (map.get(day) ?? 0) + 1);
    }
    return Array.from(map.entries()).map(([date, count]) => ({ date, count }));
  }
}
