import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

export function AnalyticsChartSkeleton() {
  return (
    <Card>
      <Skeleton className="h-5 w-36" />
      <Skeleton className="mt-3 h-4 w-56" />
      <Skeleton className="mt-5 h-80 w-full" />
    </Card>
  );
}

export function AnalyticsPageSkeleton() {
  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <Card key={index}>
            <Skeleton className="h-10 w-10 rounded-xl" />
            <Skeleton className="mt-5 h-4 w-24" />
            <Skeleton className="mt-3 h-9 w-20" />
            <Skeleton className="mt-3 h-3 w-32" />
          </Card>
        ))}
      </div>
      <div className="grid gap-6 xl:grid-cols-[minmax(0,2fr)_minmax(320px,1fr)]">
        <AnalyticsChartSkeleton />
        <AnalyticsChartSkeleton />
      </div>
      <AnalyticsChartSkeleton />
    </div>
  );
}
