"use client";

import clsx from "clsx";
import {
  BookOpen,
  CalendarDays,
  FileQuestion,
  Home,
  Layers,
  LogOut,
  Menu,
  Newspaper,
  Shield,
  Users,
  X
} from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

const navItems = [
  { href: "/", label: "Dashboard", icon: Home },
  { href: "/kotoba", label: "Kotoba", icon: BookOpen },
  { href: "/jft/sets", label: "Paket JFT", icon: FileQuestion },
  { href: "/jft", label: "Soal JFT", icon: FileQuestion },
  { href: "/jlpt/sets", label: "Paket JLPT", icon: FileQuestion },
  { href: "/jlpt", label: "Soal JLPT", icon: FileQuestion },
  { href: "/ssw/categories", label: "Kategori SSW", icon: Layers },
  { href: "/ssw/modules", label: "Modul SSW", icon: Layers },
  { href: "/ssw/questions", label: "Soal SSW", icon: FileQuestion },
  { href: "/exam-schedules", label: "Jadwal Ujian", icon: CalendarDays },
  { href: "/japan-news", label: "Berita Jepang", icon: Newspaper },
  { href: "/users", label: "Users", icon: Users }
];

export function AdminShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const { profile, signOut } = useAuth();
  const [mobileOpen, setMobileOpen] = useState(false);

  const sidebar = (
    <aside className="sidebar">
      <div className="brand">
        <span className="brand-mark">
          <Image
            className="brand-logo"
            src="/brand/nihon-e-ikitai-mark.svg"
            alt=""
            aria-hidden="true"
            width={38}
            height={38}
            priority
            unoptimized
          />
        </span>
        <div>
          <div className="brand-title">Nihon e Ikitai</div>
          <div className="brand-subtitle">Admin Console</div>
        </div>
      </div>
      <nav className="nav">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = pathname === item.href;
          return (
            <Link
              className={clsx("nav-link", active && "active")}
              href={item.href}
              key={item.href}
              onClick={() => setMobileOpen(false)}
            >
              <Icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="sidebar-footer">
        <div>
          <strong>{profile?.displayName ?? profile?.email ?? "Admin"}</strong>
          <div className="brand-subtitle">{profile?.role}</div>
        </div>
        <button className="btn btn-ghost" onClick={signOut}>
          <LogOut size={18} />
          Keluar
        </button>
      </div>
    </aside>
  );

  return (
    <div className="shell">
      {sidebar}
      {mobileOpen ? <div className="mobile-drawer">{sidebar}</div> : null}
      <div className="main">
        <header className="topbar">
          <button
            className="btn btn-ghost mobile-menu"
            onClick={() => setMobileOpen((value) => !value)}
            aria-label="Menu"
          >
            {mobileOpen ? <X size={18} /> : <Menu size={18} />}
          </button>
          <div className="button-row">
            <Shield size={18} />
            <strong>Admin</strong>
          </div>
          <span className="muted">{profile?.email ?? profile?.phoneNumber}</span>
        </header>
        <main className="content">{children}</main>
      </div>
    </div>
  );
}
