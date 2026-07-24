'use client';

import { User, getIdTokenResult, onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth';
import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { apiGet } from '@/lib/api/client';
import { firebaseAuth, googleProvider } from '@/lib/firebase/client';

type AdminProfile = {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
  admin: boolean;
};

type AuthContextValue = {
  user: User | null;
  profile: AdminProfile | null;
  initializing: boolean;
  authError: string | null;
  login: () => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<AdminProfile | null>(null);
  const [initializing, setInitializing] = useState(true);
  const [authError, setAuthError] = useState<string | null>(null);

  useEffect(() => {
    return onAuthStateChanged(
      firebaseAuth,
      async (nextUser) => {
        setUser(nextUser);
        setProfile(null);
        setAuthError(null);
        if (!nextUser) {
          setInitializing(false);
          return;
        }
        try {
          const token = await getIdTokenResult(nextUser, true);
          if (token.claims.admin !== true) {
            setAuthError('This account does not have admin access.');
            await signOut(firebaseAuth);
            setInitializing(false);
            return;
          }
          const adminProfile = await apiGet<AdminProfile>('/admin/profile');
          setProfile(adminProfile);
        } catch {
          setAuthError('Could not verify admin access. Check admin-api and Firebase configuration.');
          await signOut(firebaseAuth).catch(() => undefined);
        } finally {
          setInitializing(false);
        }
      },
      () => {
        setAuthError('Firebase Authentication could not initialize. Check the Firebase Web App configuration.');
        setInitializing(false);
      }
    );
  }, []);

  const value = useMemo<AuthContextValue>(() => ({
    user,
    profile,
    initializing,
    authError,
    login: async () => {
      setAuthError(null);
      const credential = await signInWithPopup(firebaseAuth, googleProvider);
      const token = await getIdTokenResult(credential.user, true);
      if (token.claims.admin !== true) {
        setAuthError('This account does not have admin access.');
        await signOut(firebaseAuth);
        return;
      }
      const adminProfile = await apiGet<AdminProfile>('/admin/profile');
      setProfile(adminProfile);
    },
    logout: async () => signOut(firebaseAuth)
  }), [authError, initializing, profile, user]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth must be used inside AuthProvider');
  return value;
}
