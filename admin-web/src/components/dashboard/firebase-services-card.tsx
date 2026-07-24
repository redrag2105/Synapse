import Link from 'next/link';
import { BarChart3, Bug, ExternalLink } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';

type Integration = {
  configured: boolean;
  integrationStatus?: string;
};

export function FirebaseServicesCard({
  analytics,
  crashlytics
}: {
  analytics: Integration;
  crashlytics: Integration;
}) {
  const services = [
    {
      name: 'Analytics',
      description: analytics.configured ? 'GA4 Data API is returning events.' : analytics.integrationStatus ?? 'Not configured',
      status: analytics.configured ? 'Connected' : 'Not configured',
      route: '/admin/analytics',
      icon: BarChart3
    },
    {
      name: 'Crashlytics',
      description: crashlytics.configured ? 'Crashlytics data source is configured.' : crashlytics.integrationStatus ?? 'Not configured',
      status: crashlytics.configured ? 'Connected' : 'Not configured',
      route: '/admin/crashlytics',
      icon: Bug
    }
  ];

  return (
    <Card>
      <CardTitle>Firebase services</CardTitle>
      <CardDescription className="mt-2">Integration status from the current admin API response.</CardDescription>
      <div className="mt-5 space-y-4">
        {services.map((service) => {
          const Icon = service.icon;
          return (
            <div key={service.name} className="rounded-xl border p-4">
              <div className="flex items-start gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[var(--muted)]">
                  <Icon className="h-5 w-5 text-[var(--primary)]" />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <p className="font-medium">{service.name}</p>
                    <Badge variant={service.status === 'Connected' ? 'success' : 'warning'}>{service.status}</Badge>
                  </div>
                  <p className="mt-1 text-sm text-[var(--muted-foreground)]">{service.description}</p>
                </div>
              </div>
              <Link href={service.route} className="mt-3 inline-flex items-center gap-2 rounded-lg py-2 text-sm font-medium text-[var(--primary)] hover:underline">
                View details
                <ExternalLink className="h-4 w-4" />
              </Link>
            </div>
          );
        })}
      </div>
    </Card>
  );
}
