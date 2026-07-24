'use client';

import { useSearchParams, useRouter } from 'next/navigation';
import { Flame, LogIn, ShieldCheck } from 'lucide-react';
import { Suspense, useEffect, useState } from 'react';
import { toast } from 'sonner';
import { useAuth } from '@/components/providers/auth-provider';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

export default function LoginPage() {
  return (
    <Suspense fallback={<LoginSkeleton />}>
      <LoginContent />
    </Suspense>
  );
}

function LoginSkeleton() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-[var(--background)] p-4">
      <div className="w-full max-w-md">
        <div className="mb-8 flex flex-col items-center">
          <Skeleton className="h-12 w-12 rounded-2xl" />
          <Skeleton className="mt-4 h-9 w-56" />
          <Skeleton className="mt-3 h-4 w-72" />
        </div>
        <Card>
          <div className="flex items-start justify-between gap-4">
            <div className="flex-1">
              <Skeleton className="h-6 w-36" />
              <Skeleton className="mt-3 h-4 w-full" />
              <Skeleton className="mt-2 h-4 w-3/4" />
            </div>
            <Skeleton className="h-7 w-16 rounded-full" />
          </div>
          <div className="mt-5 grid grid-cols-2 gap-3">
            <Skeleton className="h-20 rounded-xl" />
            <Skeleton className="h-20 rounded-xl" />
          </div>
          <Skeleton className="mt-6 h-11 w-full rounded-lg" />
        </Card>
      </div>
    </main>
  );
}

function LoginContent() {
  const { login, profile, initializing, authError } = useAuth();
  const params = useSearchParams();
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (profile) router.replace('/admin/dashboard');
  }, [profile, router]);

  const reason = params.get('reason');

  return (
    <main className="flex min-h-screen items-center justify-center bg-[var(--background)] p-4">
      <div className="w-full max-w-md">
        <div className="mb-8 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-[var(--primary)] text-[var(--primary-foreground)]">
            <Flame className="h-6 w-6" />
          </div>
          <h1 className="mt-4 text-3xl font-semibold tracking-normal">SYNAPSE Admin</h1>
          <p className="mt-2 text-sm text-[var(--muted-foreground)]">Firebase operations dashboard for the SYNAPSE reading app.</p>
        </div>

        <Card className="shadow-xl shadow-slate-900/5">
          <div className="flex items-start justify-between gap-4">
            <div>
              <CardTitle>Welcome back</CardTitle>
              <CardDescription className="mt-2">Sign in with a Firebase account that has the admin custom claim.</CardDescription>
            </div>
            <Badge variant="success">Secure</Badge>
          </div>

          {reason === 'forbidden' ? (
            <div className="mt-4 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-800 dark:border-red-900 dark:bg-red-950 dark:text-red-200">
              This account does not have admin access.
            </div>
          ) : null}
          {authError ? (
            <div className="mt-4 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-800 dark:border-red-900 dark:bg-red-950 dark:text-red-200">
              {authError}
            </div>
          ) : null}

          <div className="mt-5 grid grid-cols-2 gap-3 text-sm">
            <div className="rounded-xl border bg-[var(--muted)] p-3">
              <Flame className="h-4 w-4 text-[var(--primary)]" />
              <p className="mt-2 font-medium">Firebase Auth</p>
            </div>
            <div className="rounded-xl border bg-[var(--muted)] p-3">
              <ShieldCheck className="h-4 w-4 text-[var(--primary)]" />
              <p className="mt-2 font-medium">Admin claim</p>
            </div>
          </div>

          <Button
            className="mt-6 h-11 w-full"
            disabled={busy || initializing}
            onClick={async () => {
              setBusy(true);
              try {
                await login();
                router.replace('/admin/dashboard');
              } catch {
                toast.error('Login failed or account has no admin permission');
              } finally {
                setBusy(false);
              }
            }}
          >
            <LogIn className="h-4 w-4" />
            Sign in with Google
          </Button>
        </Card>
      </div>
    </main>
  );
}
