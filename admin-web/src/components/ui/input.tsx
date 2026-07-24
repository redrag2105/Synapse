import * as React from 'react';
import { cn } from '@/lib/utils/cn';

export function Input({ className, ...props }: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={cn('h-10 w-full rounded-lg border bg-[var(--card)] px-3 text-sm outline-none focus:ring-2 focus:ring-[var(--ring)] disabled:opacity-50', className)}
      {...props}
    />
  );
}
