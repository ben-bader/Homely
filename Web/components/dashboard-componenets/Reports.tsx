"use client";

import * as React from "react";
import { useReports } from "@/hooks/useReports";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ReportStatus, type Report } from "@/types/dashboard-types";
import { Button } from "@/components/ui/button";

import ReportDetails from "./details/ReportDetails"; // your existing ReportDetail component

const getStatusColor = (status: ReportStatus) => {
  switch (status) {
    case ReportStatus.OPEN:
      return "bg-yellow-500/20 text-yellow-500 border-yellow-500";
    case ReportStatus.REVIEWED:
      return "bg-blue-500/20 text-blue-500 border-blue-500";
    case ReportStatus.RESOLVED:
      return "bg-green-500/20 text-green-500 border-green-500";
    case ReportStatus.DISMISSED:
      return "bg-red-500/20 text-red-500 border-red-500";
  }
};

export default function ReportsPage() {
  const { reports, loading, error } = useReports();
  const [search, setSearch] = React.useState("");
  const [selectedReportId, setSelectedReportId] = React.useState<string | null>(null);

  // Stats
  const waitingReports = reports.filter((r) => r.status === ReportStatus.OPEN).length;
  const viewingReports = reports.filter((r) => r.status === ReportStatus.REVIEWED).length;
  const totalReports = reports.length;

  // Filtered reports
  const filteredReports = React.useMemo(
    () =>
      reports.filter((r) =>
        [
          r.reason,
          r.status,
          r.reporterEmail,
          r.reportedUserEmail,
          r.reportedPropertyTitle,
        ]
          .filter(Boolean)
          .join(" ")
          .toLowerCase()
          .includes(search.toLowerCase())
      ),
    [reports, search]
  );

  // If a report is selected, render ReportDetail instead
  if (selectedReportId) {
    return (
      <ReportDetails
        reportId={selectedReportId}
        onBack={() => setSelectedReportId(null)}
      />
    );
  }

  if (loading) return <div className="p-6">Loading reports…</div>;
  if (error) return <div className="p-6 text-destructive">{error}</div>;
  if (!reports.length) return <div className="p-6">No reports found.</div>;

  return (
    <div className="px-6">
      <h2 className="text-2xl font-semibold mb-6">Reports</h2>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-3 mb-6">
        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Waiting Reports</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{waitingReports}</CardContent>
        </Card>

        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Reports in Review</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{viewingReports}</CardContent>
        </Card>

        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>All Reports</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{totalReports}</CardContent>
        </Card>
      </div>

      {/* Search */}
      <Input
        placeholder="Search reports…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-6 w-full"
      />

      {/* Report Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {filteredReports.length ? (
          filteredReports.map((report: Report) => (
            <Card key={report.id} className="border hover:shadow-lg transition">
              <CardHeader className="flex justify-between items-start">
                <CardTitle className="text-lg">{report.reason}</CardTitle>
                <Badge
                  variant="outline"
                  className={`capitalize ${getStatusColor(report.status)}`}
                >
                  {report.status.toLowerCase()}
                </Badge>
              </CardHeader>
              <CardContent className="space-y-2">
                <p>
                  <strong>Reporter:</strong> {report.reporterName} <br />
                  {report.reporterEmail}
                </p>
                <p>
                  <strong>Reported User:</strong> {report.reportedUserName} <br />
                  {report.reportedUserEmail ?? "—"}
                </p>
                <p>
                  <strong>Property:</strong> {report.reportedPropertyTitle ?? "—"}
                </p>
                <Button
                  variant="outline"
                  size="sm"
                  className="mt-2"
                  onClick={() => setSelectedReportId(report.id)}
                >
                  View Details →
                </Button>
              </CardContent>
            </Card>
          ))
        ) : (
          <p className="col-span-full text-center py-12 text-muted-foreground">
            No reports found.
          </p>
        )}
      </div>
    </div>
  );
}
