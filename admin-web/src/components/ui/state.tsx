import { PageSkeleton, EmptyPanel, ErrorPanel } from '@/components/states/page-states';

export function LoadingState() {
  return <PageSkeleton />;
}

export function EmptyState({ title, description }: { title: string; description?: string }) {
  return <EmptyPanel title={title} description={description} />;
}

export function ErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return <ErrorPanel message={message} onRetry={onRetry} />;
}
