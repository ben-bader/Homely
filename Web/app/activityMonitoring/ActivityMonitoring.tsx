"use client";

import React, { useState, useMemo } from "react";
import { useAuditLogs } from "@/app/activityMonitoring/useAuditLogs";
import { useLogActivities } from "@/app/activityMonitoring/useAuditLogs";

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
  DrawerFooter,
} from "@/components/ui/drawer";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { FaEye } from "react-icons/fa";
import { Badge } from "@/components/ui/badge";

type DateSort = "" | "newest" | "oldest";
type Tab = "admin" | "users";

/* ---------------- HELPERS ---------------- */

function fmtFull(v: any) {
  if (!v) return "—";
  const d = new Date(v);
  return isNaN(d.getTime()) ? "—" : d.toLocaleString();
}

/* ---------------- INFO ROW FOR DRAWER ---------------- */

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[10px] uppercase tracking-widest text-muted-foreground font-bold">{label}</span>
      <div className="text-sm font-medium text-foreground">{value ?? "—"}</div>
    </div>
  );
}

/* ---------------- LOG DETAILS DRAWER ---------------- */

function LogDetailsDrawer({ log, type }: { log: any; type: Tab }) {
  const isUserActivity = type === "users";
  
  const formattedChanges = useMemo(() => {
    const data = isUserActivity ? log.changes : log.details;
    if (!data) return null;
    try {
      const parsed = typeof data === "string" ? JSON.parse(data) : data;
      return JSON.stringify(parsed, null, 2);
    } catch {
      return String(data);
    }
  }, [log, isUserActivity]);

  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon" className="h-8 w-8">
          <FaEye className="h-4 w-4 text-muted-foreground hover:text-primary" />
        </Button>
      </DrawerTrigger>
      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b">
          <DrawerTitle>{isUserActivity ? "Activity Details" : "Audit Log Details"}</DrawerTitle>
          <DrawerDescription>Full information regarding this recorded action.</DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">Core Info</p>
            <InfoRow label="Timestamp" value={fmtFull(log.createdAt)} />
            <InfoRow label="Activity Type" value={<Badge variant="outline">{isUserActivity ? log.activityType : log.action}</Badge>} />
            {isUserActivity && <InfoRow label="Entity" value={`${log.entityType} (${log.entityId})`} />}
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">User / Actor</p>
            <InfoRow label="Name" value={isUserActivity ? log.userName : log.adminName} />
            <InfoRow label="Email" value={isUserActivity ? log.userEmail : log.adminEmail} />
            <InfoRow label="ID" value={isUserActivity ? log.userId : log.adminId} />
          </section>

          {log.description && (
            <section className="space-y-4">
               <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">Description</p>
               <p className="text-sm text-muted-foreground italic">"{log.description}"</p>
            </section>
          )}

          {formattedChanges && (
            <section className="space-y-4">
              <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">Data Changes / Details</p>
              <pre className="bg-muted p-3 rounded text-[11px] font-mono overflow-x-auto whitespace-pre-wrap">
                {formattedChanges}
              </pre>
            </section>
          )}
        </div>

        <DrawerFooter className="border-t">
          <DrawerClose asChild>
            <Button variant="outline" className="w-full">Close</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- MAIN PAGE ---------------- */

export default function ActivityMonitoring() {
  const { logs, loading: auditLoading, error: auditError } = useAuditLogs();
  const { activities, loading: activityLoading, error: activityError } = useLogActivities();

  const [activeTab, setActiveTab] = useState<Tab>("users");
  const [search, setSearch] = useState("");
  const [actionFilter, setActionFilter] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("newest");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => {
    setActionFilter("");
    setDateSort("newest");
    setCreatedAfter("");
    setCreatedBefore("");
  };

  /* ---- LOG ACTIVITIES (USERS) ---- */
  const filteredActivities = useMemo(() => {
    let filtered = activities.filter((act) => {
      const textMatch = [act.activityType, act.entityType, act.description, act.userName, act.userEmail]
        .filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const typeMatch = !actionFilter || act.activityType?.toLowerCase() === actionFilter.toLowerCase();
      const ts = act.createdAt ? new Date(act.createdAt).getTime() : 0;
      const afterMatch = !createdAfter || ts >= new Date(createdAfter).getTime();
      const beforeMatch = !createdBefore || ts <= new Date(createdBefore).getTime();
      return textMatch && typeMatch && afterMatch && beforeMatch;
    });
    return dateSort === "newest" 
      ? filtered.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
      : filtered.sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
  }, [activities, search, actionFilter, dateSort, createdAfter, createdBefore]);

  /* ---- AUDIT LOGS (ADMIN) ---- */
  const filteredAuditLogs = useMemo(() => {
    let filtered = logs.filter((log) => {
      const textMatch = [log.action, log.adminName, log.adminEmail].filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      return textMatch;
    });
    return filtered;
  }, [logs, search]);

  const isLoading = activeTab === "admin" ? auditLoading : activityLoading;
  const currentData = activeTab === "admin" ? filteredAuditLogs : filteredActivities;

  return (
    <div className="p-6 space-y-6">
      <div>
        <h2 className="text-xl font-bold">Activity Monitoring</h2>
        <p className="text-muted-foreground text-sm">Review system-wide actions and user activities.</p>
      </div>

      <div className="flex gap-1 border-b">
        {(["users", "admin"] as Tab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors -mb-px ${
              activeTab === tab ? "border-primary text-primary" : "border-transparent text-muted-foreground hover:text-foreground"
            }`}
          >
            {tab === "users" ? "Users Activities" : "Admin Logs"}
          </button>
        ))}
      </div>

      <div className="flex gap-2">
        <Input 
          placeholder={`Search ${activeTab === "users" ? "by user, type or entity..." : "by action or admin..."}`} 
          value={search} 
          onChange={(e) => setSearch(e.target.value)} 
        />
      </div>

      <div className="rounded-lg border overflow-hidden">
        <Table>
          <TableHeader className="bg-primary hover:bg-primary">
            <TableRow>
              <TableHead className="text-white w-[180px]">Time</TableHead>
              <TableHead className="text-white">User</TableHead>
              <TableHead className="text-white">{activeTab === "users" ? "Activity Type" : "Action"}</TableHead>
              {activeTab === "users" && <TableHead className="text-white">Entity</TableHead>}
              <TableHead className="text-white text-right">Show More</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              <TableRow><TableCell colSpan={6} className="text-center py-10">Loading activities...</TableCell></TableRow>
            ) : currentData.length === 0 ? (
              <TableRow><TableCell colSpan={6} className="text-center py-10 text-muted-foreground">No records found.</TableCell></TableRow>
            ) : (
              currentData.map((item: any) => (
                <TableRow key={item.id}>
                  <TableCell className="text-xs font-medium">
                    {fmtFull(item.createdAt)}
                  </TableCell>
                  <TableCell>
                    <div className="flex flex-col">
                      <span className="text-sm font-semibold">{activeTab === "users" ? item.userName : item.adminName}</span>
                      <span className="text-[11px] text-muted-foreground">{activeTab === "users" ? item.userEmail : item.adminEmail}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="secondary" className="text-[10px] uppercase tracking-tighter">
                      {activeTab === "users" ? item.activityType : item.action}
                    </Badge>
                  </TableCell>
                  {activeTab === "users" && (
                    <TableCell>
                      <span className="text-xs font-medium px-1.5 py-0.5 rounded bg-muted border">{item.entityType}</span>
                    </TableCell>
                  )}
                  <TableCell className="text-right">
                    <LogDetailsDrawer log={item} type={activeTab} />
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}