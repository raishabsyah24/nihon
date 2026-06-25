"use client";

import { AlertTriangle, RefreshCw, Users } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { apiFetch, type JsonRecord } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { formatDateTime, stringifyCell } from "@/lib/format";

const columns = ["displayName", "email", "role", "createdAt"];

export function UsersPage() {
  const { token } = useAuth();
  const [items, setItems] = useState<JsonRecord[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const loadItems = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const rows = await apiFetch<JsonRecord[]>("/admin/users", token);
      setItems(rows);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    void loadItems();
  }, [loadItems]);

  return (
    <>
      <div className="page-heading">
        <div>
          <h1>Users</h1>
          <p className="muted">Daftar akun dari backend.</p>
        </div>
        <button className="btn btn-ghost" onClick={loadItems} disabled={loading}>
          <RefreshCw size={18} />
          Refresh
        </button>
      </div>

      {error ? (
        <div className="notice" style={{ marginBottom: 16 }}>
          <AlertTriangle size={18} />
          {error}
        </div>
      ) : null}

      <section className="panel">
        <div className="toolbar">
          <div className="button-row">
            <Users size={18} />
            <strong>{items.length} user</strong>
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                {columns.map((column) => (
                  <th key={column}>{column}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={String(item.id)}>
                  {columns.map((column) => (
                    <td key={column}>
                      {column.endsWith("At")
                        ? formatDateTime(item[column])
                        : stringifyCell(item[column])}
                    </td>
                  ))}
                </tr>
              ))}
              {items.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className="muted">
                    Data kosong.
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>
      </section>
    </>
  );
}
