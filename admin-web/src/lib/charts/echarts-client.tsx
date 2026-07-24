'use client';

import dynamic from 'next/dynamic';
import { AnalyticsChartSkeleton } from '@/components/analytics/analytics-chart-skeleton';

export const ReactECharts = dynamic(() => import('echarts-for-react'), {
  ssr: false,
  loading: () => <AnalyticsChartSkeleton />
});
