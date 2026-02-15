"use client"

import { useAuditLogs } from "@/hooks/useAuditLogs"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow } from "@/components/ui/table"

export default function AuditLogs() {
  const { logs, loading, error } = useAuditLogs()

  if (loading) {
    return <div className="p-6">Loading audit logs…</div>
  }

  if (error) {
    return <div className="p-6 text-destructive">{error}</div>
  }

  if (!logs.length) {
    return <div className="p-6">No audit logs yet.</div>
  }

  return (
    <div className="p-6">
      <h2 className="text-lg font-semibold mb-4">Audit Log</h2>
      <p className="text-muted-foreground text-sm mb-4">
        All admin actions (e.g. report status changes) are recorded here.
      </p>
      <div className="rounded-lg border overflow-auto">
        <Table>
          <TableHeader>
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
                  {log.createdAt ? new Date(log.createdAt).toLocaleString() : "—"}
                </TableCell>
                <TableCell>
                  {log.adminName ?? log.adminEmail ?? log.adminId ?? "—"}
                </TableCell>
                <TableCell>{log.action}</TableCell>
                <TableCell className="max-w-md truncate font-mono text-xs">
                  {log.details ?? "—"}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
