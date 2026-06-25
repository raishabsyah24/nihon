"use client";

import {
  GoogleAuthProvider,
  User,
  createUserWithEmailAndPassword,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut as firebaseSignOut
} from "firebase/auth";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode
} from "react";
import { apiFetch } from "./api";
import { getFirebaseAuth, hasFirebaseConfig } from "./firebase";

export type AdminProfile = {
  id: string;
  role: string;
  email?: string | null;
  displayName?: string | null;
  photoUrl?: string | null;
};

type AuthContextValue = {
  profile: AdminProfile | null;
  token: string | null;
  loading: boolean;
  busy: boolean;
  error: string | null;
  firebaseConfigured: boolean;
  loginWithGoogle: () => Promise<void>;
  loginWithEmail: (email: string, password: string) => Promise<void>;
  registerWithEmail: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<AdminProfile | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const firebaseConfigured = hasFirebaseConfig();

  const loadBackendProfile = useCallback(async (user: User) => {
    const idToken = await user.getIdToken();
    setToken(idToken);
    const backendProfile = await apiFetch<AdminProfile>("/me", idToken);

    if (backendProfile.role?.toUpperCase() !== "ADMIN") {
      setProfile(null);
      throw new Error("Akun ini belum memiliki role ADMIN.");
    }

    setProfile(backendProfile);
  }, []);

  useEffect(() => {
    const auth = getFirebaseAuth();
    if (!auth) {
      setLoading(false);
      return;
    }

    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      setLoading(true);

      try {
        if (!user) {
          setProfile(null);
          setToken(null);
          return;
        }

        setError(null);
        await loadBackendProfile(user);
      } catch (err) {
        setError(errorMessage(err));
        setProfile(null);
        setToken(null);
        await firebaseSignOut(auth);
      } finally {
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, [loadBackendProfile]);

  const guarded = useCallback(async (action: () => Promise<void>) => {
    setBusy(true);
    setError(null);
    try {
      await action();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  }, []);

  const loginWithGoogle = useCallback(async () => {
    await guarded(async () => {
      const auth = requireAuth();
      await signInWithPopup(auth, new GoogleAuthProvider());
    });
  }, [guarded]);

  const loginWithEmail = useCallback(
    async (email: string, password: string) => {
      await guarded(async () => {
        const auth = requireAuth();
        await signInWithEmailAndPassword(auth, email.trim(), password);
      });
    },
    [guarded]
  );

  const registerWithEmail = useCallback(
    async (email: string, password: string) => {
      await guarded(async () => {
        const auth = requireAuth();
        await createUserWithEmailAndPassword(auth, email.trim(), password);
      });
    },
    [guarded]
  );

  const signOut = useCallback(async () => {
    await guarded(async () => {
      const auth = getFirebaseAuth();
      if (auth) {
        await firebaseSignOut(auth);
      }
      setProfile(null);
      setToken(null);
    });
  }, [guarded]);

  const value = useMemo<AuthContextValue>(
    () => ({
      profile,
      token,
      loading,
      busy,
      error,
      firebaseConfigured,
      loginWithGoogle,
      loginWithEmail,
      registerWithEmail,
      signOut
    }),
    [
      profile,
      token,
      loading,
      busy,
      error,
      firebaseConfigured,
      loginWithGoogle,
      loginWithEmail,
      registerWithEmail,
      signOut
    ]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) {
    throw new Error("useAuth must be used inside AuthProvider.");
  }
  return value;
}

function requireAuth() {
  const auth = getFirebaseAuth();
  if (!auth) {
    throw new Error("Firebase belum dikonfigurasi.");
  }
  return auth;
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : String(error);
}
