"use client"

import { api } from "@/lib/api"
import type { BoostPackage } from "@/types/dashboard-types"
import { useState, useEffect, useCallback } from "react"

const getBoostPackages = async (): Promise<BoostPackage[]> => {
  const { data } = await api.get<BoostPackage[]>("/boost/packages")
  return data
}

const useBoostPackages = () => {
  const [packages, setPackages] = useState<BoostPackage[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const refetch = useCallback(async () => {
    try {
      setLoading(true)
      const data = await getBoostPackages()
      setPackages(data)
      setError(null)
    } catch (err: any) {
      setError(err.message || "Failed to load boost packages")
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    refetch()
  }, [refetch])

  const addPackage = async (newPackage: Omit<BoostPackage, 'id'>) => {
    await api.post("/boost/packages", newPackage)
    await refetch()
  }

  const deletePackage = async (packageId: number) => {
    await api.delete(`/boost/packages/${packageId}`)
    await refetch()
  }

  return {
    packages,
    loading,
    error,
    refetch,
    addPackage,
    deletePackage,
  }
}

export default useBoostPackages;
