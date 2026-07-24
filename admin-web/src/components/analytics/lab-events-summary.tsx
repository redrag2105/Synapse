import { FlaskConical } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { AnalyticsChartEvent, LAB_EVENTS } from '@/features/analytics/lib/analytics-chart.mapper';
import { wholeNumber } from '@/lib/charts/formatters';

const labEventOrder = Array.from(LAB_EVENTS);

export function LabEventsSummary({ events }: { events: AnalyticsChartEvent[] }) {
  const eventsByName = new Map(events.map((event) => [event.name, event]));
  const maxCount = Math.max(...labEventOrder.map((eventName) => eventsByName.get(eventName)?.count ?? 0), 0);

  return (
    <Card>
      <div className="flex items-start justify-between gap-3">
        <div>
          <CardTitle>Lab 3 tracked events</CardTitle>
          <CardDescription className="mt-2">Required Lab events separated from Firebase automatic events</CardDescription>
        </div>
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[var(--muted)] text-[var(--primary)]">
          <FlaskConical className="h-5 w-5" />
        </div>
      </div>

      <div className="mt-5 space-y-3">
        {labEventOrder.map((eventName) => {
          const event = eventsByName.get(eventName);
          const count = event?.count ?? 0;
          const activeUsers = event?.activeUsers ?? 0;
          const progress = maxCount > 0 ? (count / maxCount) * 100 : 0;

          return (
            <div key={eventName} className="rounded-xl border bg-[var(--muted)]/35 p-3">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <code className="rounded-md bg-[var(--card)] px-2 py-1 text-xs">{eventName}</code>
                <Badge variant={count > 0 ? 'success' : 'muted'}>{count > 0 ? 'Receiving data' : 'No data'}</Badge>
              </div>
              <div className="mt-3 flex items-center justify-between text-xs text-[var(--muted-foreground)]">
                <span><span className="font-medium tabular-nums text-[var(--foreground)]">{wholeNumber.format(count)}</span> events</span>
                <span><span className="font-medium tabular-nums text-[var(--foreground)]">{wholeNumber.format(activeUsers)}</span> users</span>
              </div>
              <div className="mt-3 h-2 overflow-hidden rounded-full bg-[var(--border)]" aria-label={`${eventName} progress`}>
                <div className="h-full rounded-full bg-emerald-500" style={{ width: `${progress}%` }} />
              </div>
            </div>
          );
        })}
      </div>
    </Card>
  );
}
