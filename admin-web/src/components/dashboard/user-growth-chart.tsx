'use client';

import { format, parseISO } from 'date-fns';
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { EmptyPanel } from '@/components/states/page-states';

export function UserGrowthChart({ data }: { data: { date: string; count: number }[] }) {
  const chartData = [...data]
    .map((item) => ({
      ...item,
      timestamp: Date.parse(item.date)
    }))
    .filter((item) => Number.isFinite(item.timestamp))
    .sort((a, b) => a.timestamp - b.timestamp)
    .map((item) => ({
      date: item.date,
      label: format(parseISO(item.date), 'MMM d'),
      count: item.count
    }));

  return (
    <Card>
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <CardTitle>New users by day</CardTitle>
          <CardDescription className="mt-2">Firebase Authentication accounts created over time.</CardDescription>
        </div>
      </div>
      {chartData.length ? (
        <div className="mt-6 h-80">
          <ResponsiveContainer>
            <AreaChart data={chartData} margin={{ left: 0, right: 8, top: 10, bottom: 0 }}>
              <defs>
                <linearGradient id="userGrowth" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="5%" stopColor="var(--chart-1)" stopOpacity={0.28} />
                  <stop offset="95%" stopColor="var(--chart-1)" stopOpacity={0.03} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" vertical={false} />
              <XAxis dataKey="label" tickLine={false} axisLine={false} tickMargin={10} />
              <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
              <Tooltip
                contentStyle={{
                  background: 'var(--popover)',
                  border: '1px solid var(--border)',
                  borderRadius: 12,
                  color: 'var(--popover-foreground)'
                }}
              />
              <Area type="monotone" dataKey="count" stroke="var(--chart-1)" fill="url(#userGrowth)" strokeWidth={2.5} dot={{ r: chartData.length < 3 ? 4 : 2 }} />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      ) : (
        <div className="mt-4">
          <EmptyPanel title="No user growth data" description="New user counts will appear after Firebase Authentication returns dated accounts." />
        </div>
      )}
    </Card>
  );
}
