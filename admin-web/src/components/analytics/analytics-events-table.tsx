'use client';

import {
  ColumnDef,
  SortingState,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable
} from '@tanstack/react-table';
import { ArrowUpDown, ChevronLeft, ChevronRight, Search } from 'lucide-react';
import { useMemo, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { AnalyticsChartEvent } from '@/features/analytics/lib/analytics-chart.mapper';
import { decimalNumber, formatPercent, wholeNumber } from '@/lib/charts/formatters';
import { cn } from '@/lib/utils/cn';

type AnalyticsEventRow = AnalyticsChartEvent & {
  rank: number;
};

export function AnalyticsEventsTable({ events }: { events: AnalyticsChartEvent[] }) {
  const [sorting, setSorting] = useState<SortingState>([{ id: 'count', desc: true }]);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('all');

  const data = useMemo(
    () => events.map((event, index) => ({ ...event, rank: index + 1 })),
    [events]
  );

  const columns = useMemo<ColumnDef<AnalyticsEventRow>[]>(() => [
    {
      accessorKey: 'rank',
      header: 'Rank',
      cell: ({ row }) => <span className="text-[var(--muted-foreground)]">#{row.original.rank}</span>,
      enableSorting: false
    },
    {
      accessorKey: 'name',
      header: 'Event',
      cell: ({ row }) => <code className="rounded-md bg-[var(--muted)] px-2 py-1 text-xs">{row.original.name}</code>
    },
    {
      accessorKey: 'category',
      header: 'Category',
      cell: ({ row }) => <CategoryBadge category={row.original.category} />
    },
    {
      accessorKey: 'count',
      header: ({ column }) => <SortableHeader label="Event count" onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')} />,
      cell: ({ row }) => <span className="tabular-nums">{wholeNumber.format(row.original.count)}</span>
    },
    {
      accessorKey: 'activeUsers',
      header: ({ column }) => <SortableHeader label="Active users" onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')} />,
      cell: ({ row }) => <span className="tabular-nums">{wholeNumber.format(row.original.activeUsers)}</span>
    },
    {
      accessorKey: 'eventsPerUser',
      header: ({ column }) => <SortableHeader label="Events/user" onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')} />,
      cell: ({ row }) => <span className="tabular-nums">{decimalNumber.format(row.original.eventsPerUser)}</span>
    },
    {
      accessorKey: 'percentage',
      header: ({ column }) => <SortableHeader label="Share" onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')} />,
      cell: ({ row }) => (
        <div className="min-w-32">
          <div className="flex items-center justify-between gap-3">
            <span className="tabular-nums">{formatPercent(row.original.percentage)}</span>
          </div>
          <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-[var(--border)]">
            <div className="h-full rounded-full bg-[var(--primary)]" style={{ width: `${Math.min(row.original.percentage, 100)}%` }} />
          </div>
        </div>
      )
    }
  ], []);

  const filteredData = useMemo(() => {
    const needle = search.trim().toLowerCase();
    return data.filter((event) => {
      const matchesSearch = !needle || event.name.toLowerCase().includes(needle);
      const matchesCategory = category === 'all' || event.category === category;
      return matchesSearch && matchesCategory;
    });
  }, [category, data, search]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { sorting },
    onSortingChange: setSorting,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: { pagination: { pageSize: 8 } }
  });

  return (
    <Card>
      <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <div>
          <CardTitle>Events table</CardTitle>
          <CardDescription className="mt-2">Sortable event metrics with category and share</CardDescription>
        </div>
        <div className="grid gap-2 sm:grid-cols-[minmax(220px,1fr)_160px]">
          <label className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[var(--muted-foreground)]" />
            <Input className="pl-9" placeholder="Search event" value={search} onChange={(event) => setSearch(event.target.value)} />
          </label>
          <Select value={category} onChange={(event) => setCategory(event.target.value)} aria-label="Filter event category">
            <option value="all">All categories</option>
            <option value="lab">Lab events</option>
            <option value="automatic">Automatic</option>
            <option value="other">Other</option>
          </Select>
        </div>
      </div>

      <div className="mt-5 overflow-hidden rounded-xl border">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[940px] text-sm">
            <thead className="sticky top-0 bg-[var(--card)]">
              {table.getHeaderGroups().map((headerGroup) => (
                <tr key={headerGroup.id} className="border-b text-left text-xs uppercase tracking-wide text-[var(--muted-foreground)]">
                  {headerGroup.headers.map((header) => (
                    <th key={header.id} className="h-11 px-3 font-semibold">
                      {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody>
              {table.getRowModel().rows.length ? (
                table.getRowModel().rows.map((row, index) => (
                  <tr key={row.id} className={cn('h-[52px] border-b last:border-0 hover:bg-[var(--muted)]/55', index % 2 === 1 && 'bg-[var(--muted)]/25')}>
                    {row.getVisibleCells().map((cell) => (
                      <td key={cell.id} className="px-3 py-2 align-middle">
                        {flexRender(cell.column.columnDef.cell, cell.getContext())}
                      </td>
                    ))}
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={columns.length} className="h-32 text-center text-[var(--muted-foreground)]">No events match the current filters.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-sm text-[var(--muted-foreground)]">
          Showing {table.getRowModel().rows.length} of {filteredData.length} events
        </p>
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()} aria-label="Previous event page">
            <ChevronLeft className="h-4 w-4" />
            Previous
          </Button>
          <span className="text-sm text-[var(--muted-foreground)]">
            Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount() || 1}
          </span>
          <Button variant="outline" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()} aria-label="Next event page">
            Next
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </Card>
  );
}

function SortableHeader({ label, onClick }: { label: string; onClick: () => void }) {
  return (
    <button className="inline-flex items-center gap-1 hover:text-[var(--foreground)]" onClick={onClick}>
      {label}
      <ArrowUpDown className="h-3.5 w-3.5" />
    </button>
  );
}

function CategoryBadge({ category }: { category: AnalyticsChartEvent['category'] }) {
  if (category === 'lab') return <Badge variant="success">Lab event</Badge>;
  if (category === 'automatic') return <Badge variant="default">Automatic</Badge>;
  return <Badge variant="muted">Other</Badge>;
}
