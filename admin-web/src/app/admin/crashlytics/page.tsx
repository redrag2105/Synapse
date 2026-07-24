'use client';

import { RefreshCw, ShieldAlert } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { apiGet } from '@/lib/api/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { EmptyPanel, ErrorPanel, PageSkeleton } from '@/components/states/page-states';

type CrashlyticsOverview = {
  configured: boolean;
  integrationStatus?: string;
  setup?: string;
  items?: unknown[];
};

export default function CrashlyticsPage() {
  const query = useQuery({
    queryKey: ['crashlytics'],
    queryFn: () => apiGet<CrashlyticsOverview>('/admin/crashlytics/issues')
  });

  if (query.isLoading) return <PageSkeleton />;
  if (query.isError || !query.data) {
    return <ErrorPanel message="Crashlytics status could not be loaded." onRetry={() => void query.refetch()} />;
  }

  const data = query.data;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Monitoring</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Crashlytics</h2>
          <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">
            Track app stability, crash export status and issue readiness.
          </p>
        </div>
        <Button variant="outline" onClick={() => void query.refetch()} disabled={query.isFetching}>
          <RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} />
          Refresh
        </Button>
      </div>

      <Card>
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[var(--muted)]">
              <ShieldAlert className="h-6 w-6 text-[var(--primary)]" />
            </div>
            <div>
              <div className="flex flex-wrap items-center gap-2">
                <CardTitle>Crashlytics export</CardTitle>
                <Badge variant={data.configured ? 'success' : 'warning'}>{data.configured ? 'Connected' : 'Not configured'}</Badge>
              </div>
              <CardDescription className="mt-2">
                {data.integrationStatus ?? 'Crashlytics status is available from admin-api.'}
              </CardDescription>
              {data.setup ? <p className="mt-3 text-sm text-[var(--muted-foreground)]">{data.setup}</p> : null}
            </div>
          </div>
        </div>
      </Card>

      {data.configured && (!data.items || data.items.length === 0) ? (
        <EmptyPanel
          title="Crashlytics is connected. Waiting for the first exported crash event."
          description="Issues will appear here after Firebase exports crash data to the configured source."
        />
      ) : null}
    </div>
  );
}
