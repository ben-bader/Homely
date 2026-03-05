"use client";

import * as React from "react";
import { useVisitRequests } from "@/hooks/useVisitRequests"; // custom hook to fetch visit requests
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { VisitStatus, type VisitRequest } from "@/types/dashboard-types";
import { VisitRequestDetails } from "./details/VisistRequestDetails"; // inline detail component

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

export default function VisitRequests() {
  const { visitRequests, loading, error } = useVisitRequests();
  const [search, setSearch] = React.useState("");
  const [selectedRequest, setSelectedRequest] = React.useState<VisitRequest | null>(null);

  // Stats
  const pendingCount = visitRequests.filter((r) => r.status === VisitStatus.PENDING).length;
  const approvedCount = visitRequests.filter((r) => r.status === VisitStatus.CONFIRMED).length;
  const completedCount = visitRequests.filter((r) => r.status === VisitStatus.CONFIRMED).length;
  const rejectedCount = visitRequests.filter((r) => r.status === VisitStatus.CANCELLED).length;
  const totalCount = visitRequests.length;

  // Filtered list
  const filteredRequests = React.useMemo(
    () =>
      visitRequests.filter((r) =>
        [r.userName, r.propertyTitle, r.status]
          .filter(Boolean)
          .join(" ")
          .toLowerCase()
          .includes(search.toLowerCase())
      ),
    [visitRequests, search]
  );

  if (loading) return <div className="p-6">Loading visit requests…</div>;
  if (error) return <div className="p-6 text-destructive">{error}</div>;
  if (!visitRequests.length) return <div className="p-6">No visit requests found.</div>;

  // If a request is selected, render details
  if (selectedRequest) {
    return (
      <VisitRequestDetails
        request={selectedRequest}
        onBack={() => setSelectedRequest(null)}
      />
    );
  }

  return (
    <div className="px-6">
      <h2 className="text-2xl font-semibold mb-6">Visit Requests</h2>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-5 mb-6">
        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Pending</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{pendingCount}</CardContent>
        </Card>
        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Completed</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{completedCount}</CardContent>
        </Card>

        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Approved</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{approvedCount}</CardContent>
        </Card>

        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Canceled</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{rejectedCount}</CardContent>
        </Card>

        <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
          <CardHeader>
            <CardTitle>Total</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{totalCount}</CardContent>
        </Card>
      </div>

      {/* Search */}
      <Input
        placeholder="Search visit requests…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-6 w-full"
      />

      {/* Request Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {filteredRequests.length ? (
          filteredRequests.map((req) => (
            <Card key={req.id} className="border hover:shadow-lg transition">
              <CardHeader className="flex justify-between items-start">
                <CardTitle className="text-lg">{req.propertyTitle}</CardTitle>
                <Badge variant="outline" className={`capitalize ${getStatusColor(req.status)}`}>
                  {req.status.toLowerCase()}
                </Badge>
              </CardHeader>
              <CardContent className="space-y-2">
                <p>
                  <strong>Client</strong><br />Name: {req.userName} <br />Email:{req.userEmail} 
                </p>
                <p>
                  <strong>Requested Date:</strong> {new Date(req.requestedDate).toLocaleString()}
                </p>
                <Button
                  variant="outline"
                  size="sm"
                  className="mt-2"
                  onClick={() => setSelectedRequest(req)}
                >
                  View Details →
                </Button>
              </CardContent>
            </Card>
          ))
        ) : (
          <p className="col-span-full text-center py-12 text-muted-foreground">No visit requests found.</p>
        )}
      </div>
    </div>
  );
}
