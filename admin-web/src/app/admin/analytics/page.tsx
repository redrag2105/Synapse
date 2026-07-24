'use client';

import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { BarChart3 } from 'lucide-react';
import { AnalyticsDateFilter } from '@/components/analytics/analytics-date-filter';
import { AnalyticsEventsTable } from '@/components/analytics/analytics-events-table';
import { AnalyticsKpiGrid } from '@/components/analytics/analytics-kpi-grid';
import { AnalyticsPageSkeleton } from '@/components/analytics/analytics-chart-skeleton';
import { EventDistributionChart } from '@/components/analytics/event-distribution-chart';
import { EventEngagementScatter } from '@/components/analytics/event-engagement-scatter';
import { LabEventsSummary } from '@/components/analytics/lab-events-summary';
import { TopEventsChart } from '@/components/analytics/top-events-chart';
import { EmptyPanel, ErrorPanel } from '@/components/states/page-states';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { AnalyticsEventInput, mapAnalyticsEvents } from '@/features/analytics/lib/analytics-chart.mapper';
import { apiGet } from '@/lib/api/client';

type AnalyticsOverview = {
  configured: boolean;
  integrationStatus?: string;
  startDate?: string;
  endDate?: string;
  totalEvents?: number;
  activeUsers?: number;
  topEvent?: AnalyticsEventInput | null;
  events?: AnalyticsEventInput[];
};

export default function AnalyticsPage() {
  const query = useQuery({
    queryKey: ['analytics'],
    queryFn: () => apiGet<AnalyticsOverview>('/admin/analytics/overview')
  });

  const mappedEvents = useMemo(
    () => mapAnalyticsEvents(query.data?.events ?? [], query.data?.totalEvents),
    [query.data?.events, query.data?.totalEvents]
  );

  if (query.isLoading) return <AnalyticsPageSkeleton />;
  if (query.isError) {
    return <ErrorPanel message="Could not load Analytics data from admin-api." onRetry={() => void query.refetch()} />;
  }
  if (!query.data) {
    return <EmptyPanel title="No Analytics events" description="No Analytics events were received for the selected date range." />;
  }

  if (!query.data.configured) {
    return (
      <div className="space-y-6">
        <AnalyticsHeader
          connected={false}
          dataUpdatedAt={query.dataUpdatedAt}
          isRefreshing={query.isFetching}
          onRefresh={() => void query.refetch()}
        />
        <Card className="border-amber-200 bg-amber-50 text-amber-950 dark:border-amber-900 dark:bg-amber-950 dark:text-amber-100">
          <CardTitle>Analytics is not configured</CardTitle>
          <CardDescription className="mt-2 text-amber-800 dark:text-amber-200">
            {query.data.integrationStatus ?? 'Connect GA4 Data API credentials to view application analytics.'}
          </CardDescription>
          <Button variant="outline" className="mt-4 border-amber-300 bg-transparent" onClick={() => void query.refetch()}>
            Retry connection check
          </Button>
        </Card>
      </div>
    );
  }

  const totalEvents = query.data.totalEvents ?? mappedEvents.reduce((sum, event) => sum + event.count, 0);
  const activeUsers = query.data.activeUsers ?? 0;
  const topEvent = mappedEvents[0];

  return (
    <div className="space-y-6">
      <AnalyticsHeader
        connected
        dataUpdatedAt={query.dataUpdatedAt}
        isRefreshing={query.isFetching}
        onRefresh={() => void query.refetch()}
      />

      {!mappedEvents.length ? (
        <EmptyAnalyticsState onRefresh={() => void query.refetch()} />
      ) : (
        <>
          <AnalyticsKpiGrid
            events={mappedEvents}
            totalEvents={totalEvents}
            activeUsers={activeUsers}
            topEvent={topEvent}
            rangeLabel="Last 7 days"
          />

          <div className="grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(320px,1fr)]">
            <TopEventsChart events={mappedEvents} />
            <EventDistributionChart events={mappedEvents} totalEvents={totalEvents} />
          </div>

          <div className="grid gap-6 xl:grid-cols-[minmax(0,1.25fr)_minmax(360px,0.75fr)]">
            <EventEngagementScatter events={mappedEvents} />
            <LabEventsSummary events={mappedEvents} />
          </div>

          <AnalyticsEventsTable events={mappedEvents} />

          <ScreenReaderFallback events={mappedEvents} />
        </>
      )}
    </div>
  );
}

function AnalyticsHeader({
  connected,
  dataUpdatedAt,
  isRefreshing,
  onRefresh
}: {
  connected: boolean;
  dataUpdatedAt?: number;
  isRefreshing?: boolean;
  onRefresh: () => void;
}) {
  return (
    <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
      <div>
        <div className="flex items-center gap-2">
          <p className="text-sm font-medium text-[var(--primary)]">Monitoring</p>
          <Badge variant={connected ? 'success' : 'warning'}>{connected ? 'Connected' : 'Setup needed'}</Badge>
        </div>
        <h2 className="mt-1 text-3xl font-semibold tracking-normal">Analytics</h2>
        <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">
          Understand how users interact with SYNAPSE through Firebase Analytics events.
        </p>
      </div>
      <AnalyticsDateFilter
        rangeLabel="Last 7 days"
        lastUpdatedAt={dataUpdatedAt}
        isRefreshing={isRefreshing}
        onRefresh={onRefresh}
      />
    </div>
  );
}

function EmptyAnalyticsState({ onRefresh }: { onRefresh: () => void }) {
  return (
    <Card className="flex min-h-72 flex-col items-center justify-center text-center">
      <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--muted)]">
        <BarChart3 className="h-6 w-6 text-[var(--muted-foreground)]" />
      </div>
      <p className="mt-4 font-semibold">No Analytics events</p>
      <p className="mt-2 max-w-md text-sm text-[var(--muted-foreground)]">
        No Analytics events were received for the selected date range.
      </p>
      <Button className="mt-5" variant="outline" onClick={onRefresh}>
        Refresh
      </Button>
    </Card>
  );
}

function ScreenReaderFallback({ events }: { events: ReturnType<typeof mapAnalyticsEvents> }) {
  return (
    <table className="sr-only">
      <caption>Analytics events data table for screen readers</caption>
      <thead>
        <tr>
          <th>Event</th>
          <th>Category</th>
          <th>Event count</th>
          <th>Active users</th>
          <th>Share</th>
        </tr>
      </thead>
      <tbody>
        {events.map((event) => (
          <tr key={event.name}>
            <td>{event.name}</td>
            <td>{event.category}</td>
            <td>{event.count}</td>
            <td>{event.activeUsers}</td>
            <td>{event.percentage}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
