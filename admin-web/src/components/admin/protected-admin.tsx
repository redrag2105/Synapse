'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { useAuth } from '@/components/providers/auth-provider';
import { LoadingState } from '@/components/ui/state';

export function ProtectedAdmin({ children }: { children: React.ReactNode }) {
  const { initializing, profile } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!initializing && !profile) router.replace('/login');
  }, [initializing, profile, router]);

  if (initializing) return <main className="p-6"><LoadingState /></main>;
  if (!profile) return null;
  return children;
}
