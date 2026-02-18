"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { getUserFromToken, isAdmin } from "@/lib/auth"

export default function AdminDashboardWrapper({
  children,
}: {
  children: React.ReactNode
}) {
  const router = useRouter()
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const user = getUserFromToken()

    if (!user || !isAdmin()) {
      router.replace("/")
      return
    }

    setLoading(false)
  }, [router])

  if (loading) return <p>Checking permissions...</p>

  return <>{children}</>
}
