import { AlertCircle, Inbox, RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

export function PageSkeleton() {
  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {Array.from({ length: 4 }).map((_, index) => (
          <Card key={index}>
            <Skeleton className="h-4 w-24" />
            <Skeleton className="mt-4 h-9 w-20" />
            <Skeleton className="mt-3 h-3 w-32" />
          </Card>
        ))}
      </div>
      <Card>
        <Skeleton className="h-5 w-40" />
        <Skeleton className="mt-4 h-72 w-full" />
      </Card>
    </div>
  );
}

export function EmptyPanel({ title, description }: { title: string; description?: string }) {
  return (
    <Card className="flex min-h-52 flex-col items-center justify-center text-center">
      <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[var(--muted)]">
        <Inbox className="h-5 w-5 text-[var(--muted-foreground)]" />
      </div>
      <p className="mt-4 font-semibold">{title}</p>
      {description ? <p className="mt-2 max-w-md text-sm text-[var(--muted-foreground)]">{description}</p> : null}
    </Card>
  );
}

export function ErrorPanel({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <Card className="flex min-h-52 flex-col items-center justify-center gap-3 text-center">
      <div className="flex h-11 w-11 items-center justify-center rounded-full bg-rose-100 dark:bg-rose-950">
        <AlertCircle className="h-5 w-5 text-rose-600 dark:text-rose-300" />
      </div>
      <p className="font-semibold">Could not load this page</p>
      <p className="max-w-md text-sm text-[var(--muted-foreground)]">{message}</p>
      {onRetry ? (
        <Button variant="outline" onClick={onRetry}>
          <RefreshCw className="h-4 w-4" />
          Retry
        </Button>
      ) : null}
    </Card>
  );
}
