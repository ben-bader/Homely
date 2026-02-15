"use client"

import { api } from "@/lib/api"
import type { Report } from "@/types/dashboard-types"
import { useState, useEffect, useCallback } from "react"

const getReports = async (): Promise<Report[]> => {
  const { data } = await api.get<Report[]>("/admin/reports")
  return data
}

const useReports = () => {
  const [reports, setReports] = useState<Report[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const refetch = useCallback(async () => {
    try {
      setLoading(true)
      const data = await getReports()
      setReports(data)
      setError(null)
    } catch (err: any) {
      setError(err.message || "Failed to load reports")
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    refetch()
  }, [refetch])

  const updateReportStatus = async (reportId: string, status: string) => {
    await api.put(`/admin/reports/${reportId}/status`, null, {
      params: { status },
    })
    await refetch()
  }

  return {
    reports,
    loading,
    error,
    setReports,
    setLoading,
    setError,
    refetch,
    updateReportStatus,
  }
}

export { useReports }
