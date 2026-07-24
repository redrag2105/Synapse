'use client';

import axios from 'axios';
import { signOut } from 'firebase/auth';
import { firebaseAuth } from '@/lib/firebase/client';

export const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE_URL ?? 'http://localhost:4000/api'
});

apiClient.interceptors.request.use(async (config) => {
  const user = firebaseAuth.currentUser;
  if (user) {
    const token = await user.getIdToken();
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await signOut(firebaseAuth);
      window.location.href = '/login';
    }
    if (error.response?.status === 403) {
      window.location.href = '/login?reason=forbidden';
    }
    return Promise.reject(error);
  }
);

export async function apiGet<T>(path: string) {
  const { data } = await apiClient.get<T>(path);
  return data;
}
