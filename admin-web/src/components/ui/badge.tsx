import * as React from 'react';
import { cn } from '@/lib/utils/cn';

type BadgeProps = React.HTMLAttributes<HTMLSpanElement> & {
  variant?: 'default' | 'success' | 'warning' | 'destructive' | 'outline' | 'muted';
};

export function Badge({ className, variant = 'default', ...props }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium',
        variant === 'default' && 'border-transparent bg-indigo-100 text-indigo-700 dark:bg-indigo-950 dark:text-indigo-200',
        variant === 'success' && 'border-transparent bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-200',
        variant === 'warning' && 'border-transparent bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-200',
        variant === 'destructive' && 'border-transparent bg-rose-100 text-rose-700 dark:bg-rose-950 dark:text-rose-200',
        variant === 'outline' && 'bg-transparent text-[var(--foreground)]',
        variant === 'muted' && 'border-transparent bg-[var(--muted)] text-[var(--muted-foreground)]',
        className
      )}
      {...props}
    />
  );
}
