'use client';

import { useMemo, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Code2, RefreshCw, Save, ShieldCheck } from 'lucide-react';
import { toast } from 'sonner';
import { apiClient, apiGet } from '@/lib/api/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { EmptyPanel, ErrorPanel, PageSkeleton } from '@/components/states/page-states';

type RemoteConfigTemplate = {
  etag?: string;
  version?: { versionNumber?: string; updateTime?: string };
  parameters?: Record<string, { defaultValue?: { value?: string }; description?: string; conditionalValues?: unknown }>;
  conditions?: unknown[];
  parameterGroups?: Record<string, unknown>;
  requiredLabKeys?: string[];
};

export default function RemoteConfigPage() {
  const query = useQuery({ queryKey: ['remote-config'], queryFn: () => apiGet<RemoteConfigTemplate>('/admin/remote-config') });
  const [text, setText] = useState('');
  const [search, setSearch] = useState('');

  const value = text || JSON.stringify(query.data, null, 2);
  const parameters = query.data?.parameters ?? {};
  const rows = useMemo(() => Object.entries(parameters)
    .map(([key, parameter]) => ({ key, value: parameter.defaultValue?.value ?? '', description: parameter.description ?? '', type: inferType(parameter.defaultValue?.value ?? '') }))
    .filter((row) => !search || row.key.toLowerCase().includes(search.toLowerCase()) || row.value.toLowerCase().includes(search.toLowerCase())), [parameters, search]);

  if (query.isLoading) return <PageSkeleton />;
  if (query.isError) return <ErrorPanel message="Could not load Remote Config template." onRetry={() => void query.refetch()} />;

  async function call(path: string) {
    try {
      const parsed = JSON.parse(value) as { parameters: unknown; conditions?: unknown[]; parameterGroups?: unknown; etag: string };
      await apiClient.post(`/admin/remote-config/${path}`, parsed);
      toast.success(path === 'publish' ? 'Remote Config published' : 'Remote Config is valid');
      await query.refetch();
    } catch {
      toast.error(path === 'publish' ? 'Publish failed' : 'Validation failed');
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Firebase Management</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Remote Config</h2>
          <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">Validate and publish Firebase Remote Config templates with ETag protection.</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Badge variant="success">Active</Badge>
          <Button variant="outline" onClick={() => void query.refetch()} disabled={query.isFetching}><RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} /> Refresh</Button>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card><p className="text-sm text-[var(--muted-foreground)]">Version</p><p className="mt-2 text-2xl font-semibold">{query.data?.version?.versionNumber ?? '-'}</p></Card>
        <Card><p className="text-sm text-[var(--muted-foreground)]">Parameters</p><p className="mt-2 text-2xl font-semibold">{Object.keys(parameters).length}</p></Card>
        <Card><p className="text-sm text-[var(--muted-foreground)]">Required Lab keys</p><p className="mt-2 text-2xl font-semibold">{query.data?.requiredLabKeys?.length ?? 0}</p></Card>
      </div>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_520px]">
        <Card>
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <CardTitle>Parameters</CardTitle>
              <CardDescription className="mt-2">Default values currently active in Firebase Remote Config.</CardDescription>
            </div>
            <Input className="sm:max-w-xs" placeholder="Search parameter" value={search} onChange={(event) => setSearch(event.target.value)} />
          </div>
          {!rows.length ? <div className="mt-5"><EmptyPanel title="No parameters found" description="Try another keyword or refresh the template." /></div> : (
            <div className="mt-5 overflow-x-auto">
              <table className="w-full min-w-[760px] text-sm">
                <thead><tr className="border-b text-left text-[var(--muted-foreground)]"><th className="p-3">Key</th><th className="p-3">Value</th><th className="p-3">Type</th><th className="p-3">Description</th></tr></thead>
                <tbody>{rows.map((row) => <tr key={row.key} className="border-b last:border-0"><td className="p-3 font-mono font-medium">{row.key}</td><td className="p-3 font-mono">{row.value}</td><td className="p-3"><Badge variant="muted">{row.type}</Badge></td><td className="p-3 text-[var(--muted-foreground)]">{row.description || '-'}</td></tr>)}</tbody>
              </table>
            </div>
          )}
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>JSON preview</CardTitle>
              <CardDescription className="mt-2">Validate before publishing. Edits are not published automatically.</CardDescription>
            </div>
            <Code2 className="h-5 w-5 text-[var(--muted-foreground)]" />
          </div>
          <Textarea className="mt-4 min-h-[520px] font-mono text-xs" value={value} onChange={(event) => setText(event.target.value)} />
          <div className="mt-4 flex flex-wrap gap-2">
            <Button variant="outline" onClick={() => call('validate')}><ShieldCheck className="h-4 w-4" /> Validate</Button>
            <Button onClick={() => confirm('Publish Remote Config template?') && call('publish')}><Save className="h-4 w-4" /> Publish</Button>
          </div>
        </Card>
      </div>
    </div>
  );
}

function inferType(value: string) {
  if (value === 'true' || value === 'false') return 'boolean';
  if (value.trim() !== '' && !Number.isNaN(Number(value))) return 'number';
  return 'string';
}
