import { create } from 'zustand';

interface UserState {
  user: any | null;
  token: string | null;
  login: (user: any, token: string) => void;
  logout: () => void;
}

export const useUserStore = create<UserState>((set) => ({
  user: typeof window !== 'undefined' ? JSON.parse(localStorage.getItem('user') || 'null') : null,
  token: typeof window !== 'undefined' ? localStorage.getItem('token') : null,
  login: (user, token) => {
    localStorage.setItem('user', JSON.stringify(user));
    localStorage.setItem('token', token);
    set({ user, token });
  },
  logout: () => {
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    set({ user: null, token: null });
  },
}));
