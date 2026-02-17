"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Report, ReportStatus } from "@/types/dashboard-types";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";

const getStatusColor = (status: ReportStatus) => {
  switch (status) {
    case ReportStatus.OPEN:
      return "bg-yellow-500/20 text-yellow-500";
    case ReportStatus.REVIEWED:
      return "bg-blue-500/20 text-blue-500";
    case ReportStatus.RESOLVED:
      return "bg-green-500/20 text-green-500";
    case ReportStatus.DISMISSED:
      return "bg-red-500/20 text-red-500";
  }
};

export default function ReportDetail({
  reportId,
  onBack,
}: {
  reportId: string;
  onBack: () => void;
}) {
  const [report, setReport] = useState<Report | null>(null);
  const [status, setStatus] = useState<ReportStatus | "">("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const fetchReport = async () => {
      const { data } = await api.get<Report>(`/admin/reports/${reportId}`);
      setReport(data);
      setStatus(data.status);
    };
    fetchReport();
  }, [reportId]);

  const handleSave = async () => {
    if (!status || !report) return;

    try {
      setSaving(true);
      await api.put(`/admin/reports/${reportId}/status`, null, { params: { status } });
      setReport({ ...report, status });
    } finally {
      setSaving(false);
    }
  };

  if (!report) return <div className="p-6">Loading...</div>;

  return (
    <div className="p-6 space-y-6">
      {/* Back Button */}
      <Button variant="ghost" className="flex items-center gap-2" onClick={onBack}>
        <ArrowLeft />
        Back
      </Button>

      {/* Report Card */}
      <Card className="border shadow-sm">
        <CardHeader className="flex justify-between items-center">
          <CardTitle className="text-lg">Report N°: {report.id}</CardTitle>
          <Badge className={`capitalize ${getStatusColor(report.status)}`} variant="outline">
            {report.status.toLowerCase()}
          </Badge>
        </CardHeader>

        <CardContent className="space-y-4">
          <div>
            <h4 className="text-sm text-muted-foreground">Reason</h4>
            <p className="font-medium">{report.reason}</p>
          </div>

          <div>
            <h4 className="text-sm text-muted-foreground">Created At</h4>
            <p>{new Date(report.createdAt || "").toLocaleString()}</p>
          </div>

          <div>
            <h4 className="text-sm text-muted-foreground">Reporter</h4>
            <p>
              Name: {report.reporterName} <br />
              Email: {report.reporterEmail}
            </p>
          </div>

          {report.reportedUserEmail && (
            <div>
              <h4 className="text-sm text-muted-foreground">Reported User</h4>
              <p>
                Name: {report.reportedUserName} <br />
                Email: {report.reportedUserEmail}
              </p>
            </div>
          )}

          {report.reportedPropertyTitle && (
            <div>
              <h4 className="text-sm text-muted-foreground">Reported Property</h4>
              <p>{report.reportedPropertyTitle}</p>
            </div>
          )}

          {/* Change Status */}
          <div className="pt-4 space-y-3">
            <h4 className="text-sm text-muted-foreground">Change Status</h4>
            <div className="flex gap-3 items-center">
              <Select value={status} onValueChange={(value) => setStatus(value as ReportStatus)}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="Select status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value={ReportStatus.OPEN}>OPEN</SelectItem>
                  <SelectItem value={ReportStatus.REVIEWED}>REVIEWED</SelectItem>
                  <SelectItem value={ReportStatus.RESOLVED}>RESOLVED</SelectItem>
                  <SelectItem value={ReportStatus.DISMISSED}>DISMISSED</SelectItem>
                </SelectContent>
              </Select>

              <Button onClick={handleSave} disabled={saving || status === report.status}>
                {saving ? "Saving..." : "Save"}
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
