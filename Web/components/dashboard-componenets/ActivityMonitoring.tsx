"use client";

import React, { useState } from "react";
import { useAuditLogs } from "@/hooks/useAuditLogs";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerTrigger,
  DrawerClose,
} from "@/components/ui/drawer";

import { Button } from "@/components/ui/button";

export default function ActivityMonitoring() {
  const { logs, loading, error } = useAuditLogs();
  const [selectedDetails, setSelectedDetails] = useState<any>(null);

  if (loading) {
    return <div className="p-6">Loading audit logs…</div>;
  }

  if (error) {
    return <div className="p-6 text-destructive">{error}</div>;
  }

  if (!logs.length) {
    return <div className="p-6">No audit logs yet.</div>;
  }

  return (
    <div className="p-6">
      <h2 className="text-lg font-semibold mb-4">Activity Monitoring</h2>
      <p className="text-muted-foreground text-sm mb-4">
        All actions (e.g. report status changes) are recorded here.
      </p>

      <div className="rounded-lg border overflow-auto">
        <Table>
          <TableHeader className="bg-blue-900 text-white">
            <TableRow>
              <TableHead>Time</TableHead>
              <TableHead>Admin</TableHead>
              <TableHead>Action</TableHead>
              <TableHead>Details</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {logs.map((log) => (
              <TableRow key={log.id}>
                <TableCell className="whitespace-nowrap">
                  {log.createdAt
                    ? new Date(log.createdAt).toLocaleString()
                    : "—"}
                </TableCell>

                <TableCell>
                  {log.adminName ?? log.adminEmail ?? log.adminId ?? "—"}
                </TableCell>

                <TableCell>{log.action}</TableCell>

                <TableCell>
                  {log.details ? (
                    <Drawer direction="right">
                      <DrawerTrigger asChild>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setSelectedDetails(log.details)}
                        >
                          View Details
                        </Button>
                      </DrawerTrigger>

                      <DrawerContent>
                        <DrawerHeader>
                          <DrawerTitle>Audit Log Details</DrawerTitle>
                          <DrawerDescription>
                            Full JSON details for this audit event.
                          </DrawerDescription>
                        </DrawerHeader>

                        <div className="p-4">
                          <div className="bg-muted p-4 rounded-md text-xs overflow-auto max-h-[70vh]">
                            {(() => {
                              if (!selectedDetails) return "—";

                              try {
                                const parsed =
                                  typeof selectedDetails === "string"
                                    ? JSON.parse(selectedDetails)
                                    : selectedDetails;

                                return JSON.stringify(parsed, null, 2);
                              } catch {
                                return typeof selectedDetails === "string"
                                  ? selectedDetails
                                  : JSON.stringify(selectedDetails, null, 2);
                              }
                            })()}
                          </div>
                        </div>

                        <div className="p-4 pt-0">
                          <DrawerClose asChild>
                            <Button variant="outline">Close</Button>
                          </DrawerClose>
                        </div>
                      </DrawerContent>
                    </Drawer>
                  ) : (
                    "—"
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
