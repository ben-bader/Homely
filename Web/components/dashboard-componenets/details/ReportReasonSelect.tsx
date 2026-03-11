import React from "react";
import { useReportReasons } from "../../hooks/useReportReasons";

export function ReportReasonSelect({ currentReason }: { currentReason: string }) {
  const { reasons, loading, error } = useReportReasons();

  if (loading) return <p>Loading reasons…</p>;
  if (error) return <p className="text-red-500">{error}</p>;

  return (
    <select defaultValue={currentReason} className="border rounded px-2 py-1">
      {reasons.map((reason) => (
        <option key={reason} value={reason}>{reason}</option>
      ))}
      {!reasons.includes(currentReason) && (
        <option value={currentReason}>{currentReason}</option>
      )}
    </select>
  );
}
