'use client';

import { RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Select } from '@/components/ui/select';

export function AnalyticsDateFilter({
  rangeLabel,
  lastUpdatedAt,
  isRefreshing,
  onRefresh
}: {
  rangeLabel: string;
  lastUpdatedAt?: number;
  isRefreshing?: boolean;
  onRefresh: () => void;
}) {
  return (
    <div className="flex flex-col items-start gap-2 sm:items-end">
      <div className="flex flex-wrap items-center justify-end gap-2">
        <Select defaultValue="last-7-days" aria-label="Analytics date range" className="w-[150px]">
          <option value="last-7-days">{rangeLabel}</option>
          <option value="last-30-days" disabled>Last 30 days</option>
          <option value="last-90-days" disabled>Last 90 days</option>
        </Select>
        <Button variant="outline" onClick={onRefresh} disabled={isRefreshing} aria-label="Refresh analytics">
          <RefreshCw className={isRefreshing ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} />
          Refresh
        </Button>
      </div>
      {lastUpdatedAt ? (
        <p className="text-xs text-[var(--muted-foreground)]">Last updated {new Date(lastUpdatedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
      ) : null}
    </div>
  );
}
