'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Bug, RefreshCw, ShieldAlert } from 'lucide-react';
import { toast } from 'sonner';
import { apiClient, apiGet } from '@/lib/api/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Select } from '@/components/ui/select';
import { EmptyPanel, ErrorPanel, PageSkeleton } from '@/components/states/page-states';

type CrashlyticsIssue = {
  id: string;
  title: string;
  exception: string | null;
  type: string;
  source: string | null;
  status: string;
  platform: string | null;
  uid: string | null;
  email: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

type CrashlyticsOverview = {
  configured: boolean;
  integrationStatus?: string;
  setup?: string;
  items?: CrashlyticsIssue[];
  count?: number;
};

export default function CrashlyticsPage() {
  const client = useQueryClient();
  const query = useQuery({
    queryKey: ['crashlytics'],
    queryFn: () => apiGet<CrashlyticsOverview>('/admin/crashlytics/issues')
  });

  const statusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      apiClient.patch(`/admin/crashlytics/issues/${id}/status`, { status }),
    onSuccess: async () => {
      toast.success('Issue status updated');
      await client.invalidateQueries({ queryKey: ['crashlytics'] });
    },
    onError: () => toast.error('Could not update issue status')
  });

  if (query.isLoading) return <PageSkeleton />;
  if (query.isError || !query.data) {
    return <ErrorPanel message="Crashlytics status could not be loaded." onRetry={() => void query.refetch()} />;
  }

  const data = query.data;
  const items = data.items ?? [];
  const openCount = items.filter((item) => item.status === 'open').length;
  const nonfatalCount = items.filter((item) => item.type === 'nonfatal').length;
  const fatalCount = items.filter((item) => item.type === 'fatal').length;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Monitoring</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Crashlytics</h2>
          <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">
            Track handled exceptions and test crashes mirrored from the mobile Profile tab.
          </p>
        </div>
        <Button variant="outline" onClick={() => void query.refetch()} disabled={query.isFetching}>
          <RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} />
          Refresh
        </Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <p className="text-sm text-[var(--muted-foreground)]">Events</p>
          <p className="mt-2 text-2xl font-semibold tabular-nums">{items.length}</p>
        </Card>
        <Card>
          <p className="text-sm text-[var(--muted-foreground)]">Open</p>
          <p className="mt-2 text-2xl font-semibold tabular-nums">{openCount}</p>
        </Card>
        <Card>
          <p className="text-sm text-[var(--muted-foreground)]">Non-fatal / Fatal</p>
          <p className="mt-2 text-2xl font-semibold tabular-nums">
            {nonfatalCount} / {fatalCount}
          </p>
        </Card>
      </div>

      <Card>
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="flex items-start gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-[var(--muted)]">
              <ShieldAlert className="h-6 w-6 text-[var(--primary)]" />
            </div>
            <div>
              <div className="flex flex-wrap items-center gap-2">
                <CardTitle>Crashlytics feed</CardTitle>
                <Badge variant={data.configured ? 'success' : 'warning'}>
                  {data.configured ? 'Connected' : 'Not configured'}
                </Badge>
              </div>
              <CardDescription className="mt-2">
                {data.integrationStatus ?? 'Crashlytics status is available from admin-api.'}
              </CardDescription>
              {data.setup ? <p className="mt-3 text-sm text-[var(--muted-foreground)]">{data.setup}</p> : null}
            </div>
          </div>
        </div>
      </Card>

      {!items.length ? (
        <EmptyPanel
          title="No Crashlytics events yet"
          description='Tap "Record handled exception" on the mobile Profile tab, then refresh this page.'
        />
      ) : (
        <Card>
          <div className="flex items-center gap-2">
            <Bug className="h-4 w-4 text-[var(--primary)]" />
            <CardTitle>Recent events</CardTitle>
            <Badge variant="muted">{items.length}</Badge>
          </div>
          <CardDescription className="mt-2">
            Newest first. Status changes are audited in adminAuditLogs.
          </CardDescription>
          <div className="mt-5 overflow-hidden rounded-xl border">
            <div className="overflow-x-auto">
              <table className="w-full min-w-[960px] text-sm">
                <thead className="bg-[var(--card)]">
                  <tr className="border-b text-left text-[var(--muted-foreground)]">
                    <th className="p-3">Event</th>
                    <th className="p-3">Type</th>
                    <th className="p-3">Platform</th>
                    <th className="p-3">User</th>
                    <th className="p-3">Created</th>
                    <th className="p-3">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {items.map((item) => (
                    <tr key={item.id} className="border-b last:border-0 hover:bg-[var(--muted)]/45">
                      <td className="p-3">
                        <p className="font-medium">{item.title}</p>
                        <p className="mt-1 max-w-md truncate text-xs text-[var(--muted-foreground)]" title={item.exception ?? undefined}>
                          {item.exception ?? item.source ?? item.id}
                        </p>
                      </td>
                      <td className="p-3">
                        <Badge variant={item.type === 'fatal' ? 'destructive' : 'warning'}>
                          {item.type === 'fatal' ? 'Fatal' : 'Non-fatal'}
                        </Badge>
                      </td>
                      <td className="p-3">
                        <Badge variant="muted">{item.platform ?? 'unknown'}</Badge>
                      </td>
                      <td className="p-3">
                        <p className="max-w-[180px] truncate">{item.email ?? 'Guest'}</p>
                        {item.uid ? (
                          <p className="mt-1 max-w-[180px] truncate text-xs text-[var(--muted-foreground)]" title={item.uid}>
                            {item.uid}
                          </p>
                        ) : null}
                      </td>
                      <td className="p-3 whitespace-nowrap">
                        {item.createdAt ? new Date(item.createdAt).toLocaleString() : '—'}
                      </td>
                      <td className="p-3">
                        <Select
                          className="w-[120px]"
                          value={item.status}
                          disabled={statusMutation.isPending}
                          aria-label={`Status for ${item.title}`}
                          onChange={(event) =>
                            statusMutation.mutate({ id: item.id, status: event.target.value })
                          }
                        >
                          <option value="open">Open</option>
                          <option value="closed">Closed</option>
                          <option value="muted">Muted</option>
                        </Select>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </Card>
      )}
    </div>
  );
}
