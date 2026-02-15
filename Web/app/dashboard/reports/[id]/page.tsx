"use client";

import { useParams } from "next/navigation";
import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Report, ReportStatus } from "@/types/dashboard-types";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

import { Button } from "@/components/ui/button";

const ReportDetail = () => {
  const { id } = useParams();
  const [report, setReport] = useState<Report | null>(null);
  const [status, setStatus] = useState<ReportStatus | "">("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const fetchReport = async () => {
      const { data } = await api.get<Report>(`/admin/reports/${id}`);
      setReport(data);
      setStatus(data.status);
    };

    fetchReport();
  }, [id]);

  const handleSave = async () => {
    if (!status || !report) return;

    try {
      setSaving(true);

      await api.put(`/admin/reports/${id}/status`, null, {
        params: { status },
      });

      setReport({ ...report, status });
    } finally {
      setSaving(false);
    }
  };

  if (!report) return <div className="p-6">Loading...</div>;

  return (
    <div className="p-6 max-w-3xl space-y-6">
      <h2 className="text-xl font-semibold">Report N°: {report.id}</h2>

      <div className="border rounded-xl p-6 space-y-4 bg-card shadow-sm">
        <div>
          <h4 className="text-sm text-muted-foreground">Reason</h4>
          <p className="font-medium">{report.reason}</p>
        </div>
        <div>
          <h4>
            {new Date(report.createdAt).toLocaleString()}
          </h4>
        </div>
        <div>
          <h4 className="text-sm text-muted-foreground">Reporter</h4>
          <p>
            Name:{report.reporterName} <br />
            Email: {report.reporterEmail}
          </p>
        </div>

        {report.reportedUserEmail && (
          <div>
            <h4 className="text-sm text-muted-foreground">Reported User</h4>
            <p>
              Name:{report.reportedUserName} <br />
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

        <div className="pt-4 space-y-3">
          <h4 className="text-sm text-muted-foreground">Change Status</h4>

          <div className="flex gap-3 items-center">
            <Select
              value={status}
              onValueChange={(value) => setStatus(value as ReportStatus)}
            >
              <SelectTrigger className="w-[200px]">
                <SelectValue placeholder="Select status" />
              </SelectTrigger>

              <SelectContent>
                <SelectItem value={ReportStatus.OPEN}>OPEN</SelectItem>
                <SelectItem value={ReportStatus.REVIEWED}>REVIEWED</SelectItem>
                <SelectItem value={ReportStatus.RESOLVED}>RESOLVED</SelectItem>
                <SelectItem value={ReportStatus.DISMISSED}>
                  DISMISSED
                </SelectItem>
              </SelectContent>
            </Select>

            <Button
              onClick={handleSave}
              disabled={saving || status === report.status}
            >
              {saving ? "Saving..." : "Save"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReportDetail;
