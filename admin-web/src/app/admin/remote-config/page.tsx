'use client';

import { useEffect, useMemo, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { ChevronDown, ChevronRight, Code2, RefreshCw, Save, ShieldCheck } from 'lucide-react';
import { toast } from 'sonner';
import { apiClient, apiGet } from '@/lib/api/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { EmptyPanel, ErrorPanel, PageSkeleton } from '@/components/states/page-states';
import { cn } from '@/lib/utils/cn';

type ParameterValue = {
  defaultValue?: { value?: string };
  description?: string;
  conditionalValues?: unknown;
  valueType?: string;
};

type RemoteConfigTemplate = {
  etag?: string;
  version?: { versionNumber?: string; updateTime?: string };
  parameters?: Record<string, ParameterValue>;
  conditions?: unknown[];
  parameterGroups?: Record<string, unknown>;
  requiredLabKeys?: string[];
};

type PublishPayload = {
  parameters: Record<string, unknown>;
  conditions?: unknown[];
  parameterGroups?: unknown;
  etag: string;
};

function cloneTemplate(template: RemoteConfigTemplate): RemoteConfigTemplate {
  return structuredClone(template);
}

function inferType(value: string) {
  if (value === 'true' || value === 'false') return 'boolean';
  if (value.trim() !== '' && !Number.isNaN(Number(value))) return 'number';
  return 'string';
}

function toPublishPayload(template: RemoteConfigTemplate): PublishPayload {
  if (!template.etag) {
    throw new Error('Missing ETag');
  }
  return {
    etag: template.etag,
    parameters: template.parameters ?? {},
    conditions: template.conditions ?? [],
    parameterGroups: template.parameterGroups ?? {}
  };
}

export default function RemoteConfigPage() {
  const query = useQuery({
    queryKey: ['remote-config'],
    queryFn: () => apiGet<RemoteConfigTemplate>('/admin/remote-config')
  });

  const [draft, setDraft] = useState<RemoteConfigTemplate | null>(null);
  const [dirty, setDirty] = useState(false);
  const [search, setSearch] = useState('');
  const [jsonOpen, setJsonOpen] = useState(false);
  const [jsonText, setJsonText] = useState('');
  const [jsonError, setJsonError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [confirmPublish, setConfirmPublish] = useState(false);

  useEffect(() => {
    if (!query.data || dirty) return;
    const next = cloneTemplate(query.data);
    setDraft(next);
    setJsonText(JSON.stringify(next, null, 2));
    setJsonError(null);
  }, [query.data, dirty]);

  const parameters = draft?.parameters ?? {};
  const rows = useMemo(
    () =>
      Object.entries(parameters)
        .map(([key, parameter]) => ({
          key,
          value: parameter.defaultValue?.value ?? '',
          description: parameter.description ?? '',
          type: inferType(parameter.defaultValue?.value ?? '')
        }))
        .filter(
          (row) =>
            !search ||
            row.key.toLowerCase().includes(search.toLowerCase()) ||
            row.value.toLowerCase().includes(search.toLowerCase()) ||
            row.description.toLowerCase().includes(search.toLowerCase())
        ),
    [parameters, search]
  );

  function syncJsonFromDraft(nextDraft: RemoteConfigTemplate) {
    setJsonText(JSON.stringify(nextDraft, null, 2));
    setJsonError(null);
  }

  function updateParameterValue(key: string, value: string) {
    setDraft((current) => {
      if (!current) return current;
      const next = cloneTemplate(current);
      const existing = next.parameters?.[key] ?? {};
      next.parameters = {
        ...(next.parameters ?? {}),
        [key]: {
          ...existing,
          defaultValue: {
            ...(existing.defaultValue ?? {}),
            value
          }
        }
      };
      syncJsonFromDraft(next);
      return next;
    });
    setDirty(true);
  }

  function applyJsonText(text: string): RemoteConfigTemplate | null {
    try {
      const parsed = JSON.parse(text) as RemoteConfigTemplate;
      if (!parsed || typeof parsed !== 'object' || !parsed.parameters || typeof parsed.parameters !== 'object') {
        setJsonError('JSON must include a parameters object.');
        return null;
      }
      if (!parsed.etag || typeof parsed.etag !== 'string') {
        setJsonError('JSON must include the current etag string.');
        return null;
      }
      setDraft(cloneTemplate(parsed));
      setJsonError(null);
      setDirty(true);
      return parsed;
    } catch {
      setJsonError('Invalid JSON. Fix the syntax before validating or publishing.');
      return null;
    }
  }

  function openJsonPanel() {
    if (draft) syncJsonFromDraft(draft);
    setJsonOpen(true);
  }

  function closeJsonPanel() {
    if (jsonText.trim()) {
      const parsed = applyJsonText(jsonText);
      if (!parsed) return;
    }
    setJsonOpen(false);
  }

  async function refresh() {
    setDirty(false);
    setJsonError(null);
    await query.refetch();
  }

  async function call(path: 'validate' | 'publish') {
    if (!draft) return;
    const source = jsonOpen ? applyJsonText(jsonText) : draft;
    if (!source) {
      toast.error('Fix JSON errors before continuing');
      return;
    }

    setBusy(true);
    try {
      const payload = toPublishPayload(source);
      await apiClient.post(`/admin/remote-config/${path}`, payload);
      toast.success(path === 'publish' ? 'Remote Config published' : 'Remote Config is valid');
      setDirty(false);
      setConfirmPublish(false);
      await query.refetch();
    } catch {
      toast.error(path === 'publish' ? 'Publish failed' : 'Validation failed');
    } finally {
      setBusy(false);
    }
  }

  if (query.isLoading && !draft) return <PageSkeleton />;
  if (query.isError && !draft) {
    return <ErrorPanel message="Could not load Remote Config template." onRetry={() => void query.refetch()} />;
  }
  if (!draft) return <PageSkeleton />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Firebase Management</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Remote Config</h2>
          <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">
            Edit parameter values in the GUI or JSON editor, then validate and publish with ETag protection.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {dirty ? <Badge variant="warning">Unsaved edits</Badge> : <Badge variant="success">In sync</Badge>}
          <Button variant="outline" onClick={() => void refresh()} disabled={query.isFetching || busy}>
            <RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} /> Refresh
          </Button>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <p className="text-sm text-[var(--muted-foreground)]">Version</p>
          <p className="mt-2 text-2xl font-semibold">{draft.version?.versionNumber ?? '-'}</p>
        </Card>
        <Card>
          <p className="text-sm text-[var(--muted-foreground)]">Parameters</p>
          <p className="mt-2 text-2xl font-semibold">{Object.keys(parameters).length}</p>
        </Card>
        <Card>
          <p className="text-sm text-[var(--muted-foreground)]">Required Lab keys</p>
          <p className="mt-2 text-2xl font-semibold">{draft.requiredLabKeys?.length ?? 0}</p>
        </Card>
      </div>

      <Card>
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <CardTitle>Parameters</CardTitle>
            <CardDescription className="mt-2">
              Edit default values directly. Changes stay local until you publish.
            </CardDescription>
          </div>
          <Input
            className="sm:max-w-xs"
            placeholder="Search parameter"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
          />
        </div>

        {!rows.length ? (
          <div className="mt-5">
            <EmptyPanel title="No parameters found" description="Try another keyword or refresh the template." />
          </div>
        ) : (
          <div className="mt-5 overflow-x-auto">
            <table className="w-full min-w-[860px] text-sm">
              <thead>
                <tr className="border-b text-left text-[var(--muted-foreground)]">
                  <th className="p-3">Key</th>
                  <th className="p-3">Value</th>
                  <th className="p-3">Type</th>
                  <th className="p-3">Description</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.key} className="border-b last:border-0 align-top">
                    <td className="p-3 font-mono font-medium">{row.key}</td>
                    <td className="p-3">
                      <Input
                        className="font-mono"
                        value={row.value}
                        onChange={(event) => updateParameterValue(row.key, event.target.value)}
                        aria-label={`Value for ${row.key}`}
                      />
                    </td>
                    <td className="p-3">
                      <Badge variant="muted">{inferType(row.value)}</Badge>
                    </td>
                    <td className="p-3 text-[var(--muted-foreground)]">{row.description || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <div className="mt-5 flex flex-wrap gap-2">
          <Button variant="outline" disabled={busy} onClick={() => void call('validate')}>
            <ShieldCheck className="h-4 w-4" /> Validate
          </Button>
          <Button disabled={busy} onClick={() => setConfirmPublish(true)}>
            <Save className="h-4 w-4" /> Publish
          </Button>
        </div>
      </Card>

      <Card className="overflow-hidden p-0">
        <button
          type="button"
          className="flex w-full items-center justify-between gap-3 px-5 py-4 text-left hover:bg-[var(--muted)]/60"
          onClick={() => (jsonOpen ? closeJsonPanel() : openJsonPanel())}
          aria-expanded={jsonOpen}
        >
          <div className="flex min-w-0 items-start gap-3">
            <div className="mt-0.5 text-[var(--muted-foreground)]">
              {jsonOpen ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <CardTitle>JSON view</CardTitle>
                <Code2 className="h-4 w-4 text-[var(--muted-foreground)]" />
              </div>
              <CardDescription className="mt-1">
                {jsonOpen
                  ? 'Advanced template editor. Closing applies valid JSON back to the GUI.'
                  : 'Collapsed by default. Open to inspect or edit the full template JSON.'}
              </CardDescription>
            </div>
          </div>
          <Badge variant="muted">{jsonOpen ? 'Expanded' : 'Collapsed'}</Badge>
        </button>

        <div
          className={cn(
            'grid transition-[grid-template-rows] duration-200 ease-out',
            jsonOpen ? 'grid-rows-[1fr]' : 'grid-rows-[0fr]'
          )}
        >
          <div className="overflow-hidden">
            <div className="space-y-3 border-t px-5 py-4">
              <Textarea
                className="min-h-[320px] font-mono text-xs"
                value={jsonText}
                onChange={(event) => {
                  setJsonText(event.target.value);
                  setDirty(true);
                  setJsonError(null);
                }}
                onBlur={() => {
                  if (jsonText.trim()) applyJsonText(jsonText);
                }}
                spellCheck={false}
              />
              {jsonError ? <p className="text-xs text-[var(--destructive)]">{jsonError}</p> : null}
              <div className="flex flex-wrap gap-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => {
                    if (draft) syncJsonFromDraft(draft);
                  }}
                >
                  Reset from GUI
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => {
                    if (applyJsonText(jsonText)) toast.success('JSON applied to GUI');
                  }}
                >
                  Apply JSON to GUI
                </Button>
              </div>
            </div>
          </div>
        </div>
      </Card>

      <ConfirmDialog
        open={confirmPublish}
        title="Publish Remote Config?"
        description="This updates the live Firebase Remote Config template for all clients. Continue only if you have validated the changes."
        confirmLabel="Publish now"
        confirming={busy}
        onCancel={() => {
          if (busy) return;
          setConfirmPublish(false);
        }}
        onConfirm={() => {
          void call('publish');
        }}
      />
    </div>
  );
}
