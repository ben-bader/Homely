import React from "react"
import { useReports } from "@/hooks/useReports"
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui/card"

const Reports = () => {
  const { reports, loading, error } = useReports()

  if (loading) {
    return <div className="p-6">Loading reports...</div>
  }

  if (error) {
    return <div className="p-6 text-red-500">{error}</div>
  }

  if (!reports.length) {
    return <div className="p-6">No reports found.</div>
  }

  return (
    <div className="grid gap-6 p-6 md:grid-cols-2 lg:grid-cols-3">
      {reports.map((report: any) => (
        <Card key={report.id}>
          <CardHeader>
            <CardTitle>{report.reason}</CardTitle>
            <CardDescription>
              {report.createdAt
                ? new Date(report.createdAt).toLocaleString()
                : "No date"}
            </CardDescription>
          </CardHeader>

          <CardContent>
            
            <p className="text-sm">Report N°:{report.id}</p>
          </CardContent>

          <CardFooter>
            <span className="text-xs text-muted-foreground">
              Status: {report.status}
            </span>
          </CardFooter>
        </Card>
      ))}
    </div>
  )
}

export default Reports
