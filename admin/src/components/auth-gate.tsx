"use client";

import { LoaderCircle } from "lucide-react";
import { AdminShell } from "./admin-shell";
import { LoginPanel } from "./login-panel";
import { useAuth } from "@/lib/auth";

export function AuthGate({ children }: { children: React.ReactNode }) {
  const { profile, loading } = useAuth();

  if (loading) {
    return (
      <main className="auth-screen">
        <div className="login-panel">
          <div className="button-row">
            <LoaderCircle className="spin" size={18} />
            <strong>Memuat sesi admin</strong>
          </div>
        </div>
      </main>
    );
  }

  if (!profile) {
    return <LoginPanel />;
  }

  return <AdminShell>{children}</AdminShell>;
}

