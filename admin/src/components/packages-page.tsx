"use client";

import {
  AlertTriangle,
  Archive,
  Edit3,
  Eye,
  EyeOff,
  PackagePlus,
  Plus,
  RefreshCw,
  Save,
  Search,
  X
} from "lucide-react";
import { FormEvent, useCallback, useEffect, useMemo, useState } from "react";
import { apiFetch } from "@/lib/api";
import { useAuth } from "@/lib/auth";

type ProductPackage = {
  id: string;
  kind: PackageKind;
  title: string;
  slug: string;
  subtitle?: string | null;
  previewDescription?: string | null;
  description?: string | null;
  level?: string | null;
  category?: string | null;
  price: number;
  currency: string;
  benefits?: unknown;
  metadata?: unknown;
  status: "DRAFT" | "PUBLISHED";
  sortOrder: number;
  contents?: PackageContent[];
};

type PackageContent = {
  contentType: ContentType;
  contentId: string;
  title?: string | null;
  sortOrder: number;
};

type PackageKind =
  | "JFT_MATERIAL"
  | "JFT_QUESTION"
  | "JLPT_MATERIAL"
  | "JLPT_QUESTION"
  | "SSW_QUESTION";

type ContentType =
  | "JFT_MATERIAL"
  | "JLPT_MATERIAL"
  | "QUESTION_SET"
  | "SSW_MODULE"
  | "SSW_CATEGORY";

type PackageForm = {
  kind: PackageKind;
  title: string;
  slug: string;
  subtitle: string;
  previewDescription: string;
  description: string;
  level: string;
  category: string;
  price: string;
  currency: string;
  benefits: string;
  metadata: string;
  status: "DRAFT" | "PUBLISHED";
  sortOrder: string;
  contents: string;
};

const kindOptions: PackageKind[] = [
  "JFT_MATERIAL",
  "JFT_QUESTION",
  "JLPT_MATERIAL",
  "JLPT_QUESTION",
  "SSW_QUESTION"
];

const contentTypeOptions: ContentType[] = [
  "JFT_MATERIAL",
  "JLPT_MATERIAL",
  "QUESTION_SET",
  "SSW_MODULE",
  "SSW_CATEGORY"
];

const emptyForm: PackageForm = {
  kind: "JFT_MATERIAL",
  title: "",
  slug: "",
  subtitle: "",
  previewDescription: "",
  description: "",
  level: "",
  category: "",
  price: "0",
  currency: "IDR",
  benefits: "",
  metadata: "",
  status: "DRAFT",
  sortOrder: "0",
  contents: ""
};

