'use client';

import type { EChartsOption } from 'echarts';
import { Badge } from '@/components/ui/badge';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { AnalyticsChartEvent } from '@/features/analytics/lib/analytics-chart.mapper';
import { ReactECharts } from '@/lib/charts/echarts-client';
import { compactNumber, decimalNumber, formatPercent, wholeNumber } from '@/lib/charts/formatters';
import { useChartTheme } from '@/lib/charts/chart-theme';

export function TopEventsChart({ events }: { events: AnalyticsChartEvent[] }) {
  const theme = useChartTheme();
  const topEvents = events.slice(0, 10);

  const option: EChartsOption = {
    color: [theme.palette[0], theme.palette[3]],
    grid: { left: 132, right: 28, top: 12, bottom: 24 },
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      backgroundColor: theme.tooltipBackground,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.textColor },
      extraCssText: 'border-radius: 12px; box-shadow: 0 16px 40px rgba(15, 23, 42, 0.14);',
      formatter: (params) => {
        const item = Array.isArray(params) ? params[0] : params;
        const event = topEvents[item.dataIndex];
        if (!event) return '';
        return tooltipHtml(event);
      }
    },
    xAxis: {
      type: 'value',
      minInterval: 1,
      axisLabel: { color: theme.mutedColor, formatter: (value) => compactNumber.format(Number(value)) },
      axisLine: { show: false },
      axisTick: { show: false },
      splitLine: { lineStyle: { color: theme.gridColor } }
    },
    yAxis: {
      type: 'category',
      inverse: true,
      data: topEvents.map((event) => event.name),
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: {
        color: theme.textColor,
        width: 116,
        overflow: 'truncate',
        fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace'
      }
    },
    series: [
      {
        type: 'bar',
        data: topEvents.map((event) => ({
          value: event.count,
          itemStyle: { color: event.category === 'lab' ? theme.palette[3] : theme.palette[0] }
        })),
        barWidth: 22,
        itemStyle: { borderRadius: [0, 7, 7, 0] },
        emphasis: { focus: 'self' },
        animationDuration: 600
      }
    ]
  };

  return (
    <Card>
      <div className="flex items-start justify-between gap-3">
        <div>
          <CardTitle>Top events</CardTitle>
          <CardDescription className="mt-2">Events ranked by total occurrences</CardDescription>
        </div>
        <Badge variant="muted">Top 10</Badge>
      </div>
      <div className="mt-4 h-[420px]" aria-label="Top Analytics events horizontal bar chart">
        <ReactECharts option={option} style={{ height: '100%', width: '100%' }} notMerge lazyUpdate />
      </div>
    </Card>
  );
}

function tooltipHtml(event: AnalyticsChartEvent) {
  return `
    <div style="min-width:220px">
      <div style="font-weight:700;margin-bottom:8px">${event.name}</div>
      <div style="display:grid;gap:6px;font-size:12px">
        <div>Event count: <strong>${wholeNumber.format(event.count)}</strong></div>
        <div>Active users: <strong>${wholeNumber.format(event.activeUsers)}</strong></div>
        <div>Share: <strong>${formatPercent(event.percentage)}</strong></div>
        <div>Events/user: <strong>${decimalNumber.format(event.eventsPerUser)}</strong></div>
        <div>Category: <strong>${categoryLabel(event.category)}</strong></div>
      </div>
    </div>
  `;
}

function categoryLabel(category: AnalyticsChartEvent['category']) {
  if (category === 'lab') return 'Lab event';
  if (category === 'automatic') return 'Automatic';
  return 'Other';
}
