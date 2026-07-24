import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AnalyticsService {
  constructor(private readonly config: ConfigService) {}

  async overview(startDate = '7daysAgo', endDate = 'today') {
    const propertyId = this.config.get<string>('analytics.propertyId');
    if (!propertyId) {
      return {
        configured: false,
        integrationStatus: 'GOOGLE_ANALYTICS_PROPERTY_ID is not configured'
      };
    }

    const serviceAccountBase64 = this.config.get<string>('firebase.serviceAccountBase64');
    const googleApplicationCredentials = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    if (!serviceAccountBase64 && !googleApplicationCredentials) {
      return {
        configured: false,
        integrationStatus:
          'GOOGLE_ANALYTICS_PROPERTY_ID is set, but Google credentials are not configured for Analytics Data API'
      };
    }

    try {
      const { BetaAnalyticsDataClient } = await import('@google-analytics/data');
      const client = serviceAccountBase64
        ? new BetaAnalyticsDataClient({
            credentials: JSON.parse(
              Buffer.from(serviceAccountBase64, 'base64').toString('utf8')
            ) as { client_email: string; private_key: string },
            projectId: this.config.get<string>('firebase.projectId')
          })
        : new BetaAnalyticsDataClient();
      const [response] = await client.runReport({
        property: `properties/${propertyId}`,
        dateRanges: [{ startDate, endDate }],
        dimensions: [{ name: 'eventName' }],
        metrics: [{ name: 'eventCount' }, { name: 'activeUsers' }]
      });
      const events = (response.rows ?? []).map((row) => ({
        eventName: row.dimensionValues?.[0]?.value ?? 'unknown',
        eventCount: Number(row.metricValues?.[0]?.value ?? 0),
        activeUsers: Number(row.metricValues?.[1]?.value ?? 0)
      }));
      const totalEvents = events.reduce((sum, row) => sum + row.eventCount, 0);
      const activeUsers = events.reduce((sum, row) => sum + row.activeUsers, 0);
      const topEvent = [...events].sort((a, b) => b.eventCount - a.eventCount)[0] ?? null;

      return {
        configured: true,
        startDate,
        endDate,
        totalEvents,
        activeUsers,
        topEvent,
        events
      };
    } catch {
      return {
        configured: false,
        integrationStatus:
          'Google Analytics Data API credentials are not available or cannot read the configured GA4 property'
      };
    }
  }

  events(startDate?: string, endDate?: string) {
    return this.overview(startDate, endDate);
  }

  topTopics() {
    return this.overview();
  }

  topPublications() {
    return this.overview();
  }
}
