"use client"

import { api } from "@/lib/api"
import type { AuditLog } from "@/types/dashboard-types"
import { useState, useEffect, useCallback } from "react"

const getAuditLogs = async (): Promise<AuditLog[]> => {
  const { data } = await api.get<AuditLog[]>("/admin/audit-logs")
  return data
}

export function useAuditLogs() {
  const [logs, setLogs] = useState<AuditLog[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const refetch = useCallback(async () => {
    try {
      setLoading(true)
      const data = await getAuditLogs()
      setLogs(data)
      setError(null)
    } catch (err: any) {
      setError(err.message || "Failed to load audit logs")
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    refetch()
  }, [refetch])

  return { logs, loading, error, refetch }
}
