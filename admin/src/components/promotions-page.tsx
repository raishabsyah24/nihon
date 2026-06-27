"use client";

import {
  AlertTriangle,
  Archive,
  BadgePercent,
  Edit3,
  Eye,
  EyeOff,
  Plus,
  RefreshCw,
  Save,
  Ticket,
  X
} from "lucide-react";
import { FormEvent, useCallback, useEffect, useMemo, useState } from "react";
import { apiFetch } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { formatDateTime } from "@/lib/format";

type DiscountMode = "promos" | "vouchers";
type DiscountKind = "FIXED_AMOUNT" | "PERCENTAGE";
type PublishStatus = "DRAFT" | "PUBLISHED";
type PackageKind =
  | "JFT_MATERIAL"
  | "JFT_QUESTION"
  | "JLPT_MATERIAL"
  | "JLPT_QUESTION"
  | "SSW_QUESTION";

type DiscountItem = {
  id: string;
  code?: string | null;
  title: string;
  description?: string | null;
  discountKind: DiscountKind;
  discountValue: number;
  maxDiscount?: number | null;
  minimumSubtotal: number;
  targetKind?: PackageKind | null;
  startsAt?: string | null;
  endsAt?: string | null;
  usageLimit?: number | null;
  usedCount: number;
  perUserLimit?: number;
  stackable?: boolean;
  status: PublishStatus;
  createdAt: string;
};

type DiscountForm = {
  code: string;
  title: string;
  description: string;
  discountKind: DiscountKind;
  discountValue: string;
  maxDiscount: string;
  minimumSubtotal: string;
  targetKind: "" | PackageKind;
  startsAt: string;
  endsAt: string;
  usageLimit: string;
  perUserLimit: string;
  stackable: boolean;
  status: PublishStatus;
};

const packageKinds: PackageKind[] = [
  "JFT_MATERIAL",
  "JFT_QUESTION",
  "JLPT_MATERIAL",
  "JLPT_QUESTION",
  "SSW_QUESTION"
];

const emptyForm: DiscountForm = {
  code: "",
  title: "",
  description: "",
  discountKind: "FIXED_AMOUNT",
  discountValue: "0",
  maxDiscount: "",
  minimumSubtotal: "0",
  targetKind: "",
  startsAt: "",
  endsAt: "",
  usageLimit: "",
  perUserLimit: "1",
  stackable: false,
  status: "DRAFT"
};

