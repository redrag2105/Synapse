'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { Bell, ImageIcon, Send, Smartphone } from 'lucide-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { toast } from 'sonner';
import { z } from 'zod';
import { useQuery } from '@tanstack/react-query';
import { apiClient, apiGet } from '@/lib/api/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';

const schema = z.object({
  title: z.string().min(1).max(100),
  body: z.string().min(1).max(500),
  imageUrl: z.string().optional(),
  targetType: z.enum(['user', 'multiple_users', 'topic', 'all']),
  target: z.string().optional(),
  type: z.enum(['trending_topic', 'highly_cited_publication', 'research_trend_update', 'general']),
  route: z.string().optional(),
  entityId: z.string().optional(),
  deepLink: z.string().optional()
});

type FormValue = z.infer<typeof schema>;

export default function NotificationsPage() {
  const [sending, setSending] = useState(false);
  const history = useQuery({ queryKey: ['notifications'], queryFn: () => apiGet<{ items: Record<string, unknown>[] }>('/admin/notifications') });
  const form = useForm<FormValue>({ resolver: zodResolver(schema), defaultValues: { targetType: 'all', type: 'general', title: '', body: '' } });
  const values = form.watch();
  const targetType = values.targetType;

  async function submit(nextValues: FormValue, test = false) {
    if (!test && nextValues.targetType === 'all' && !confirm('Send notification to all-users?')) return;
    setSending(true);
    try {
      await apiClient.post(`/admin/notifications/${test ? 'test' : 'send'}`, {
        ...nextValues,
        targetUsers: nextValues.targetType === 'multiple_users' ? nextValues.target?.split(',').map((item) => item.trim()).filter(Boolean) : undefined,
        data: { route: nextValues.route, entityId: nextValues.entityId, deepLink: nextValues.deepLink }
      });
      toast.success(test ? 'Test notification sent' : 'Notification campaign sent');
      await history.refetch();
    } catch {
      toast.error('Notification request failed');
    } finally {
      setSending(false);
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <p className="text-sm font-medium text-[var(--primary)]">Firebase Management</p>
        <h2 className="mt-1 text-3xl font-semibold tracking-normal">Notifications</h2>
        <p className="mt-2 max-w-2xl text-sm text-[var(--muted-foreground)]">Compose FCM campaigns, preview payloads and review delivery history.</p>
      </div>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_420px]">
        <Card>
          <CardTitle>Compose notification</CardTitle>
          <CardDescription className="mt-2">FCM is sent by admin-api using active mobile device tokens or topic delivery.</CardDescription>
          <form className="mt-5 grid gap-4 md:grid-cols-2" onSubmit={form.handleSubmit((formValues) => submit(formValues))}>
            <label className="space-y-2 md:col-span-2"><span className="text-sm font-medium">Title</span><Input placeholder="Research update" {...form.register('title')} /></label>
            <label className="space-y-2 md:col-span-2"><span className="text-sm font-medium">Body</span><Textarea placeholder="New trends are available for your topic." {...form.register('body')} /></label>
            <label className="space-y-2"><span className="text-sm font-medium">Target type</span><Select {...form.register('targetType')}><option value="all">All users</option><option value="topic">Topic</option><option value="user">One user</option><option value="multiple_users">Multiple users</option></Select></label>
            <label className="space-y-2"><span className="text-sm font-medium">Notification type</span><Select {...form.register('type')}><option value="general">General</option><option value="trending_topic">Trending topic</option><option value="highly_cited_publication">Highly cited publication</option><option value="research_trend_update">Research trend update</option></Select></label>
            {targetType !== 'all' ? <label className="space-y-2 md:col-span-2"><span className="text-sm font-medium">Target</span><Input placeholder="UID/email, topic, or comma separated users" {...form.register('target')} /></label> : null}
            <label className="space-y-2 md:col-span-2"><span className="text-sm font-medium">Image URL</span><Input placeholder="https://..." {...form.register('imageUrl')} /></label>
            <label className="space-y-2"><span className="text-sm font-medium">Route</span><Input placeholder="/publication" {...form.register('route')} /></label>
            <label className="space-y-2"><span className="text-sm font-medium">Entity ID</span><Input placeholder="OpenAlex ID or local entity ID" {...form.register('entityId')} /></label>
            <label className="space-y-2 md:col-span-2"><span className="text-sm font-medium">Deep link</span><Input placeholder="synapse://..." {...form.register('deepLink')} /></label>
            <div className="flex flex-wrap gap-2 md:col-span-2">
              <Button type="button" variant="outline" disabled={sending} onClick={form.handleSubmit((formValues) => submit(formValues, true))}><Bell className="h-4 w-4" /> Send test</Button>
              <Button type="submit" disabled={sending}><Send className={sending ? 'h-4 w-4 animate-pulse' : 'h-4 w-4'} /> Send notification</Button>
            </div>
          </form>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Mobile preview</CardTitle>
              <CardDescription className="mt-2">Approximate notification appearance.</CardDescription>
            </div>
            <Smartphone className="h-5 w-5 text-[var(--muted-foreground)]" />
          </div>
          <div className="mt-6 rounded-[2rem] border bg-neutral-950 p-4 text-white shadow-inner">
            <div className="rounded-3xl bg-neutral-900 p-4">
              <div className="flex items-start gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-500"><Bell className="h-5 w-5" /></div>
                <div className="min-w-0 flex-1">
                  <p className="font-semibold">{values.title || 'Notification title'}</p>
                  <p className="mt-1 text-sm text-neutral-300">{values.body || 'Notification body appears here.'}</p>
                  {values.imageUrl ? <div className="mt-3 flex h-24 items-center justify-center rounded-xl bg-neutral-800 text-neutral-400"><ImageIcon className="h-5 w-5" /></div> : null}
                </div>
              </div>
            </div>
          </div>
        </Card>
      </div>

      <Card>
        <CardTitle>Notification history</CardTitle>
        <div className="mt-4 overflow-x-auto">
          <table className="w-full min-w-[860px] text-sm">
            <thead><tr className="border-b text-left text-[var(--muted-foreground)]"><th className="p-3">Title</th><th className="p-3">Target</th><th className="p-3">Status</th><th className="p-3">Success</th><th className="p-3">Failure</th><th className="p-3">Created by</th></tr></thead>
            <tbody>{history.data?.items.map((item) => <tr key={String(item.id)} className="border-b last:border-0"><td className="p-3 font-medium">{String(item.title ?? '')}</td><td className="p-3">{String(item.targetType ?? '')}</td><td className="p-3"><Badge variant={String(item.status) === 'sent' ? 'success' : String(item.status).includes('failed') ? 'destructive' : 'warning'}>{String(item.status ?? '')}</Badge></td><td className="p-3">{String(item.successCount ?? 0)}</td><td className="p-3">{String(item.failureCount ?? 0)}</td><td className="p-3">{String(item.createdByEmail ?? '')}</td></tr>)}</tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
