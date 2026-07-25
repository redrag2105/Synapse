'use client';

import { FormEvent, useCallback, useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { ChevronLeft, ChevronRight, ChevronsLeft, Copy, Download, Eye, FileText, RefreshCw, Search, Trash2 } from 'lucide-react';
import { toast } from 'sonner';
import { apiClient, apiGet } from '@/lib/api/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { PdfPreviewDialog } from '@/components/ui/pdf-preview-dialog';
import { EmptyPanel, ErrorPanel, PageSkeleton } from '@/components/states/page-states';

type Report = {
  name: string;
  fullPath: string;
  ownerUid: string | null;
  size: number;
  created: string | null;
  updated?: string | null;
};

type ReportsResponse = {
  items: Report[];
  pageToken: string | null;
};

type PdfPreviewState = {
  report: Report;
  url: string | null;
  loading: boolean;
  error: string | null;
};

const pageSizeOptions = [10, 25, 50, 100];

export default function ReportsPage() {
  const [searchInput, setSearchInput] = useState('');
  const [ownerInput, setOwnerInput] = useState('');
  const [search, setSearch] = useState('');
  const [ownerUid, setOwnerUid] = useState('');
  const [pageSize, setPageSize] = useState(25);
  const [pageIndex, setPageIndex] = useState(0);
  const [pageTokens, setPageTokens] = useState<(string | null)[]>([null]);
  const [preview, setPreview] = useState<PdfPreviewState | null>(null);
  const client = useQueryClient();
  const currentPageToken = pageTokens[pageIndex] ?? null;

  const query = useQuery({
    queryKey: ['reports', { pageSize, pageToken: currentPageToken, search, ownerUid }],
    queryFn: () => apiGet<ReportsResponse>(`/admin/reports?${buildReportQuery({ limit: pageSize, pageToken: currentPageToken, search, uid: ownerUid })}`)
  });

  const deleteMutation = useMutation({
    mutationFn: (path: string) => apiClient.delete('/admin/reports', { params: { path } }),
    onSuccess: async () => {
      toast.success('Report deleted');
      await client.invalidateQueries({ queryKey: ['reports'] });
    },
    onError: () => toast.error('Could not delete report')
  });

  const reports = query.data?.items ?? [];
  const totalBytesOnPage = useMemo(() => reports.reduce((sum, report) => sum + report.size, 0), [reports]);
  const hasNextPage = Boolean(query.data?.pageToken);
  const hasPreviousPage = pageIndex > 0;
  const activeFilterCount = Number(Boolean(search)) + Number(Boolean(ownerUid));

  function applyFilters(event?: FormEvent<HTMLFormElement>) {
    event?.preventDefault();
    setSearch(searchInput.trim());
    setOwnerUid(ownerInput.trim());
    resetPagination();
  }

  function clearFilters() {
    setSearchInput('');
    setOwnerInput('');
    setSearch('');
    setOwnerUid('');
    resetPagination();
  }

  function resetPagination() {
    setPageIndex(0);
    setPageTokens([null]);
  }

  function goFirst() {
    resetPagination();
  }

  function goPrevious() {
    if (!hasPreviousPage) return;
    setPageIndex((value) => Math.max(0, value - 1));
  }

  function goNext() {
    const nextToken = query.data?.pageToken;
    if (!nextToken) return;
    setPageTokens((tokens) => {
      const next = tokens.slice(0, pageIndex + 1);
      next[pageIndex + 1] = nextToken;
      return next;
    });
    setPageIndex((value) => value + 1);
  }

  async function copyUrl(path: string, open = false) {
    const data = await apiGet<{ url: string }>(`/admin/reports/download-url?path=${encodeURIComponent(path)}`);
    await navigator.clipboard.writeText(data.url);
    toast.success('Signed URL copied');
    if (open) window.open(data.url, '_blank', 'noopener,noreferrer');
  }

  const loadPreviewUrl = useCallback(async (report: Report) => {
    setPreview({ report, url: null, loading: true, error: null });
    try {
      const data = await apiGet<{ url: string }>(
        `/admin/reports/download-url?path=${encodeURIComponent(report.fullPath)}&inline=1`
      );
      setPreview({ report, url: data.url, loading: false, error: null });
    } catch {
      setPreview({
        report,
        url: null,
        loading: false,
        error: 'Could not load a signed URL for this PDF.'
      });
    }
  }, []);

  function closePreview() {
    setPreview(null);
  }

  if (query.isLoading && !query.data) return <PageSkeleton />;
  if (query.isError) return <ErrorPanel message="Could not load Firebase Storage reports." onRetry={() => void query.refetch()} />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Firebase Management</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Reports & Storage</h2>
          <p className="mt-2 text-sm text-[var(--muted-foreground)]">Browse exported PDF reports under the configured Storage prefix.</p>
        </div>
        <Button variant="outline" onClick={() => void query.refetch()} disabled={query.isFetching}>
          <RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} />
          Refresh
        </Button>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card><p className="text-sm text-[var(--muted-foreground)]">Files on page</p><p className="mt-2 text-2xl font-semibold tabular-nums">{reports.length}</p></Card>
        <Card><p className="text-sm text-[var(--muted-foreground)]">Page storage</p><p className="mt-2 text-2xl font-semibold tabular-nums">{Math.round(totalBytesOnPage / 1024).toLocaleString()} KB</p></Card>
        <Card><p className="text-sm text-[var(--muted-foreground)]">Current page</p><p className="mt-2 text-2xl font-semibold tabular-nums">Page {pageIndex + 1}</p></Card>
      </div>

      <Card>
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
            <div>
              <div className="flex items-center gap-2">
                <CardTitle>PDF reports</CardTitle>
                {activeFilterCount ? <Badge variant="muted">{activeFilterCount} filters</Badge> : null}
              </div>
              <CardDescription className="mt-2">Click a report name to preview the PDF. Signed URLs are generated on demand.</CardDescription>
            </div>
            <div className="flex items-center gap-2 text-sm text-[var(--muted-foreground)]">
              <span>Rows per page</span>
              <Select
                className="w-24"
                value={String(pageSize)}
                onChange={(event) => {
                  setPageSize(Number(event.target.value));
                  resetPagination();
                }}
                aria-label="Rows per page"
              >
                {pageSizeOptions.map((option) => <option key={option} value={option}>{option}</option>)}
              </Select>
            </div>
          </div>

          <form className="grid gap-3 lg:grid-cols-[minmax(220px,1fr)_minmax(220px,320px)_auto_auto]" onSubmit={applyFilters}>
            <label className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[var(--muted-foreground)]" />
              <Input className="pl-9" placeholder="Search report name or path" value={searchInput} onChange={(event) => setSearchInput(event.target.value)} />
            </label>
            <Input placeholder="Filter by owner UID" value={ownerInput} onChange={(event) => setOwnerInput(event.target.value)} />
            <Button type="submit">Apply</Button>
            <Button type="button" variant="ghost" onClick={clearFilters} disabled={!searchInput && !ownerInput && !search && !ownerUid}>Clear</Button>
          </form>
        </div>

        {!reports.length ? (
          <div className="mt-5"><EmptyPanel title="No reports found" description="Exported PDFs from the mobile app will appear here, or try another search/page." /></div>
        ) : (
          <div className="mt-5 overflow-hidden rounded-xl border">
            <div className="overflow-x-auto">
              <table className="w-full min-w-[960px] text-sm">
                <thead className="sticky top-0 bg-[var(--card)]">
                  <tr className="border-b text-left text-[var(--muted-foreground)]">
                    <th className="p-3">Name</th>
                    <th className="p-3">Owner</th>
                    <th className="p-3">Path</th>
                    <th className="p-3">Size</th>
                    <th className="p-3">Created</th>
                    <th className="p-3 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {reports.map((report) => (
                    <tr key={report.fullPath} className="border-b last:border-0 hover:bg-[var(--muted)]/45">
                      <td className="p-3">
                        <button
                          type="button"
                          className="flex max-w-full items-center gap-3 rounded-lg text-left transition-colors hover:text-[var(--primary)] focus:outline-none focus:ring-2 focus:ring-[var(--ring)]"
                          onClick={() => void loadPreviewUrl(report)}
                          aria-label={`Preview ${report.name}`}
                        >
                          <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-[var(--muted)]">
                            <FileText className="h-4 w-4 text-[var(--primary)]" />
                          </span>
                          <span className="max-w-[260px] truncate font-medium underline-offset-2 hover:underline">{report.name}</span>
                        </button>
                      </td>
                      <td className="p-3"><Badge variant="muted">{report.ownerUid ?? 'unknown'}</Badge></td>
                      <td className="max-w-sm truncate p-3 text-[var(--muted-foreground)]" title={report.fullPath}>{report.fullPath}</td>
                      <td className="p-3 tabular-nums">{Math.round(report.size / 1024).toLocaleString()} KB</td>
                      <td className="p-3">{report.created ? new Date(report.created).toLocaleString() : '-'}</td>
                      <td className="p-3">
                        <div className="flex justify-end gap-2">
                          <Button size="icon" variant="outline" aria-label={`Preview ${report.name}`} onClick={() => void loadPreviewUrl(report)}><Eye className="h-4 w-4" /></Button>
                          <Button size="icon" variant="outline" aria-label={`Download ${report.name}`} onClick={() => copyUrl(report.fullPath, true)}><Download className="h-4 w-4" /></Button>
                          <Button size="icon" variant="outline" aria-label={`Copy signed URL for ${report.name}`} onClick={() => copyUrl(report.fullPath)}><Copy className="h-4 w-4" /></Button>
                          <Button size="icon" variant="destructive" aria-label={`Delete ${report.name}`} onClick={() => confirm('Delete this report?') && deleteMutation.mutate(report.fullPath)}><Trash2 className="h-4 w-4" /></Button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        <div className="mt-4 flex flex-col gap-3 border-t pt-4 lg:flex-row lg:items-center lg:justify-between">
          <div className="text-sm text-[var(--muted-foreground)]">
            Showing <span className="font-medium tabular-nums text-[var(--foreground)]">{reports.length}</span> reports on page <span className="font-medium tabular-nums text-[var(--foreground)]">{pageIndex + 1}</span>
            {query.isFetching ? <span className="ml-2">Updating...</span> : null}
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <Button variant="outline" onClick={goFirst} disabled={!hasPreviousPage || query.isFetching} aria-label="Go to first reports page">
              <ChevronsLeft className="h-4 w-4" />
              First
            </Button>
            <Button variant="outline" onClick={goPrevious} disabled={!hasPreviousPage || query.isFetching} aria-label="Go to previous reports page">
              <ChevronLeft className="h-4 w-4" />
              Previous
            </Button>
            <Badge variant="muted">Page {pageIndex + 1}</Badge>
            <Button variant="outline" onClick={goNext} disabled={!hasNextPage || query.isFetching} aria-label="Go to next reports page">
              Next
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </Card>

      <PdfPreviewDialog
        open={Boolean(preview)}
        title={preview?.report.name ?? 'PDF'}
        url={preview?.url ?? null}
        loading={preview?.loading ?? false}
        error={preview?.error ?? null}
        onClose={closePreview}
        onRetry={preview ? () => void loadPreviewUrl(preview.report) : undefined}
      />
    </div>
  );
}

function buildReportQuery({
  limit,
  pageToken,
  search,
  uid
}: {
  limit: number;
  pageToken: string | null;
  search: string;
  uid: string;
}) {
  const params = new URLSearchParams({ limit: String(limit) });
  if (pageToken) params.set('pageToken', pageToken);
  if (search) params.set('search', search);
  if (uid) params.set('uid', uid);
  return params.toString();
}
