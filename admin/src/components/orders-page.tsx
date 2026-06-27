"use client";

import {
  AlertTriangle,
  CheckCircle2,
  ClipboardList,
  RefreshCw,
  Search,
  XCircle
} from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { apiFetch } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { formatDateTime } from "@/lib/format";

type OrderStatus = "PENDING" | "PAID" | "CANCELLED";

type Order = {
  id: string;
  orderNumber: string;
  status: OrderStatus;
  subtotal: number;
  promoDiscount: number;
  voucherDiscount: number;
  pointDiscount: number;
  total: number;
  currency: string;
  pointsUsed: number;
  pointsEarned: number;
  createdAt: string;
  paidAt?: string | null;
  cancelledAt?: string | null;
  user?: {
    email?: string | null;
    displayName?: string | null;
    phoneNumber?: string | null;
  } | null;
  items?: Array<{
    id: string;
    titleSnapshot: string;
    price: number;
    quantity: number;
    subtotal: number;
    package?: {
      title: string;
      slug: string;
      kind: string;
      level?: string | null;
      category?: string | null;
    };
  }>;
};

const statuses: Array<"ALL" | OrderStatus> = [
  "ALL",
  "PENDING",
  "PAID",
  "CANCELLED"
];

export function OrdersPage() {
  const { token } = useAuth();
  const [items, setItems] = useState<Order[]>([]);
  const [status, setStatus] = useState<"ALL" | OrderStatus>("ALL");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadItems = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const query = status === "ALL" ? "" : `?status=${status}`;
      const rows = await apiFetch<Order[]>(`/admin/orders${query}`, token);
      setItems(rows);
    } catch (err) {
      setError(errorMessage(err));
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, [status, token]);

  useEffect(() => {
    void loadItems();
  }, [loadItems]);

  const filteredItems = useMemo(() => {
    const needle = search.trim().toLowerCase();
    if (!needle) {
      return items;
    }

    return items.filter((item) =>
      [
        item.orderNumber,
        item.status,
        item.user?.email,
        item.user?.displayName,
        ...(item.items?.map((row) => row.titleSnapshot) ?? [])
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(needle)
    );
  }, [items, search]);

  async function updateStatus(order: Order, nextStatus: OrderStatus) {
    setUpdatingId(order.id);
    setError(null);
    try {
      await apiFetch(`/admin/orders/${order.id}/status`, token, {
        method: "PATCH",
        body: JSON.stringify({ status: nextStatus })
      });
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setUpdatingId(null);
    }
  }

  return (
    <>
      <div className="page-heading">
        <div>
          <h1>Order</h1>
          <p className="muted">
            Verifikasi order manual dan buka akses paket setelah pembayaran.
          </p>
        </div>
        <button className="btn btn-ghost" onClick={loadItems} disabled={loading}>
          <RefreshCw className={loading ? "spin" : undefined} size={18} />
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
            <ClipboardList size={18} />
            <strong>{filteredItems.length} order</strong>
          </div>
          <div className="button-row">
            <select
              className="select"
              style={{ minWidth: 150 }}
              value={status}
              onChange={(event) =>
                setStatus(event.target.value as "ALL" | OrderStatus)
              }
            >
              {statuses.map((option) => (
                <option key={option}>{option}</option>
              ))}
            </select>
            <label className="search">
              <span className="sr-only">Cari order</span>
              <div style={{ position: "relative" }}>
                <Search
                  size={16}
                  style={{ left: 10, position: "absolute", top: 12 }}
                />
                <input
                  className="input"
                  style={{ paddingLeft: 34 }}
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder="Cari order"
                />
              </div>
            </label>
          </div>
        </div>

        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Order</th>
                <th>User</th>
                <th>Paket</th>
                <th>Total</th>
                <th>Point</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {filteredItems.map((item) => (
                <tr key={item.id}>
                  <td>
                    <strong>{item.orderNumber}</strong>
                    <div className="muted">{formatDateTime(item.createdAt)}</div>
                    {item.paidAt ? (
                      <div className="muted">Paid: {formatDateTime(item.paidAt)}</div>
                    ) : null}
                    {item.cancelledAt ? (
                      <div className="muted">
                        Cancelled: {formatDateTime(item.cancelledAt)}
                      </div>
                    ) : null}
                  </td>
                  <td>
                    <strong>
                      {item.user?.displayName ?? item.user?.email ?? "-"}
                    </strong>
                    <div className="muted">{item.user?.email ?? ""}</div>
                    <div className="muted">{item.user?.phoneNumber ?? ""}</div>
                  </td>
                  <td>
                    <div className="mini-list">
                      {item.items?.map((row) => (
                        <div key={row.id}>
                          <strong>{row.titleSnapshot}</strong>
                          <div className="muted">
                            {row.package?.kind ?? "-"} ·{" "}
                            {formatCurrency(row.subtotal, item.currency)}
                          </div>
                        </div>
                      ))}
                    </div>
                  </td>
                  <td>
                    <strong>{formatCurrency(item.total, item.currency)}</strong>
                    <div className="muted">
                      Subtotal {formatCurrency(item.subtotal, item.currency)}
                    </div>
                    <div className="muted">
                      Diskon{" "}
                      {formatCurrency(
                        item.promoDiscount +
                          item.voucherDiscount +
                          item.pointDiscount,
                        item.currency
                      )}
                    </div>
                  </td>
                  <td>
                    <strong>+{item.pointsEarned}</strong>
                    <div className="muted">Pakai {item.pointsUsed}</div>
                  </td>
                  <td>
                    <OrderStatusPill status={item.status} />
                  </td>
                  <td>
                    <div className="button-row">
                      <button
                        className="btn btn-primary"
                        onClick={() => updateStatus(item, "PAID")}
                        disabled={item.status !== "PENDING" || updatingId === item.id}
                      >
                        <CheckCircle2 size={16} />
                        Paid
                      </button>
                      <button
                        className="btn btn-danger"
                        onClick={() => updateStatus(item, "CANCELLED")}
                        disabled={item.status !== "PENDING" || updatingId === item.id}
                      >
                        <XCircle size={16} />
                        Cancel
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {!filteredItems.length ? (
                <tr>
                  <td colSpan={7}>
                    <span className="muted">
                      {loading ? "Memuat order..." : "Belum ada order."}
                    </span>
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

function OrderStatusPill({ status }: { status: OrderStatus }) {
  const className =
    status === "PAID"
      ? "status-pill status-paid"
      : status === "CANCELLED"
        ? "status-pill status-cancelled"
        : "status-pill status-pending";

  return <span className={className}>{status}</span>;
}

function formatCurrency(value: number, currency = "IDR") {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency,
    maximumFractionDigits: 0
  }).format(value);
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : String(error);
}
