import * as React from 'react';
import { cn } from '@/lib/utils/cn';

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'default' | 'outline' | 'ghost' | 'destructive';
  size?: 'default' | 'icon';
};

export function Button({ className, variant = 'default', size = 'default', ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center gap-2 rounded-lg border px-3 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-[var(--ring)] disabled:cursor-not-allowed disabled:opacity-50',
        variant === 'default' && 'border-transparent bg-[var(--primary)] text-[var(--primary-foreground)] hover:opacity-90',
        variant === 'outline' && 'bg-[var(--card)] hover:bg-[var(--muted)]',
        variant === 'ghost' && 'border-transparent bg-transparent hover:bg-[var(--muted)]',
        variant === 'destructive' && 'border-transparent bg-[var(--destructive)] text-white hover:opacity-90',
        size === 'icon' && 'h-9 w-9 p-0',
        className
      )}
      {...props}
    />
  );
}
