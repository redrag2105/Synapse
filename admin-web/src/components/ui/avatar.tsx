import * as React from 'react';
import { cn } from '@/lib/utils/cn';

export function Avatar({
  src,
  name,
  className
}: {
  src?: string | null;
  name?: string | null;
  className?: string;
}) {
  const initials = (name ?? 'Admin')
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('');

  return (
    <div className={cn('flex h-9 w-9 items-center justify-center overflow-hidden rounded-full border bg-[var(--muted)] text-sm font-semibold', className)}>
      {src ? <img src={src} alt={name ?? 'Admin'} className="h-full w-full object-cover" /> : initials}
    </div>
  );
}
