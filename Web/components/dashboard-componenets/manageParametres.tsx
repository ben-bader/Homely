import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import useReportReasons  from "@/hooks/useReportReasons";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { ReportReason } from "@/types/dashboard-types";
import { Card } from "../ui/card";



const ManageParameters = () => {
  const { reasons, loading, error, refetch } = useReportReasons();
  const [newReason, setNewReason] = useState("");

  const addReportReason = async () => {
    if (!newReason.trim()) return;
    try {
      await api.post<ReportReason>("/report-reasons", { reason: newReason });
      setNewReason("");
      refetch();
    } catch (error) {
      console.error("Failed to add report reason", error);
    }
  };

  const deleteReportReason = async (id: string) => {
    try {
      await api.delete(`/report-reasons/${id}`);
      refetch();
    } catch (error) {
      console.error("Failed to delete report reason", error);
    }
  };

  // ... rest of JSX, replace reportReasons with reasons
  if (loading) {
    return <div className="flex items-center justify-center">
      <h1>Loading report reasons</h1>
    </div>
  }
  if (error) {
    return <div className="flex items-center justify-center">
      <h1>Error loading report reasons : {error}</h1>
    </div>
  }
  return (
    <div className="p-6">
      <h2 className="mb-4">Manage Report Reasons</h2>
      <div className="w-full flex flex-1 gap-4">
         <Input
        type="text"
        value={newReason}
        onChange={(e) => setNewReason(e.target.value)}
        placeholder="Add new reason"
      />
      <Button onClick={addReportReason}>Add Reason</Button>
      </div>
      <div className="flex flex-col w-[50%] my-4 gap-2 ">
        {reasons.map((reason) => (
          <li key={reason.id} className="flex gap-4 justify-between items-center rounded-md border border-muted p-2 shadow-xs">
            {reason.reason}
            <Button onClick={() => deleteReportReason(reason.id)}>Delete</Button>
          </li>
        ))}
      </div>
     
    </div>
  );
}

export default ManageParameters;