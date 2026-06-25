"use client";

import { AlertTriangle, RefreshCw } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { apiFetch, type JsonRecord } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { dashboardResources } from "@/lib/resources";

type Metric = {
  key: string;
  label: string;
  count: number;
};

export function Dashboard() {
  const { token } = useAuth();
  const [metrics, setMetrics] = useState<Metric[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const loadMetrics = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const rows = await Promise.all(
        dashboardResources.map(async (resource) => {
          const items = await apiFetch<JsonRecord[]>(resource.endpoint, token);
          return {
            key: resource.key,
            label: resource.title,
            count: items.length
          };
        })
      );
      setMetrics(rows);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setMetrics(
        dashboardResources.map((resource) => ({
          key: resource.key,
          label: resource.title,
          count: 0
        }))
      );
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    void loadMetrics();
  }, [loadMetrics]);

  return (
    <>
      <div className="page-heading">
        <div>
          <h1>Dashboard</h1>
          <p className="muted">Ringkasan konten Nihon e Ikitai.</p>
        </div>
        <button className="btn btn-ghost" onClick={loadMetrics} disabled={loading}>
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

      <section className="metrics-grid">
        {metrics.map((metric) => (
          <article className="metric" key={metric.key}>
            <div className="metric-label">{metric.label}</div>
            <div className="metric-value">{metric.count}</div>
          </article>
        ))}
      </section>
    </>
  );
}
