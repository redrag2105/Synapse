import { LucideIcon } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { cn } from '@/lib/utils/cn';

export function MetricCard({
  title,
  value,
  description,
  icon: Icon,
  status,
  loading
}: {
  title: string;
  value: string | number;
  description: string;
  icon: LucideIcon;
  status?: 'default' | 'success' | 'warning' | 'destructive';
  loading?: boolean;
}) {
  return (
    <Card className="group transition-shadow hover:shadow-md">
      <div className="flex items-start justify-between gap-4">
        <div className="min-w-0">
          <p className="text-sm font-medium text-[var(--muted-foreground)]">{title}</p>
          <p className="mt-3 text-3xl font-semibold tracking-normal">{loading ? '-' : value}</p>
          <p className="mt-2 truncate text-xs text-[var(--muted-foreground)]">{description}</p>
        </div>
        <div
          className={cn(
            'flex h-11 w-11 shrink-0 items-center justify-center rounded-xl',
            status === 'success' && 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300',
            status === 'warning' && 'bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300',
            status === 'destructive' && 'bg-rose-100 text-rose-700 dark:bg-rose-950 dark:text-rose-300',
            (!status || status === 'default') && 'bg-indigo-100 text-indigo-700 dark:bg-indigo-950 dark:text-indigo-300'
          )}
        >
          <Icon className="h-5 w-5" />
        </div>
      </div>
    </Card>
  );
}
