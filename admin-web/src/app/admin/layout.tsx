import { AdminShell } from '@/components/admin/admin-shell';
import { ProtectedAdmin } from '@/components/admin/protected-admin';

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <ProtectedAdmin>
      <AdminShell>{children}</AdminShell>
    </ProtectedAdmin>
  );
}