export function PackagesPage() {
  const { token } = useAuth();
  const [items, setItems] = useState<ProductPackage[]>([]);
  const [form, setForm] = useState<PackageForm>(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadItems = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const rows = await apiFetch<ProductPackage[]>("/admin/packages", token);
      setItems(rows);
    } catch (err) {
      setError(errorMessage(err));
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, [token]);

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
        item.title,
        item.slug,
        item.kind,
        item.level,
        item.category,
        item.status
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(needle)
    );
  }, [items, search]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const payload = payloadFromForm(form);
      await apiFetch(
        editingId ? `/admin/packages/${editingId}` : "/admin/packages",
        token,
        {
          method: editingId ? "PATCH" : "POST",
          body: JSON.stringify(payload)
        }
      );
      cancelEdit();
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function toggleStatus(item: ProductPackage) {
    setSaving(true);
    setError(null);
    try {
      const nextStatus = item.status === "PUBLISHED" ? "DRAFT" : "PUBLISHED";
      await apiFetch(`/admin/packages/${item.id}`, token, {
        method: "PATCH",
        body: JSON.stringify({ status: nextStatus })
      });
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function archivePackage(item: ProductPackage) {
    setSaving(true);
    setError(null);
    try {
      await apiFetch(`/admin/packages/${item.id}`, token, { method: "DELETE" });
      await loadItems();
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function editItem(item: ProductPackage) {
    setEditingId(item.id);
    setForm(formFromItem(item));
  }

  function cancelEdit() {
    setEditingId(null);
    setForm(emptyForm);
  }

  return (
    <>
      <div className="page-heading">
        <div>
          <h1>Paket Jualan</h1>
          <p className="muted">
            Kelola paket materi, soal, harga, dan mapping konten berbayar.
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

      <div className="resource-layout">
        <section className="panel">
          <div className="toolbar">
            <div className="button-row">
              <PackagePlus size={18} />
              <strong>{filteredItems.length} paket</strong>
            </div>
            <label className="search">
              <span className="sr-only">Cari paket</span>
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
                  placeholder="Cari paket"
                />
              </div>
            </label>
          </div>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Paket</th>
                  <th>Jenis</th>
                  <th>Level</th>
                  <th>Harga</th>
                  <th>Konten</th>
                  <th>Status</th>
                  <th>Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filteredItems.map((item) => (
                  <tr key={item.id}>
                    <td>
                      <strong>{item.title}</strong>
                      <div className="muted">{item.slug}</div>
                    </td>
                    <td>{item.kind}</td>
                    <td>
                      {item.level ?? "-"}
                      <div className="muted">{item.category ?? ""}</div>
                    </td>
                    <td>{formatCurrency(item.price, item.currency)}</td>
                    <td>{item.contents?.length ?? 0}</td>
                    <td>
                      <StatusPill status={item.status} />
                    </td>
                    <td>
                      <div className="button-row">
                        <button
                          className="btn btn-ghost"
                          onClick={() => editItem(item)}
                          disabled={saving}
                          title="Edit"
                          aria-label="Edit"
                        >
                          <Edit3 size={16} />
                        </button>
                        <button
                          className="btn btn-ghost"
                          onClick={() => toggleStatus(item)}
                          disabled={saving}
                          title={
                            item.status === "PUBLISHED"
                              ? "Jadikan draft"
                              : "Publish"
                          }
                          aria-label={
                            item.status === "PUBLISHED"
                              ? "Jadikan draft"
                              : "Publish"
                          }
                        >
                          {item.status === "PUBLISHED" ? (
                            <EyeOff size={16} />
                          ) : (
                            <Eye size={16} />
                          )}
                        </button>
                        <button
                          className="btn btn-danger"
                          onClick={() => archivePackage(item)}
                          disabled={saving}
                          title="Archive"
                          aria-label="Archive"
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
                        {loading ? "Memuat paket..." : "Belum ada paket."}
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
                <strong>{editingId ? "Edit paket" : "Paket baru"}</strong>
              </div>
              {editingId ? (
                <button
                  className="btn btn-ghost"
                  type="button"
                  onClick={cancelEdit}
                >
                  <X size={16} />
                  Batal
                </button>
              ) : null}
            </div>

            <Field label="Jenis">
              <select
                className="select"
                value={form.kind}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    kind: event.target.value as PackageKind
                  }))
                }
              >
                {kindOptions.map((option) => (
                  <option key={option}>{option}</option>
                ))}
              </select>
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

            <Field label="Slug">
              <input
                className="input"
                value={form.slug}
                onChange={(event) =>
                  setForm((current) => ({ ...current, slug: event.target.value }))
                }
                required
              />
            </Field>

            <div className="two-columns">
              <Field label="Level">
                <input
                  className="input"
                  value={form.level}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      level: event.target.value
                    }))
                  }
                  placeholder="N5 / A1 / SSW"
                />
              </Field>
              <Field label="Kategori">
                <input
                  className="input"
                  value={form.category}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      category: event.target.value
                    }))
                  }
                  placeholder="JLPT / JFT Basic / Kaigo"
                />
              </Field>
            </div>

            <div className="two-columns">
              <Field label="Harga">
                <input
                  className="input"
                  type="number"
                  min="0"
                  value={form.price}
                  onChange={(event) =>
                    setForm((current) => ({ ...current, price: event.target.value }))
                  }
                  required
                />
              </Field>
              <Field label="Urutan">
                <input
                  className="input"
                  type="number"
                  value={form.sortOrder}
                  onChange={(event) =>
                    setForm((current) => ({
                      ...current,
                      sortOrder: event.target.value
                    }))
                  }
                />
              </Field>
            </div>

            <Field label="Status">
              <select
                className="select"
                value={form.status}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    status: event.target.value as "DRAFT" | "PUBLISHED"
                  }))
                }
              >
                <option>DRAFT</option>
                <option>PUBLISHED</option>
              </select>
            </Field>

            <Field label="Subtitle">
              <input
                className="input"
                value={form.subtitle}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    subtitle: event.target.value
                  }))
                }
              />
            </Field>

            <Field label="Preview">
              <textarea
                className="textarea"
                value={form.previewDescription}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    previewDescription: event.target.value
                  }))
                }
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

            <Field label="Benefit">
              <textarea
                className="textarea"
                value={form.benefits}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    benefits: event.target.value
                  }))
                }
                placeholder="Satu benefit per baris"
              />
            </Field>

            <Field label="Konten Paket">
              <textarea
                className="textarea"
                value={form.contents}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    contents: event.target.value
                  }))
                }
                placeholder={`${contentTypeOptions.join(" / ")}\nQUESTION_SET | seed-jlpt-n5 | Bank Soal N5 | 1`}
              />
            </Field>

            <Field label="Metadata JSON">
              <textarea
                className="textarea"
                value={form.metadata}
                onChange={(event) =>
                  setForm((current) => ({
                    ...current,
                    metadata: event.target.value
                  }))
                }
                placeholder='{"access":"paid"}'
              />
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

