import { Activity, FlaskConical, Trophy, Users } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { AnalyticsChartEvent, LAB_EVENTS } from '@/features/analytics/lib/analytics-chart.mapper';
import { wholeNumber } from '@/lib/charts/formatters';

export function AnalyticsKpiGrid({
  events,
  totalEvents,
  activeUsers,
  topEvent,
  rangeLabel
}: {
  events: AnalyticsChartEvent[];
  totalEvents: number;
  activeUsers: number;
  topEvent?: AnalyticsChartEvent;
  rangeLabel: string;
}) {
  const labCount = events.filter((event) => LAB_EVENTS.has(event.name)).length;

  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <AnalyticsKpi icon={Activity} title="Total events" value={totalEvents} description={`${events.length} event types`} />
      <AnalyticsKpi icon={Users} title="Active users" value={activeUsers} description={rangeLabel} />
      <AnalyticsKpi icon={Trophy} title="Top event" value={topEvent?.count ?? 0} description={topEvent?.name ?? 'No events'} />
      <AnalyticsKpi icon={FlaskConical} title="Tracked Lab events" value={labCount} description="login, search, views, export, logout" />
    </div>
  );
}

function AnalyticsKpi({
  icon: Icon,
  title,
  value,
  description
}: {
  icon: typeof Activity;
  title: string;
  value: number;
  description: string;
}) {
  return (
    <Card className="transition-colors hover:border-[var(--primary)]/40">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-sm text-[var(--muted-foreground)]">{title}</p>
          <p className="mt-3 text-3xl font-semibold tabular-nums">{wholeNumber.format(value)}</p>
          <p className="mt-2 truncate text-xs text-[var(--muted-foreground)]">{description}</p>
        </div>
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[var(--muted)] text-[var(--primary)]">
          <Icon className="h-5 w-5" />
        </div>
      </div>
    </Card>
  );
}
