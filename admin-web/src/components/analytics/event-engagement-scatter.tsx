'use client';

import type { EChartsOption } from 'echarts';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { AnalyticsChartEvent } from '@/features/analytics/lib/analytics-chart.mapper';
import { ReactECharts } from '@/lib/charts/echarts-client';
import { compactNumber, decimalNumber, wholeNumber } from '@/lib/charts/formatters';
import { useChartTheme } from '@/lib/charts/chart-theme';

export function EventEngagementScatter({ events }: { events: AnalyticsChartEvent[] }) {
  const theme = useChartTheme();

  const option: EChartsOption = {
    color: [theme.palette[2]],
    grid: { left: 56, right: 28, top: 24, bottom: 52 },
    tooltip: {
      trigger: 'item',
      backgroundColor: theme.tooltipBackground,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.textColor },
      extraCssText: 'border-radius: 12px; box-shadow: 0 16px 40px rgba(15, 23, 42, 0.14);',
      formatter: (params) => {
        const event = events[(params as { dataIndex: number }).dataIndex];
        if (!event) return '';
        return `
          <strong>${event.name}</strong><br/>
          Event count: ${wholeNumber.format(event.count)}<br/>
          Active users: ${wholeNumber.format(event.activeUsers)}<br/>
          Events/user: ${decimalNumber.format(event.eventsPerUser)}<br/>
          Category: ${event.category === 'lab' ? 'Lab event' : event.category === 'automatic' ? 'Automatic' : 'Other'}
        `;
      }
    },
    xAxis: {
      name: 'Active users',
      nameLocation: 'middle',
      nameGap: 34,
      type: 'value',
      minInterval: 1,
      axisLabel: { color: theme.mutedColor, formatter: (value) => compactNumber.format(Number(value)) },
      axisLine: { lineStyle: { color: theme.gridColor } },
      axisTick: { show: false },
      splitLine: { lineStyle: { color: theme.gridColor } }
    },
    yAxis: {
      name: 'Event count',
      type: 'value',
      minInterval: 1,
      axisLabel: { color: theme.mutedColor, formatter: (value) => compactNumber.format(Number(value)) },
      axisLine: { show: false },
      axisTick: { show: false },
      splitLine: { lineStyle: { color: theme.gridColor } }
    },
    series: [
      {
        type: 'scatter',
        data: events.map((event) => [event.activeUsers, event.count, event.eventsPerUser]),
        symbolSize: (value) => {
          const eventsPerUser = Array.isArray(value) ? Number(value[2]) : 1;
          return Math.max(10, Math.min(30, eventsPerUser * 3));
        },
        itemStyle: {
          color: (params) => {
            const event = events[params.dataIndex];
            if (event?.category === 'lab') return theme.palette[3];
            if (event?.category === 'automatic') return theme.palette[0];
            return theme.palette[2];
          },
          opacity: 0.86
        },
        emphasis: { focus: 'self' },
        animationDuration: 600
      }
    ]
  };

  return (
    <Card>
      <CardTitle>Events vs active users</CardTitle>
      <CardDescription className="mt-2">Spot events with high repetition across fewer users</CardDescription>
      <div className="mt-4 h-[360px]" aria-label="Scatter chart comparing event count and active users">
        <ReactECharts option={option} style={{ height: '100%', width: '100%' }} notMerge lazyUpdate />
      </div>
    </Card>
  );
}