export function PromotionsPage() {
  const { token } = useAuth();
  const [mode, setMode] = useState<DiscountMode>("promos");
  const [promos, setPromos] = useState<DiscountItem[]>([]);
  const [vouchers, setVouchers] = useState<DiscountItem[]>([]);
  const [form, setForm] = useState<DiscountForm>(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadItems = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [promoRows, voucherRows] = await Promise.all([
        apiFetch<DiscountItem[]>("/admin/promos", token),
        apiFetch<DiscountItem[]>("/admin/vouchers", token)
      ]);
      setPromos(promoRows);
      setVouchers(voucherRows);
    } catch (err) {
      setError(errorMessage(err));
      setPromos([]);
      setVouchers([]);
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    void loadItems();
  }, [loadItems]);

  const activeItems = mode === "promos" ? promos : vouchers;
  const filteredItems = useMemo(() => {
    const needle = search.trim().toLowerCase();
    if (!needle) {
      return activeItems;
    }

    return activeItems.filter((item) =>
      [
        item.code,
        item.title,
        item.description,
        item.discountKind,
        item.targetKind,
        item.status
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(needle)
    );
  }, [activeItems, search]);

  const modeLabel = mode === "promos" ? "Promo" : "Voucher";

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const endpoint = mode === "promos" ? "/admin/promos" : "/admin/vouchers";
      await apiFetch(editingId ? `${endpoint}/${editingId}` : endpoint, token, {
        method: editingId ? "PATCH" : "POST",
        body: JSON.stringify(payloadFromForm(form, mode))
      });
      cancelEdit();
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function toggleStatus(item: DiscountItem) {
    setSaving(true);
    setError(null);
    try {
      const endpoint = mode === "promos" ? "/admin/promos" : "/admin/vouchers";
      const status = item.status === "PUBLISHED" ? "DRAFT" : "PUBLISHED";
      await apiFetch(`${endpoint}/${item.id}`, token, {
        method: "PATCH",
        body: JSON.stringify({ status })
      });
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function archiveItem(item: DiscountItem) {
    setSaving(true);
    setError(null);
    try {
      const endpoint = mode === "promos" ? "/admin/promos" : "/admin/vouchers";
      await apiFetch(`${endpoint}/${item.id}`, token, { method: "DELETE" });
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function editItem(item: DiscountItem) {
    setEditingId(item.id);
    setForm(formFromItem(item));
  }

  function cancelEdit() {
    setEditingId(null);
    setForm(emptyForm);
  }

  function changeMode(nextMode: DiscountMode) {
    setMode(nextMode);
    setSearch("");
    cancelEdit();
  }

  return (
    <>
      <div className="page-heading">
        <div>
          <h1>Promo & Voucher</h1>
          <p className="muted">
            Promo otomatis memotong harga sesuai minimum belanja. Voucher dipakai
            user lewat kolom redeem saat checkout.
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

      <div className="button-row" style={{ marginBottom: 16 }}>
        <button
          className={mode === "promos" ? "btn btn-primary" : "btn btn-ghost"}
          onClick={() => changeMode("promos")}
          type="button"
        >
          <BadgePercent size={18} />
          Promo Otomatis
        </button>
        <button
          className={mode === "vouchers" ? "btn btn-primary" : "btn btn-ghost"}
          onClick={() => changeMode("vouchers")}
          type="button"
        >
          <Ticket size={18} />
          Voucher Redeem
        </button>
      </div>

      <div className="resource-layout">
        <section className="panel">
          <div className="toolbar">
            <div className="button-row">
              {mode === "promos" ? (
                <BadgePercent size={18} />
              ) : (
                <Ticket size={18} />
              )}
              <strong>{filteredItems.length} data</strong>
            </div>
            <label className="search">
              <span className="sr-only">Cari {modeLabel}</span>
              <input
                className="input"
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                placeholder={`Cari ${modeLabel.toLowerCase()}`}
              />
            </label>
          </div>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>{modeLabel}</th>
                  <th>Diskon</th>
                  <th>Minimum</th>
                  <th>Target</th>
                  <th>Periode</th>
                  <th>Status</th>
                  <th>Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filteredItems.map((item) => (
                  <tr key={item.id}>
                    <td>
                      <strong>{item.title}</strong>
                      <div className="muted">
                        {item.code ? item.code : "Auto promo"}
                      </div>
                      <div className="muted">{item.description ?? ""}</div>
                    </td>
                    <td>
                      <strong>{discountLabel(item)}</strong>
                      <div className="muted">
                        Maks {moneyOrDash(item.maxDiscount)}
                      </div>
                    </td>
                    <td>{formatCurrency(item.minimumSubtotal)}</td>
                    <td>{item.targetKind ?? "Semua paket"}</td>
                    <td>
                      <div>{item.startsAt ? formatDateTime(item.startsAt) : "-"}</div>
                      <div className="muted">
                        s/d {item.endsAt ? formatDateTime(item.endsAt) : "-"}
                      </div>
                    </td>
                    <td>
                      <StatusPill status={item.status} />
                      <div className="muted">
                        Pakai {item.usedCount}/{item.usageLimit ?? "∞"}
                      </div>
                    </td>
                    <td>
                      <div className="button-row">
                        <button
                          className="btn btn-ghost"
                          disabled={saving}
                          onClick={() => editItem(item)}
                          title="Edit"
                          type="button"
                        >
                          <Edit3 size={16} />
                        </button>
                        <button
                          className="btn btn-ghost"
                          disabled={saving}
                          onClick={() => toggleStatus(item)}
                          title={item.status === "PUBLISHED" ? "Draft" : "Publish"}
                          type="button"
                        >
                          {item.status === "PUBLISHED" ? (
                            <EyeOff size={16} />
                          ) : (
                            <Eye size={16} />
                          )}
                        </button>
                        <button
                          className="btn btn-danger"
                          disabled={saving}
                          onClick={() => archiveItem(item)}
                          title="Archive"
                          type="button"
                        >
                          <Archive size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {!filteredItems.length ? (
                  <tr>
                    <td colSpan={7}>
                      <span className="muted">
                        {loading ? "Memuat data..." : "Belum ada data."}
                      </span>
                    </td>
                  </tr>
                ) : null}
              </tbody>
            </table>
          </div>
        </section>

        <section className="panel">
          <form className="form-grid" onSubmit={submit}>
            <div className="toolbar">
              <div className="button-row">
                {editingId ? <Edit3 size={18} /> : <Plus size={18} />}
                <strong>{editingId ? `Edit ${modeLabel}` : `${modeLabel} baru`}</strong>
              </div>
              {editingId ? (
                <button className="btn btn-ghost" onClick={cancelEdit} type="button">
                  <X size={16} />
                  Batal
                </button>
              ) : null}
            </div>

            <Field label={mode === "promos" ? "Kode Promo" : "Kode Voucher"}>
              <input
                className="input"
                value={form.code}
                onChange={(event) =>
                  setForm((current) => ({ ...current, code: event.target.value }))
                }
                placeholder={mode === "promos" ? "Kosongkan untuk auto" : "NIHON10"}
                required={mode === "vouchers"}
              />
            </Field>

            <Field label="Judul">
              <input
                className="input"
                value={form.title}
                onChange={(event) =>
                  setForm((current) => ({ ...current, title: event.target.value }))
                }
                required
              />
            </Field>

            <Field label="Deskripsi">
              <textarea
                className="textarea"
                value={form.description}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    description: event.target.value
                  }))
                }
              />
            </Field>

            <div className="two-columns">
              <Field label="Tipe Diskon">
                <select
                  className="select"
                  value={form.discountKind}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      discountKind: event.target.value as DiscountKind
                    }))
                  }
                >
                  <option value="FIXED_AMOUNT">Nominal</option>
                  <option value="PERCENTAGE">Persen</option>
                </select>
              </Field>
              <Field label="Nilai Diskon">
                <input
                  className="input"
                  min="0"
                  type="number"
                  value={form.discountValue}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      discountValue: event.target.value
                    }))
                  }
                  required
                />
              </Field>
            </div>

            <div className="two-columns">
              <Field label="Maks Diskon">
                <input
                  className="input"
                  min="0"
                  type="number"
                  value={form.maxDiscount}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      maxDiscount: event.target.value
                    }))
                  }
                  placeholder="Opsional"
                />
              </Field>
              <Field label="Minimum Belanja">
                <input
                  className="input"
                  min="0"
                  type="number"
                  value={form.minimumSubtotal}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      minimumSubtotal: event.target.value
                    }))
                  }
                />
              </Field>
            </div>

            <Field label="Target Paket">
              <select
                className="select"
                value={form.targetKind}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    targetKind: event.target.value as "" | PackageKind
                  }))
                }
              >
                <option value="">Semua paket</option>
                {packageKinds.map((kind) => (
                  <option key={kind} value={kind}>
                    {kind}
                  </option>
                ))}
              </select>
            </Field>

            <div className="two-columns">
              <Field label="Mulai">
                <input
                  className="input"
                  type="datetime-local"
                  value={form.startsAt}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      startsAt: event.target.value
                    }))
                  }
                />
              </Field>
              <Field label="Selesai">
                <input
                  className="input"
                  type="datetime-local"
                  value={form.endsAt}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      endsAt: event.target.value
                    }))
                  }
                />
              </Field>
            </div>

            <div className="two-columns">
              <Field label="Limit Pakai">
                <input
                  className="input"
                  min="0"
                  type="number"
                  value={form.usageLimit}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      usageLimit: event.target.value
                    }))
                  }
                  placeholder="Tidak terbatas"
                />
              </Field>
              {mode === "vouchers" ? (
                <Field label="Limit/User">
                  <input
                    className="input"
                    min="1"
                    type="number"
                    value={form.perUserLimit}
                    onChange={(event) =>
                      setForm((current) => ({
                        ...current,
                        perUserLimit: event.target.value
                      }))
                    }
                  />
                </Field>
              ) : (
                <Field label="Stackable">
                  <select
                    className="select"
                    value={form.stackable ? "true" : "false"}
                    onChange={(event) =>
                      setForm((current) => ({
                        ...current,
                        stackable: event.target.value === "true"
                      }))
                    }
                  >
                    <option value="false">Tidak</option>
                    <option value="true">Ya</option>
                  </select>
                </Field>
              )}
            </div>

            <Field label="Status">
              <select
                className="select"
                value={form.status}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    status: event.target.value as PublishStatus
                  }))
                }
              >
                <option>DRAFT</option>
                <option>PUBLISHED</option>
              </select>
            </Field>

            <button className="btn btn-cta" disabled={saving} type="submit">
              <Save size={18} />
              {saving ? "Menyimpan..." : "Simpan"}
            </button>
          </form>
        </section>
      </div>
    </>
  );
}

