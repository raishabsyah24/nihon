"use client";

import { KeyRound, Mail, Phone, ShieldCheck } from "lucide-react";
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
    registerWithEmail,
    sendPhoneOtp,
    verifyPhoneOtp,
    useDemoAdmin
  } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState("");

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
          <p className="muted">Konten kursus, soal, jadwal, dan berita dikelola dari sini.</p>
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

          <div className="field">
            <label htmlFor="phone">Nomor HP</label>
            <input
              className="input"
              id="phone"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+628123456789"
            />
          </div>
          <div className="button-row">
            <button
              className="btn btn-secondary"
              disabled={busy}
              onClick={() => sendPhoneOtp(phone)}
            >
              <Phone size={18} />
              Kirim OTP
            </button>
          </div>
          <div className="field">
            <label htmlFor="otp">Kode OTP</label>
            <input
              className="input"
              id="otp"
              value={otp}
              onChange={(event) => setOtp(event.target.value)}
            />
          </div>
          <button
            className="btn btn-ghost"
            disabled={busy}
            onClick={() => verifyPhoneOtp(otp)}
          >
            <ShieldCheck size={18} />
            Verifikasi OTP
          </button>

          <button className="btn btn-ghost" disabled={busy} onClick={useDemoAdmin}>
            Demo Admin
          </button>
          <div id="admin-recaptcha" />
        </div>
      </section>
    </main>
  );
}
