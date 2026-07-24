export type AnalyticsEventInput = {
  eventName: string;
  eventCount: number;
  activeUsers: number;
};

export type AnalyticsEventCategory = 'lab' | 'automatic' | 'other';

export type AnalyticsChartEvent = {
  name: string;
  count: number;
  activeUsers: number;
  percentage: number;
  eventsPerUser: number;
  category: AnalyticsEventCategory;
};

export const LAB_EVENTS = new Set([
  'login',
  'search_topic',
  'view_publication',
  'view_journal',
  'view_keyword',
  'export_pdf',
  'logout'
]);

export const AUTOMATIC_EVENTS = new Set([
  'user_engagement',
  'screen_view',
  'session_start',
  'first_open',
  'app_remove',
  'app_clear_data',
  'app_exception',
  'notification_receive',
  'notification_foreground'
]);

export function mapAnalyticsEvents(events: AnalyticsEventInput[] = [], totalEvents?: number): AnalyticsChartEvent[] {
  const total = totalEvents ?? events.reduce((sum, event) => sum + safeNumber(event.eventCount), 0);

  return events
    .map((event) => {
      const count = safeNumber(event.eventCount);
      const activeUsers = safeNumber(event.activeUsers);

      return {
        name: event.eventName,
        count,
        activeUsers,
        percentage: total > 0 ? (count / total) * 100 : 0,
        eventsPerUser: activeUsers > 0 ? count / activeUsers : 0,
        category: getEventCategory(event.eventName)
      };
    })
    .sort((a, b) => b.count - a.count);
}

export function getEventCategory(eventName: string): AnalyticsEventCategory {
  if (LAB_EVENTS.has(eventName)) return 'lab';
  if (AUTOMATIC_EVENTS.has(eventName)) return 'automatic';
  return 'other';
}

function safeNumber(value: number) {
  return Number.isFinite(value) ? value : 0;
}
