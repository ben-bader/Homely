"use client"
import { api } from "@/lib/api"
import { useState, useEffect } from "react"

const getReports = async (): Promise<Report[]> => {
  const { data } = await api.get<Report[]>("/admin/reports")
  return data
}

const useReports = () => {
  const [reports, setReports] = useState<Report[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchReports = async () => {
      try {
        setLoading(true)
        const data = await getReports()
        setReports(data)
      } catch (err: any) {
        setError(err.message || "Failed to load reports")
      } finally {
        setLoading(false)
      }
    }

    fetchReports()
  }, [])

  return {
    reports,
    loading,
    error,
    setReports,
    setLoading,
    setError
  }
}

export { useReports }
