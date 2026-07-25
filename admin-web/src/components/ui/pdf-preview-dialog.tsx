'use client';

import { useEffect } from 'react';
import { Download, ExternalLink, Loader2, X } from 'lucide-react';
import { Button } from '@/components/ui/button';

type PdfPreviewDialogProps = {
  open: boolean;
  title: string;
  url: string | null;
  loading?: boolean;
  error?: string | null;
  onClose: () => void;
  onRetry?: () => void;
};

export function PdfPreviewDialog({
  open,
  title,
  url,
  loading = false,
  error = null,
  onClose,
  onRetry
}: PdfPreviewDialogProps) {
  useEffect(() => {
    if (!open) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKeyDown);
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKeyDown);
      document.body.style.overflow = previousOverflow;
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-6">
      <button
        type="button"
        aria-label="Close PDF preview"
        className="absolute inset-0 bg-black/45"
        onClick={onClose}
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="pdf-preview-title"
        className="relative z-10 flex h-[min(92vh,920px)] w-full max-w-5xl flex-col overflow-hidden rounded-2xl border bg-[var(--card)] shadow-xl"
      >
        <div className="flex items-center gap-3 border-b px-4 py-3">
          <div className="min-w-0 flex-1">
            <h3 id="pdf-preview-title" className="truncate text-base font-semibold tracking-normal">
              {title}
            </h3>
            <p className="truncate text-xs text-[var(--muted-foreground)]">PDF preview</p>
          </div>
          <div className="flex shrink-0 items-center gap-2">
            {url ? (
              <>
                <Button
                  size="icon"
                  variant="outline"
                  aria-label="Open PDF in new tab"
                  onClick={() => window.open(url, '_blank', 'noopener,noreferrer')}
                >
                  <ExternalLink className="h-4 w-4" />
                </Button>
                <Button
                  size="icon"
                  variant="outline"
                  aria-label="Download PDF"
                  onClick={() => window.open(url, '_blank', 'noopener,noreferrer')}
                >
                  <Download className="h-4 w-4" />
                </Button>
              </>
            ) : null}
            <Button size="icon" variant="ghost" aria-label="Close" onClick={onClose}>
              <X className="h-4 w-4" />
            </Button>
          </div>
        </div>

        <div className="relative min-h-0 flex-1 bg-[var(--muted)]/40">
          {loading ? (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 text-sm text-[var(--muted-foreground)]">
              <Loader2 className="h-6 w-6 animate-spin text-[var(--primary)]" />
              Loading PDF…
            </div>
          ) : null}

          {!loading && error ? (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 p-6 text-center">
              <p className="text-sm text-[var(--muted-foreground)]">{error}</p>
              {onRetry ? (
                <Button type="button" variant="outline" onClick={onRetry}>
                  Retry
                </Button>
              ) : null}
            </div>
          ) : null}

          {!loading && !error && url ? (
            <iframe
              title={`Preview of ${title}`}
              src={url}
              className="h-full w-full border-0 bg-white"
            />
          ) : null}
        </div>
      </div>
    </div>
  );
}
