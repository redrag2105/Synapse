'use client';

import { BellRing, FileText, RefreshCw, UserPlus, Users } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { apiGet } from '@/lib/api/client';
import { Button } from '@/components/ui/button';
import { ErrorPanel, PageSkeleton } from '@/components/states/page-states';
import { FirebaseServicesCard } from '@/components/dashboard/firebase-services-card';
import { MetricCard } from '@/components/dashboard/metric-card';
import { UserGrowthChart } from '@/components/dashboard/user-growth-chart';

type Overview = {
  users: {
    total: number;
    active: number;
    disabled: number;
    newIn7Days: number;
    newByDay: { date: string; count: number }[];
  };
  notifications: { campaigns: number; successCount: number; failureCount: number };
  reports: { count: number; totalBytes: number };
  analytics: { configured: boolean; integrationStatus?: string };
  crashlytics: { configured: boolean; integrationStatus?: string };
};

export default function DashboardPage() {
  const query = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => apiGet<Overview>('/admin/dashboard/overview')
  });

  if (query.isLoading) return <PageSkeleton />;
  if (query.isError || !query.data) {
    return <ErrorPanel message="Dashboard overview could not be loaded from admin-api." onRetry={() => void query.refetch()} />;
  }

  const data = query.data;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Overview</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Dashboard</h2>
          <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">
            Monitor Firebase users, notifications, reports and application health.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <div className="rounded-lg border bg-[var(--card)] px-3 py-2 text-sm text-[var(--muted-foreground)]">Last 7 days</div>
          <Button variant="outline" onClick={() => void query.refetch()} disabled={query.isFetching}>
            <RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} />
            Refresh
          </Button>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard title="Total users" value={data.users.total} description={`${data.users.active} active users`} icon={Users} status="default" />
        <MetricCard title="New users" value={data.users.newIn7Days} description="Last 7 days" icon={UserPlus} status="success" />
        <MetricCard title="Notifications" value={data.notifications.campaigns} description={`${data.notifications.successCount} sent · ${data.notifications.failureCount} failed`} icon={BellRing} status={data.notifications.failureCount > 0 ? 'warning' : 'default'} />
        <MetricCard title="PDF reports" value={data.reports.count} description={`${Math.round(data.reports.totalBytes / 1024).toLocaleString()} KB total`} icon={FileText} status="default" />
      </div>

      <div className="grid gap-6 xl:grid-cols-[2fr_1fr]">
        <UserGrowthChart data={data.users.newByDay} />
        <FirebaseServicesCard analytics={data.analytics} crashlytics={data.crashlytics} />
      </div>
    </div>
  );
}
