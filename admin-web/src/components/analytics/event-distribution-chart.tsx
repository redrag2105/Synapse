'use client';

import type { EChartsOption } from 'echarts';
import { Badge } from '@/components/ui/badge';
import { Card, CardDescription, CardTitle } from '@/components/ui/card';
import { AnalyticsChartEvent } from '@/features/analytics/lib/analytics-chart.mapper';
import { ReactECharts } from '@/lib/charts/echarts-client';
import { formatPercent, wholeNumber } from '@/lib/charts/formatters';
import { useChartTheme } from '@/lib/charts/chart-theme';

type DistributionSlice = {
  name: string;
  value: number;
  percentage: number;
};

export function EventDistributionChart({ events, totalEvents }: { events: AnalyticsChartEvent[]; totalEvents: number }) {
  const theme = useChartTheme();
  const slices = buildDistribution(events, totalEvents);

  const option: EChartsOption = {
    color: theme.palette,
    tooltip: {
      trigger: 'item',
      backgroundColor: theme.tooltipBackground,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.textColor },
      extraCssText: 'border-radius: 12px; box-shadow: 0 16px 40px rgba(15, 23, 42, 0.14);',
      formatter: (params) => {
        const item = params as { name: string; value: number; data?: DistributionSlice };
        const percentage = item.data?.percentage ?? 0;
        return `<strong>${item.name}</strong><br/>Count: ${wholeNumber.format(item.value)}<br/>Share: ${formatPercent(percentage)}`;
      }
    },
    legend: {
      bottom: 0,
      left: 'center',
      icon: 'circle',
      textStyle: { color: theme.mutedColor },
      itemWidth: 8,
      itemHeight: 8
    },
    graphic: [
      {
        type: 'text',
        left: 'center',
        top: '40%',
        style: {
          text: `Total\n${wholeNumber.format(totalEvents)} events`,
          align: 'center',
          fill: theme.textColor,
          fontSize: 14,
          fontWeight: 600,
          lineHeight: 22
        }
      }
    ],
    series: [
      {
        type: 'pie',
        radius: ['58%', '78%'],
        center: ['50%', '42%'],
        data: slices,
        avoidLabelOverlap: true,
        label: { show: false },
        labelLine: { show: false },
        itemStyle: { borderRadius: 8, borderWidth: 3, borderColor: theme.tooltipBackground },
        emphasis: { scale: true, scaleSize: 4 },
        animationDuration: 650
      }
    ]
  };

  return (
    <Card>
      <div className="flex items-start justify-between gap-3">
        <div>
          <CardTitle>Event distribution</CardTitle>
          <CardDescription className="mt-2">Top events by share of all tracked events</CardDescription>
        </div>
        <Badge variant="muted">Top 5</Badge>
      </div>
      <div className="mt-4 h-[420px]" aria-label="Analytics event distribution donut chart">
        <ReactECharts option={option} style={{ height: '100%', width: '100%' }} notMerge lazyUpdate />
      </div>
    </Card>
  );
}

function buildDistribution(events: AnalyticsChartEvent[], totalEvents: number): DistributionSlice[] {
  const top = events.slice(0, 5).map((event) => ({
    name: event.name,
    value: event.count,
    percentage: event.percentage
  }));
  const otherCount = events.slice(5).reduce((sum, event) => sum + event.count, 0);
  if (otherCount > 0) {
    top.push({
      name: 'Other',
      value: otherCount,
      percentage: totalEvents > 0 ? (otherCount / totalEvents) * 100 : 0
    });
  }

  return top;
}
