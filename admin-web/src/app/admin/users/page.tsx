'use client';

import { useMemo, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Ban, CheckCircle2, MoreHorizontal, RefreshCw, Shield, Trash2 } from 'lucide-react';
import { toast } from 'sonner';
import { apiClient, apiGet } from '@/lib/api/client';
import { Avatar } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { EmptyPanel, ErrorPanel, PageSkeleton } from '@/components/states/page-states';

type UserItem = {
  uid: string;
  email: string | null;
  displayName: string | null;
  photoURL?: string | null;
  providerIds: string[];
  emailVerified: boolean;
  disabled: boolean;
  creationTime: string;
  lastSignInTime: string | null;
  role: string;
};

export default function UsersPage() {
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('all');
  const [role, setRole] = useState('all');
  const queryClient = useQueryClient();
  const query = useQuery({ queryKey: ['users'], queryFn: () => apiGet<{ items: UserItem[] }>('/admin/users') });
  const mutation = useMutation({
    mutationFn: ({ path, body, method = 'patch' }: { path: string; body?: unknown; method?: 'patch' | 'delete' }) =>
      method === 'delete' ? apiClient.delete(path) : apiClient.patch(path, body),
    onSuccess: async () => {
      toast.success('User updated');
      await queryClient.invalidateQueries({ queryKey: ['users'] });
    },
    onError: () => toast.error('Action failed')
  });

  const users = query.data?.items ?? [];
  const filtered = useMemo(() => {
    const needle = search.trim().toLowerCase();
    return users.filter((user) => {
      const matchesSearch = !needle || user.uid.toLowerCase().includes(needle) || (user.email ?? '').toLowerCase().includes(needle) || (user.displayName ?? '').toLowerCase().includes(needle);
      const matchesStatus = status === 'all' || (status === 'disabled' ? user.disabled : !user.disabled);
      const matchesRole = role === 'all' || user.role === role;
      return matchesSearch && matchesStatus && matchesRole;
    });
  }, [role, search, status, users]);

  if (query.isLoading) return <PageSkeleton />;
  if (query.isError) return <ErrorPanel message="Could not load Firebase Authentication users." onRetry={() => void query.refetch()} />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm font-medium text-[var(--primary)]">Firebase Management</p>
          <h2 className="mt-1 text-3xl font-semibold tracking-normal">Users</h2>
          <p className="mt-2 text-sm text-[var(--muted-foreground)]">Manage Firebase Authentication accounts, status and admin claims.</p>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant="muted">{users.length} total</Badge>
          <Button variant="outline" onClick={() => void query.refetch()} disabled={query.isFetching}>
            <RefreshCw className={query.isFetching ? 'h-4 w-4 animate-spin' : 'h-4 w-4'} />
            Refresh
          </Button>
        </div>
      </div>

      <Card>
        <div className="grid gap-3 md:grid-cols-[1fr_180px_180px_auto]">
          <Input placeholder="Search name, email or UID" value={search} onChange={(event) => setSearch(event.target.value)} />
          <Select value={status} onChange={(event) => setStatus(event.target.value)}>
            <option value="all">All statuses</option>
            <option value="active">Active</option>
            <option value="disabled">Disabled</option>
          </Select>
          <Select value={role} onChange={(event) => setRole(event.target.value)}>
            <option value="all">All roles</option>
            <option value="admin">Admin</option>
            <option value="user">User</option>
          </Select>
          <Button variant="ghost" onClick={() => { setSearch(''); setStatus('all'); setRole('all'); }}>Clear</Button>
        </div>
      </Card>

      {!filtered.length ? (
        <EmptyPanel title="No users match the current filters" description="Adjust search or filters to see Firebase Authentication users." />
      ) : (
        <Card>
          <CardTitle>Firebase Authentication Users</CardTitle>
          <CardDescription className="mt-2">Actions are applied through admin-api and audited on the backend.</CardDescription>
          <div className="mt-5 overflow-x-auto">
            <table className="w-full min-w-[1024px] border-collapse text-sm">
              <thead className="sticky top-0 bg-[var(--card)]">
                <tr className="border-b text-left text-[var(--muted-foreground)]">
                  <th className="p-3">User</th>
                  <th className="p-3">Provider</th>
                  <th className="p-3">Verified</th>
                  <th className="p-3">Status</th>
                  <th className="p-3">Role</th>
                  <th className="p-3">Created</th>
                  <th className="p-3">Last sign-in</th>
                  <th className="p-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((user) => (
                  <tr key={user.uid} className="border-b last:border-0">
                    <td className="p-3">
                      <div className="flex items-center gap-3">
                        <Avatar src={user.photoURL} name={user.displayName ?? user.email} />
                        <div className="min-w-0">
                          <p className="truncate font-medium">{user.displayName ?? 'No name'}</p>
                          <p className="truncate text-xs text-[var(--muted-foreground)]">{user.email ?? user.uid}</p>
                        </div>
                      </div>
                    </td>
                    <td className="p-3">{user.providerIds.join(', ') || 'password'}</td>
                    <td className="p-3"><Badge variant={user.emailVerified ? 'success' : 'muted'}>{user.emailVerified ? 'Verified' : 'Unverified'}</Badge></td>
                    <td className="p-3"><Badge variant={user.disabled ? 'destructive' : 'success'}>{user.disabled ? 'Disabled' : 'Active'}</Badge></td>
                    <td className="p-3"><Badge variant={user.role === 'admin' ? 'default' : 'muted'}>{user.role}</Badge></td>
                    <td className="p-3">{user.creationTime}</td>
                    <td className="p-3">{user.lastSignInTime ?? '-'}</td>
                    <td className="p-3 text-right">
                      <details className="relative inline-block">
                        <summary className="inline-flex h-9 w-9 cursor-pointer items-center justify-center rounded-lg border hover:bg-[var(--muted)]" aria-label="Open user actions">
                          <MoreHorizontal className="h-4 w-4" />
                        </summary>
                        <div className="absolute right-0 z-20 mt-2 w-52 rounded-xl border bg-[var(--popover)] p-2 text-left shadow-lg">
                          <button className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm hover:bg-[var(--muted)]" onClick={() => confirm('Confirm status change?') && mutation.mutate({ path: `/admin/users/${user.uid}/status`, body: { disabled: !user.disabled } })}>
                            {user.disabled ? <CheckCircle2 className="h-4 w-4" /> : <Ban className="h-4 w-4" />}
                            {user.disabled ? 'Enable user' : 'Disable user'}
                          </button>
                          <button className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm hover:bg-[var(--muted)]" onClick={() => confirm('User must refresh token or sign in again. Continue?') && mutation.mutate({ path: `/admin/users/${user.uid}/role`, body: { admin: user.role !== 'admin' } })}>
                            <Shield className="h-4 w-4" />
                            {user.role === 'admin' ? 'Remove admin' : 'Grant admin'}
                          </button>
                          <button className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm text-[var(--destructive)] hover:bg-[var(--muted)]" onClick={() => confirm('Delete this user?') && mutation.mutate({ path: `/admin/users/${user.uid}`, method: 'delete' })}>
                            <Trash2 className="h-4 w-4" />
                            Delete user
                          </button>
                        </div>
                      </details>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
}
