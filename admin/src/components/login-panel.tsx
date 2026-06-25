"use client";

import { KeyRound, Mail, ShieldCheck } from "lucide-react";
import Image from "next/image";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

export function LoginPanel() {
  const {
    busy,
    error,
    firebaseConfigured,
    loginWithGoogle,
    loginWithEmail,
    registerWithEmail
  } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  return (
    <main className="auth-screen">
      <section className="login-panel">
        <div className="login-brand">
          <Image
            className="admin-logo"
            src="/brand/nihon-e-ikitai-admin-logo.svg"
            alt="Nihon e Ikitai Admin"
            width={420}
            height={92}
            priority
            unoptimized
          />
          <h1 style={{ marginTop: 18 }}>Masuk Admin</h1>
          <p className="muted">
            Konten kursus, soal, jadwal, dan berita dikelola dari sini.
          </p>
        </div>

        <div className="login-grid">
          {error ? <div className="notice">{error}</div> : null}
          {!firebaseConfigured ? (
            <div className="notice">Firebase belum dikonfigurasi di env admin.</div>
          ) : null}

          <button className="btn btn-cta" disabled={busy} onClick={loginWithGoogle}>
            <ShieldCheck size={18} />
            Google
          </button>

          <div className="field">
            <label htmlFor="email">Email</label>
            <input
              className="input"
              id="email"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="admin@email.com"
            />
          </div>
          <div className="field">
            <label htmlFor="password">Password</label>
            <input
              className="input"
              id="password"
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
            />
          </div>
          <div className="button-row">
            <button
              className="btn btn-cta"
              disabled={busy}
              onClick={() => loginWithEmail(email, password)}
            >
              <Mail size={18} />
              Login Email
            </button>
            <button
              className="btn btn-ghost"
              disabled={busy}
              onClick={() => registerWithEmail(email, password)}
            >
              <KeyRound size={18} />
              Daftar
            </button>
          </div>
        </div>
      </section>
    </main>
  );
}
