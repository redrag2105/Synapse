'use client';

import { useQuery } from '@tanstack/react-query';
import { ReactNode } from 'react';
import { apiGet } from '@/lib/api/client';
import { EmptyState, ErrorState, LoadingState } from '@/components/ui/state';

export function DataSection<T>({
  queryKey,
  path,
  empty,
  children
}: {
  queryKey: string[];
  path: string;
  empty: string;
  children: (data: T) => ReactNode;
}) {
  const query = useQuery({ queryKey, queryFn: () => apiGet<T>(path) });
  if (query.isLoading) return <LoadingState />;
  if (query.isError) return <ErrorState message="Could not load data" onRetry={() => void query.refetch()} />;
  if (!query.data) return <EmptyState title={empty} />;
  return children(query.data);
}