function Field({
  children,
  label
}: {
  children: React.ReactNode;
  label: string;
}) {
  return (
    <div className="field">
      <label>{label}</label>
      {children}
    </div>
  );
}

function StatusPill({ status }: { status: PublishStatus }) {
  return (
    <span
      className={
        status === "PUBLISHED"
          ? "status-pill status-published"
          : "status-pill status-draft"
      }
    >
      {status}
    </span>
  );
}

function payloadFromForm(form: DiscountForm, mode: DiscountMode) {
  return {
    code: nullable(form.code),
    title: form.title.trim(),
    description: nullable(form.description),
    discountKind: form.discountKind,
    discountValue: Number(form.discountValue),
    maxDiscount: nullableNumber(form.maxDiscount),
    minimumSubtotal: Number(form.minimumSubtotal || 0),
    targetKind: form.targetKind || null,
    startsAt: nullable(form.startsAt),
    endsAt: nullable(form.endsAt),
    usageLimit: nullableNumber(form.usageLimit),
    ...(mode === "vouchers"
      ? { perUserLimit: Number(form.perUserLimit || 1) }
      : { stackable: form.stackable }),
    status: form.status
  };
}

function formFromItem(item: DiscountItem): DiscountForm {
  return {
    code: item.code ?? "",
    title: item.title,
    description: item.description ?? "",
    discountKind: item.discountKind,
    discountValue: String(item.discountValue),
    maxDiscount: item.maxDiscount == null ? "" : String(item.maxDiscount),
    minimumSubtotal: String(item.minimumSubtotal ?? 0),
    targetKind: item.targetKind ?? "",
    startsAt: toDatetimeLocal(item.startsAt),
    endsAt: toDatetimeLocal(item.endsAt),
    usageLimit: item.usageLimit == null ? "" : String(item.usageLimit),
    perUserLimit: String(item.perUserLimit ?? 1),
    stackable: Boolean(item.stackable),
    status: item.status
  };
}

function discountLabel(item: DiscountItem) {
  if (item.discountKind === "PERCENTAGE") {
    return `${item.discountValue}%`;
  }

  return formatCurrency(item.discountValue);
}

function moneyOrDash(value?: number | null) {
  return value == null ? "-" : formatCurrency(value);
}

function formatCurrency(value: number, currency = "IDR") {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency,
    maximumFractionDigits: 0
  }).format(value);
}

function nullable(value?: string) {
  const text = value?.trim();
  return text ? text : null;
}

function nullableNumber(value: string) {
  const text = value.trim();
  return text ? Number(text) : null;
}

function toDatetimeLocal(value?: string | null) {
  if (!value) {
    return "";
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "";
  }

  const offset = date.getTimezoneOffset() * 60000;
  return new Date(date.getTime() - offset).toISOString().slice(0, 16);
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : String(error);
}
