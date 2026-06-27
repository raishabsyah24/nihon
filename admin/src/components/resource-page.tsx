"use client";

import {
  AlertTriangle,
  Edit3,
  Eye,
  EyeOff,
  Plus,
  RefreshCw,
  Save,
  Search,
  Trash2,
  X,
} from "lucide-react";
import { FormEvent, useCallback, useEffect, useMemo, useState } from "react";
import { apiFetch, type JsonRecord } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { formatDateTime, stringifyCell, toDateTimeLocal } from "@/lib/format";
import type { ResourceConfig, ResourceField } from "@/lib/resources";

type FormState = Record<string, string>;

export function ResourcePage({ resource }: { resource: ResourceConfig }) {
  const { token } = useAuth();
  const [items, setItems] = useState<JsonRecord[]>([]);
  const [form, setForm] = useState<FormState>(() =>
    initialForm(resource.fields),
  );
  const [editingId, setEditingId] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [statusUpdatingId, setStatusUpdatingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const Icon = resource.icon;
  const hasStatusField = resource.fields.some(
    (field) => field.name === "status",
  );

  const loadItems = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const rows = await apiFetch<JsonRecord[]>(resource.endpoint, token);
      setItems(rows);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setItems([]);
    } finally {
      setLoading(false);
    }
  }, [resource.endpoint, token]);

  useEffect(() => {
    void loadItems();
  }, [loadItems]);

  const filteredItems = useMemo(() => {
    const needle = search.trim().toLowerCase();
    if (!needle) {
      return items;
    }

    return items.filter((item) =>
      JSON.stringify(item).toLowerCase().includes(needle),
    );
  }, [items, search]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSaving(true);
    setError(null);
    try {
      const payload = normalizePayload(resource.fields, form);
      await apiFetch(
        editingId ? `${resource.endpoint}/${editingId}` : resource.endpoint,
        token,
        {
          method: editingId ? "PATCH" : "POST",
          body: JSON.stringify(payload),
        },
      );
      setForm(initialForm(resource.fields));
      setEditingId(null);
      await loadItems();
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setSaving(false);
    }
  }

  async function removeItem(id: string) {
    setSaving(true);
    setError(null);
    try {
      await apiFetch(`${resource.endpoint}/${id}`, token, { method: "DELETE" });
      await loadItems();
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setSaving(false);
    }
  }

  async function toggleStatus(item: JsonRecord) {
    const id = String(item.id);
    const currentStatus = String(item.status ?? "DRAFT");
    const nextStatus = currentStatus === "PUBLISHED" ? "DRAFT" : "PUBLISHED";

    setStatusUpdatingId(id);
    setError(null);
    try {
      await apiFetch(`${resource.endpoint}/${id}`, token, {
        method: "PATCH",
        body: JSON.stringify({ status: nextStatus }),
      });
      setItems((current) =>
        current.map((row) =>
          String(row.id) === id ? { ...row, status: nextStatus } : row,
        ),
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setStatusUpdatingId(null);
    }
  }

  function editItem(item: JsonRecord) {
    setEditingId(String(item.id));
    setForm(formFromItem(resource.fields, item));
  }

  function cancelEdit() {
    setEditingId(null);
    setForm(initialForm(resource.fields));
  }

  return (
    <>
      <div className="page-heading">
        <div>
          <h1>{resource.title}</h1>
          <p className="muted">Kelola data {resource.title.toLowerCase()}.</p>
        </div>
        <button
          className="btn btn-ghost"
          onClick={loadItems}
          disabled={loading}
        >
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

      <div className="resource-layout">
        <section className="panel">
          <div className="toolbar">
            <div className="button-row">
              <Icon size={18} />
              <strong>{filteredItems.length} item</strong>
            </div>
            <label className="search">
              <span className="sr-only">Search</span>
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
                  placeholder="Cari"
                />
              </div>
            </label>
          </div>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  {resource.columns.map((column) => (
                    <th key={column}>{column}</th>
                  ))}
                  <th>Aksi</th>
                </tr>
              </thead>
              <tbody>
                {filteredItems.map((item) => (
                  <tr key={String(item.id)}>
                    {resource.columns.map((column) => (
                      <td key={column}>{renderCell(column, item[column])}</td>
                    ))}
                    <td>
                      <div className="button-row">
                        {hasStatusField ? (
                          <button
                            className="btn btn-ghost"
                            onClick={() => toggleStatus(item)}
                            disabled={
                              saving || statusUpdatingId === String(item.id)
                            }
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
                        ) : null}
                        <button
                          className="btn btn-ghost"
                          onClick={() => editItem(item)}
                          disabled={saving}
                          aria-label="Edit"
                        >
                          <Edit3 size={16} />
                        </button>
                        <button
                          className="btn btn-danger"
                          onClick={() => removeItem(String(item.id))}
                          disabled={saving}
                          aria-label="Hapus"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {filteredItems.length === 0 ? (
                  <tr>
                    <td colSpan={resource.columns.length + 1} className="muted">
                      Data kosong.
                    </td>
                  </tr>
                ) : null}
              </tbody>
            </table>
          </div>
        </section>

        <section className="panel">
          <div className="toolbar">
            <div className="button-row">
              {editingId ? <Edit3 size={18} /> : <Plus size={18} />}
              <strong>{editingId ? "Edit" : "Tambah"}</strong>
            </div>
            {editingId ? (
              <button
                className="btn btn-ghost"
                onClick={cancelEdit}
                type="button"
              >
                <X size={16} />
              </button>
            ) : null}
          </div>
          <form className="form-grid" onSubmit={submit}>
            {resource.fields.map((field) => (
              <FieldInput
                field={field}
                key={field.name}
                value={form[field.name] ?? ""}
                onChange={(value) =>
                  setForm((current) => ({ ...current, [field.name]: value }))
                }
              />
            ))}
            <button className="btn btn-primary" disabled={saving} type="submit">
              <Save size={18} />
              Simpan
            </button>
          </form>
        </section>
      </div>
    </>
  );
}

function FieldInput({
  field,
  value,
  onChange,
}: {
  field: ResourceField;
  value: string;
  onChange: (value: string) => void;
}) {
  const id = `field-${field.name}`;

  return (
    <div className="field">
      <label htmlFor={id}>{field.label}</label>
      {field.kind === "textarea" || field.kind === "lines" ? (
        <textarea
          className="textarea"
          id={id}
          required={field.required}
          value={value}
          onChange={(event) => onChange(event.target.value)}
        />
      ) : field.kind === "sections" ||
        field.kind === "vocabulary" ||
        field.kind === "examples" ? (
        <textarea
          className="textarea"
          id={id}
          required={field.required}
          value={value}
          onChange={(event) => onChange(event.target.value)}
        />
      ) : field.kind === "select" ? (
        <select
          className="select"
          id={id}
          required={field.required}
          value={value}
          onChange={(event) => onChange(event.target.value)}
        >
          <option value="">Pilih</option>
          {field.options?.map((option) => (
            <option key={option} value={option}>
              {option}
            </option>
          ))}
        </select>
      ) : (
        <input
          className="input"
          id={id}
          required={field.required}
          type={
            field.kind === "number"
              ? "number"
              : field.kind === "datetime"
                ? "datetime-local"
                : "text"
          }
          value={value}
          onChange={(event) => onChange(event.target.value)}
        />
      )}
      {field.help ? <span className="muted">{field.help}</span> : null}
    </div>
  );
}

function initialForm(fields: ResourceField[]) {
  return Object.fromEntries(
    fields.map((field) => [field.name, field.name === "status" ? "DRAFT" : ""]),
  );
}

function formFromItem(fields: ResourceField[], item: JsonRecord) {
  return Object.fromEntries(
    fields.map((field) => {
      const value = item[field.name];
      if (field.kind === "lines" && Array.isArray(value)) {
        return [field.name, value.join("\n")];
      }
      if (field.kind === "sections" && Array.isArray(value)) {
        return [field.name, value.map(formatSectionLine).join("\n")];
      }
      if (field.kind === "vocabulary" && Array.isArray(value)) {
        return [field.name, value.map(formatVocabularyLine).join("\n")];
      }
      if (field.kind === "examples" && Array.isArray(value)) {
        return [field.name, value.map(formatExampleLine).join("\n")];
      }
      if (field.kind === "datetime") {
        return [field.name, toDateTimeLocal(value)];
      }
      return [field.name, value == null ? "" : String(value)];
    }),
  );
}

function normalizePayload(fields: ResourceField[], form: FormState) {
  return Object.fromEntries(
    fields
      .map((field) => {
        const raw = form[field.name]?.trim() ?? "";
        if (field.kind === "vocabulary") {
          return [field.name, raw ? parseVocabulary(raw) : []];
        }
        if (field.kind === "sections") {
          return [field.name, raw ? parseSections(raw) : []];
        }
        if (field.kind === "examples") {
          return [field.name, raw ? parseExamples(raw) : []];
        }
        if (!raw && !field.required) {
          return [field.name, null];
        }
        if (field.kind === "number") {
          return [field.name, Number(raw)];
        }
        if (field.kind === "lines") {
          return [
            field.name,
            raw
              .split("\n")
              .map((line) => line.trim())
              .filter(Boolean),
          ];
        }
        if (field.kind === "datetime") {
          return [field.name, raw ? new Date(raw).toISOString() : null];
        }
        return [field.name, raw];
      })
      .filter(([, value]) => value !== null),
  );
}

function renderCell(column: string, value: unknown) {
  if (column === "status") {
    const status = String(value ?? "DRAFT");
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

  if (column.endsWith("At")) {
    return formatDateTime(value);
  }

  if (column === "vocabulary" && Array.isArray(value)) {
    return `${value.length} kosakata`;
  }

  if (column === "sections" && Array.isArray(value)) {
    return `${value.length} section`;
  }

  if (column === "examples" && Array.isArray(value)) {
    return `${value.length} contoh`;
  }

  return stringifyCell(value);
}

function formatSectionLine(value: unknown) {
  if (!isRecord(value)) {
    return stringifyCell(value);
  }

  return [value.title, value.body]
    .map((item) => (item == null ? "" : String(item)))
    .join(" | ");
}

function formatVocabularyLine(value: unknown) {
  if (!isRecord(value)) {
    return stringifyCell(value);
  }

  return [value.kanji, value.kana, value.furigana, value.romaji, value.meaning]
    .map((item) => (item == null ? "" : String(item)))
    .join(" | ");
}

function formatExampleLine(value: unknown) {
  if (!isRecord(value)) {
    return stringifyCell(value);
  }

  return [value.japanese, value.furigana, value.romaji, value.meaning]
    .map((item) => (item == null ? "" : String(item)))
    .join(" | ");
}

function parseSections(raw: string) {
  return raw
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [title, body] = line.split("|").map((item) => item.trim());
      return {
        title: title || null,
        body: body || null,
      };
    });
}

function parseVocabulary(raw: string) {
  return raw
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [kanji, kana, furigana, romaji, meaning] = line
        .split("|")
        .map((item) => item.trim());
      return {
        kanji: kanji || null,
        kana: kana || null,
        furigana: furigana || null,
        romaji: romaji || null,
        meaning: meaning || null,
      };
    });
}

function parseExamples(raw: string) {
  return raw
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [japanese, furigana, romaji, meaning] = line
        .split("|")
        .map((item) => item.trim());
      return {
        japanese: japanese || null,
        furigana: furigana || null,
        romaji: romaji || null,
        meaning: meaning || null,
      };
    });
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
