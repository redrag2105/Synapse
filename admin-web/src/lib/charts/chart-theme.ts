'use client';

import { useEffect, useState } from 'react';
import { useTheme } from 'next-themes';

export type ChartTheme = {
  textColor: string;
  mutedColor: string;
  gridColor: string;
  tooltipBackground: string;
  tooltipBorder: string;
  palette: string[];
};

const fallbackTheme: ChartTheme = {
  textColor: '#0f172a',
  mutedColor: '#64748b',
  gridColor: 'rgba(148, 163, 184, 0.2)',
  tooltipBackground: '#ffffff',
  tooltipBorder: '#e2e8f0',
  palette: ['#4f46e5', '#7c3aed', '#0891b2', '#059669', '#ca8a04', '#dc2626']
};

export function useChartTheme() {
  const { resolvedTheme } = useTheme();
  const [theme, setTheme] = useState<ChartTheme>(fallbackTheme);

  useEffect(() => {
    const styles = getComputedStyle(document.documentElement);
    const read = (name: string, fallback: string) => styles.getPropertyValue(name).trim() || fallback;
    const foreground = read('--foreground', fallbackTheme.textColor);
    const muted = read('--muted-foreground', fallbackTheme.mutedColor);
    const border = read('--border', fallbackTheme.tooltipBorder);
    const card = read('--card', fallbackTheme.tooltipBackground);
    const palette = Array.from({ length: 6 }, (_, index) => read(`--chart-${index + 1}`, fallbackTheme.palette[index]));

    setTheme({
      textColor: foreground,
      mutedColor: muted,
      gridColor: colorWithAlpha(border, resolvedTheme === 'dark' ? 0.28 : 0.45),
      tooltipBackground: card,
      tooltipBorder: border,
      palette
    });
  }, [resolvedTheme]);

  return theme;
}

function colorWithAlpha(color: string, alpha: number) {
  if (color.startsWith('#') && color.length === 7) {
    const red = parseInt(color.slice(1, 3), 16);
    const green = parseInt(color.slice(3, 5), 16);
    const blue = parseInt(color.slice(5, 7), 16);
    return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
  }

  return color;
}
