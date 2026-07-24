export const compactNumber = new Intl.NumberFormat('en', {
  notation: 'compact',
  maximumFractionDigits: 1
});

export const wholeNumber = new Intl.NumberFormat('en', {
  maximumFractionDigits: 0
});

export const decimalNumber = new Intl.NumberFormat('en', {
  maximumFractionDigits: 2
});

export const percentNumber = new Intl.NumberFormat('en', {
  maximumFractionDigits: 1
});

export function formatPercent(value: number) {
  return `${percentNumber.format(value)}%`;
}
