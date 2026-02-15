"use client"

import { useReports } from "@/hooks/useReports"
import { useRouter } from "next/navigation"
import { ReportStatus } from "@/types/dashboard-types"

const getStatusColor = (status: ReportStatus) => {
  switch (status) {
    case ReportStatus.OPEN:
      return "bg-yellow-500/20 text-yellow-600"
    case ReportStatus.REVIEWED:
      return "bg-blue-500/20 text-blue-600"
    case ReportStatus.RESOLVED:
      return "bg-green-500/20 text-green-600"
    case ReportStatus.DISMISSED:
      return "bg-red-500/20 text-red-600"
  }
}

const Reports = () => {
  const { reports, loading, error } = useReports()
  const router = useRouter()

  if (loading) return <div className="p-6">Loading reports…</div>
  if (error) return <div className="p-6 text-destructive">{error}</div>
  if (!reports.length) return <div className="p-6">No reports found.</div>

  return (
    <div className="p-6 space-y-6">
      <h2 className="text-lg font-semibold">Reports</h2>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        {reports.map((report) => (
          <div
            key={report.id}
            className="border rounded-xl p-5 shadow-sm hover:shadow-md transition bg-card"
          >
            <div className="flex justify-end items-center mb-3">
              <span
                className={`text-xs px-2 py-1 rounded-full ${getStatusColor(
                  report.status
                )}`}
                  >
                {report.status}
              </span>
            </div>

            <div className="space-y-2 text-sm text-muted-foreground">
                <p><strong>Reason:</strong> {report.reason}</p>
              <p><strong>Reporter:</strong> {report.reporterEmail}</p>
              {report.reportedUserEmail && (
                <p><strong>Reported User:</strong> {report.reportedUserEmail}</p>
              )}
              {report.reportedPropertyTitle && (
                <p><strong>Property:</strong> {report.reportedPropertyTitle}</p>
              )}
            </div>

            <button
              onClick={() => router.push(`/dashboard/reports/${report.id}`)}
              className="mt-4 text-sm font-medium text-primary hover:underline"
            >
              View Details →
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}

export default Reports