function StatusPill({ status }: { status: ProductPackage["status"] }) {
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

function payloadFromForm(form: PackageForm) {
  return {
    kind: form.kind,
    title: form.title.trim(),
    slug: form.slug.trim(),
    subtitle: nullable(form.subtitle),
    previewDescription: nullable(form.previewDescription),
    description: nullable(form.description),
    level: nullable(form.level),
    category: nullable(form.category),
    price: Number(form.price),
    currency: form.currency.trim().toUpperCase() || "IDR",
    benefits: lines(form.benefits),
    metadata: jsonOrUndefined(form.metadata),
    status: form.status,
    sortOrder: Number(form.sortOrder || 0),
    contents: parseContents(form.contents)
  };
}

function formFromItem(item: ProductPackage): PackageForm {
  return {
    kind: item.kind,
    title: item.title,
    slug: item.slug,
    subtitle: item.subtitle ?? "",
    previewDescription: item.previewDescription ?? "",
    description: item.description ?? "",
    level: item.level ?? "",
    category: item.category ?? "",
    price: String(item.price),
    currency: item.currency ?? "IDR",
    benefits: Array.isArray(item.benefits)
      ? item.benefits.map(String).join("\n")
      : item.benefits
        ? JSON.stringify(item.benefits, null, 2)
        : "",
    metadata: item.metadata ? JSON.stringify(item.metadata, null, 2) : "",
    status: item.status,
    sortOrder: String(item.sortOrder ?? 0),
    contents:
      item.contents
        ?.map((content) =>
          [
            content.contentType,
            content.contentId,
            content.title ?? "",
            content.sortOrder
          ].join(" | ")
        )
        .join("\n") ?? ""
  };
}

function parseContents(value: string) {
  return value
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line, index) => {
      const [contentType, contentId, title, sortOrder] = line
        .split("|")
        .map((part) => part.trim());

      if (!contentTypeOptions.includes(contentType as ContentType)) {
        throw new Error(`Content type tidak valid di baris ${index + 1}.`);
      }

      if (!contentId) {
        throw new Error(`Content ID wajib di baris ${index + 1}.`);
      }

      return {
        contentType,
        contentId,
        title: nullable(title),
        sortOrder: sortOrder ? Number(sortOrder) : index + 1
      };
    });
}

function lines(value: string) {
  const rows = value
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

  return rows.length ? rows : undefined;
}

function jsonOrUndefined(value: string) {
  const text = value.trim();
  if (!text) {
    return undefined;
  }

  return JSON.parse(text) as unknown;
}

function nullable(value?: string) {
  const text = value?.trim();
  return text ? text : null;
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
