'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  BarChart3,
  Bell,
  Bug,
  ChevronsLeft,
  ChevronsRight,
  FileText,
  Home,
  LogOut,
  Menu,
  Moon,
  Search,
  SlidersHorizontal,
  Sun,
  Users,
  X
} from 'lucide-react';
import { useTheme } from 'next-themes';
import { useState } from 'react';
import { useAuth } from '@/components/providers/auth-provider';
import { Avatar } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils/cn';

const navGroups = [
  {
    label: 'Overview',
    items: [{ href: '/admin/dashboard', label: 'Dashboard', icon: Home }]
  },
  {
    label: 'Firebase Management',
    items: [
      { href: '/admin/users', label: 'Users', icon: Users },
      { href: '/admin/notifications', label: 'Notifications', icon: Bell },
      { href: '/admin/remote-config', label: 'Remote Config', icon: SlidersHorizontal },
      { href: '/admin/reports', label: 'Reports & Storage', icon: FileText }
    ]
  },
  {
    label: 'Monitoring',
    items: [
      { href: '/admin/analytics', label: 'Analytics', icon: BarChart3 },
      { href: '/admin/crashlytics', label: 'Crashlytics', icon: Bug }
    ]
  }
];

const navItems = navGroups.flatMap((group) => group.items);

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { profile, logout } = useAuth();
  const { theme, setTheme } = useTheme();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [userOpen, setUserOpen] = useState(false);
  const current = navItems.find((item) => pathname.startsWith(item.href));

  return (
    <div className="min-h-screen bg-[var(--background)] lg:flex">
      <div className="hidden lg:fixed lg:inset-y-0 lg:block">
        <Sidebar collapsed={collapsed} pathname={pathname} onNavigate={() => undefined} />
      </div>
      {mobileOpen ? (
        <div className="fixed inset-0 z-50 bg-black/40 lg:hidden" onClick={() => setMobileOpen(false)}>
          <div className="h-full w-72" onClick={(event) => event.stopPropagation()}>
            <Sidebar collapsed={false} pathname={pathname} onNavigate={() => setMobileOpen(false)} onClose={() => setMobileOpen(false)} />
          </div>
        </div>
      ) : null}

      <div className={cn('min-w-0 flex-1 transition-[padding] duration-200', collapsed ? 'lg:pl-[72px]' : 'lg:pl-[260px]')}>
        <header className="sticky top-0 z-40 border-b bg-[var(--card)]/95 backdrop-blur">
          <div className="flex h-16 items-center justify-between gap-3 px-4 sm:px-6">
            <div className="flex min-w-0 items-center gap-3">
              <Button variant="ghost" size="icon" onClick={() => setMobileOpen(true)} className="lg:hidden" aria-label="Open navigation">
                <Menu className="h-5 w-5" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setCollapsed((value) => !value)}
                className="hidden lg:inline-flex"
                aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
              >
                {collapsed ? <ChevronsRight className="h-4 w-4" /> : <ChevronsLeft className="h-4 w-4" />}
              </Button>
              <div className="min-w-0">
                <p className="text-xs text-[var(--muted-foreground)]">Admin / {current?.label ?? 'Dashboard'}</p>
                <h1 className="truncate text-lg font-semibold">{current?.label ?? 'Dashboard'}</h1>
              </div>
            </div>

            <div className="hidden min-w-0 flex-1 justify-center px-6 md:flex">
              <div className="flex h-10 w-full max-w-md items-center gap-2 rounded-xl border bg-[var(--muted)] px-3 text-sm text-[var(--muted-foreground)]">
                <Search className="h-4 w-4" />
                <span>Search users, reports, config...</span>
              </div>
            </div>

            <div className="relative flex items-center gap-2">
              <Button variant="ghost" size="icon" aria-label="Toggle theme" onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>
                <Sun className="hidden h-4 w-4 dark:block" />
                <Moon className="h-4 w-4 dark:hidden" />
              </Button>
              <button
                className="flex items-center gap-2 rounded-xl border bg-[var(--card)] px-2 py-1.5 text-left hover:bg-[var(--muted)]"
                onClick={() => setUserOpen((value) => !value)}
                aria-label="Open admin menu"
              >
                <Avatar src={profile?.picture} name={profile?.name ?? profile?.email} />
                <div className="hidden min-w-0 pr-1 sm:block">
                  <p className="truncate text-sm font-medium">{profile?.name ?? 'Admin'}</p>
                  <p className="truncate text-xs text-[var(--muted-foreground)]">{profile?.email}</p>
                </div>
              </button>
              {userOpen ? (
                <div className="absolute right-0 top-12 z-50 w-72 rounded-xl border bg-[var(--popover)] p-2 text-[var(--popover-foreground)] shadow-lg">
                  <div className="p-3">
                    <p className="font-semibold">{profile?.name ?? 'Admin'}</p>
                    <p className="mt-1 truncate text-sm text-[var(--muted-foreground)]">{profile?.email}</p>
                    <Badge className="mt-3" variant="success">Admin</Badge>
                  </div>
                  <div className="border-t pt-2">
                    <button className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm hover:bg-[var(--muted)]" onClick={logout}>
                      <LogOut className="h-4 w-4" />
                      Logout
                    </button>
                  </div>
                </div>
              ) : null}
            </div>
          </div>
        </header>
        <main className="mx-auto max-w-[1440px] p-4 sm:p-6 lg:p-8">{children}</main>
      </div>
    </div>
  );
}

