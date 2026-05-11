"use client";

import * as React from "react";
import { VisitRequest, VisitStatus } from "@/types/dashboard-types";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import { api } from "@/lib/api";

interface Props {
  request: VisitRequest;
  onBack: () => void;
}

export const VisitRequestDetails: React.FC<Props> = ({ request, onBack }) => {
  const [status, setStatus] = React.useState<VisitStatus | "">(request.status);
  const [saving, setSaving] = React.useState(false);

  const handleSave = async () => {
    if (!status) return;
    setSaving(true);
    try {
      await api.put(`/admin/visit-requests/${request.id}/status`, null, { params: { status } });
    } finally {
      setSaving(false);
    }
  };

  const getStatusColor = (status: VisitStatus) => {
    switch (status) {
      case VisitStatus.PENDING:
        return "bg-yellow-500/20 text-yellow-500";
      case VisitStatus.CONFIRMED:
        return "bg-green-500/20 text-green-500";
        case VisitStatus.COMPLETED:
            return "bg-blue-500/20 text-blue-500";
      case VisitStatus.CANCELLED:
        return "bg-red-500/20 text-red-500";
    }
  };

  return (
    <div className="px-6 max-w-3xl space-y-6">
      <Button variant="ghost" className="flex items-center gap-2" onClick={onBack}>
        <ArrowLeft /> Back
      </Button>

      <h2 className="text-xl font-semibold">Visit Request Details</h2>

      <Card className="border rounded-xl p-6 space-y-4 bg-card shadow-sm">
        <CardHeader>
          <CardTitle>{request.propertyTitle}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <p>
            <strong>Client:</strong> <br />Name: {request.userName} <br />Email: {request.userEmail}
          </p>
          <p>
            <strong>Requested Date:</strong> {new Date(request.requestedDate).toLocaleString()}
          </p>
          <div className="flex gap-3 items-center">
            <Select value={status} onValueChange={(val) => setStatus(val as VisitStatus)}>
              <SelectTrigger className="w-[200px]">
                <SelectValue placeholder="Select status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={VisitStatus.PENDING}>PENDING</SelectItem>
                <SelectItem value={VisitStatus.CONFIRMED}>APPROVED</SelectItem>
                <SelectItem value={VisitStatus.COMPLETED}>COMPLETED</SelectItem>
                <SelectItem value={VisitStatus.CANCELLED}>REJECTED</SelectItem>
              </SelectContent>
            </Select>
            <Button onClick={handleSave} disabled={saving || status === request.status}>
              {saving ? "Saving..." : "Save"}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
