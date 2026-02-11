"use client";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";

type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
};

type Property = {
  id: string;
  title: string;
  price: number;
  status: string;
};

type Report = {
  id: string;
  reason: string;
  status: string;
};

export default function DashboardPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [properties, setProperties] = useState<Property[]>([]);
  const [reports, setReports] = useState<Report[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const [usersRes, propertiesRes, reportsRes] = await Promise.all([
          fetch("/api/users").then(r => r.json()),
          fetch("/api/properties").then(r => r.json()),
          fetch("/api/admin/reports").then(r => r.json()),
        ]);
        setUsers(usersRes);
        setProperties(propertiesRes);
        setReports(reportsRes);
      } catch (err) {
        console.error("Failed to fetch dashboard data", err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  if (loading) return <p className="p-6">Loading dashboard...</p>;

  return (
    <div className="p-6 space-y-6" >
      {/* Summary Cards */}
      <div>
        <h1 className="text-3xl font-bold mx-auto text-center tracking-tight text-zinc-900">Dashboard Overview</h1>
        <h2 className="text-bg text-zinc-400 pt-10">Stats section</h2>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="bg bg-black text-white">
          <CardHeader>
            <CardTitle className="mx-auto">Total users Users</CardTitle>
          </CardHeader>
          <CardContent className="mx-auto">{users.length}</CardContent>
        </Card>
        <Card className="bg bg-black text-white">
          <CardHeader>
            <CardTitle className="mx-auto">Total Properties</CardTitle>
          </CardHeader>
          <CardContent className="mx-auto">{properties.length}</CardContent>
        </Card>
        <Card className="bg bg-black text-white">
          <CardHeader>
            <CardTitle className="mx-auto">Total Reports</CardTitle>
          </CardHeader>
          <CardContent className="mx-auto">{reports.length}</CardContent>
        </Card>
      </div>

      <h2 className="text-bg text-zinc-400 pt-5">Recent activities</h2>
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Recent Users</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="divide-y">
              {users.slice(0, 5).map(user => (
                <li key={user.id} className="py-2 flex justify-between">
                  <span>{user.name} ({user.role})</span>
                  <span>{user.active ? "Active" : "Inactive"}</span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent Properties</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="divide-y">
              {properties.slice(0, 5).map(p => (
                <li key={p.id} className="py-2 flex justify-between">
                  <span>{p.title}</span>
                  <span>${p.price}</span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent Reports</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="divide-y">
              {reports.slice(0, 5).map(r => (
                <li key={r.id} className="py-2 flex justify-between">
                  <span>{r.reason}</span>
                  <span>{r.status}</span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      </div>
    </div>
    
  );
}