function Sidebar({
  collapsed,
  pathname,
  onNavigate,
  onClose
}: {
  collapsed: boolean;
  pathname: string;
  onNavigate: () => void;
  onClose?: () => void;
}) {
  return (
    <aside className={cn('flex h-full flex-col border-r bg-[var(--sidebar)] text-[var(--sidebar-foreground)] shadow-sm transition-[width] duration-200', collapsed ? 'w-[72px]' : 'w-[260px]')}>
      <div className="flex h-20 items-center justify-between border-b px-4">
        <div className="flex min-w-0 items-center gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[var(--primary)] text-sm font-bold text-[var(--primary-foreground)]">
            S
          </div>
          {!collapsed ? (
            <div className="min-w-0">
              <p className="truncate text-base font-semibold">SYNAPSE</p>
              <p className="truncate text-xs text-[var(--muted-foreground)]">Firebase Admin Console</p>
            </div>
          ) : null}
        </div>
        {onClose ? (
          <Button variant="ghost" size="icon" onClick={onClose} aria-label="Close navigation">
            <X className="h-4 w-4" />
          </Button>
        ) : null}
      </div>

      <nav className="flex-1 overflow-y-auto p-3">
        {navGroups.map((group) => (
          <div key={group.label} className="mb-5">
            {!collapsed ? <p className="mb-2 px-3 text-[11px] font-semibold uppercase tracking-wide text-[var(--muted-foreground)]">{group.label}</p> : null}
            <div className="space-y-1">
              {group.items.map((item) => {
                const Icon = item.icon;
                const active = pathname.startsWith(item.href);
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    title={collapsed ? item.label : undefined}
                    onClick={onNavigate}
                    className={cn(
                      'flex h-10 items-center gap-3 rounded-xl px-3 text-sm font-medium transition-colors hover:bg-[var(--muted)]',
                      collapsed && 'justify-center px-0',
                      active && 'bg-indigo-50 text-indigo-700 dark:bg-indigo-950 dark:text-indigo-200'
                    )}
                  >
                    <Icon className="h-4 w-4 shrink-0" />
                    {!collapsed ? <span className="truncate">{item.label}</span> : null}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="border-t p-3">
        <div className={cn('rounded-xl border bg-[var(--card)] p-3', collapsed && 'flex justify-center p-2')} title="synapse-prm393: Firebase connected">
          {collapsed ? (
            <span className="h-2.5 w-2.5 rounded-full bg-emerald-500" />
          ) : (
            <div className="flex items-center gap-3">
              <span className="h-2.5 w-2.5 rounded-full bg-emerald-500" />
              <div className="min-w-0">
                <p className="truncate text-sm font-medium">synapse-prm393</p>
                <p className="truncate text-xs text-[var(--muted-foreground)]">Firebase connected</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </aside>
  );
}
