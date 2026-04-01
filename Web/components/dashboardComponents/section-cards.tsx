"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardAction,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { IconUsers, IconHome, IconFlag, IconRocket } from "@tabler/icons-react";

export function SectionCards() {
  const [users, setUsers] = useState(0);
  const [properties, setProperties] = useState(0);
  const [reports, setReports] = useState(0);
  const [boosts, setBoosts] = useState(0);

 useEffect(() => {
  const fetchStats = async () => {
    try {
      const res = await api.get("/admin/dashboard-stats");

      const data = res.data || {};

      setUsers(data.users || 0);
      setProperties(data.properties || 0);
      setReports(data.reports || 0);
      setBoosts(data.boosts || 0);

    } catch (error) {
      console.error("Failed to load dashboard stats", error);
    }
  };

  fetchStats();
}, []);

  return (
    <div className="grid grid-cols-1 gap-4 px-4 lg:grid-cols-2 lg:px-6">
      {/* USERS */}
      <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
        <CardHeader>
          <CardDescription>Total Users</CardDescription>
          <CardTitle className="text-3xl font-bold">{users}</CardTitle>
          <CardAction>
            <Badge variant="outline" className="bg-gray-50">
              <IconUsers className="size-4 mr-1" />
              Platform Users
            </Badge>
          </CardAction>
        </CardHeader>
        <CardFooter className="text-muted-foreground text-sm">
          Registered accounts in the system
        </CardFooter>
      </Card>

      {/* PROPERTIES */}
      <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
        <CardHeader>
          <CardDescription>Total Properties</CardDescription>
          <CardTitle className="text-3xl font-bold">{properties}</CardTitle>
          <CardAction>
            <Badge variant="outline" className="bg-gray-50">
              <IconHome className="size-4 mr-1" />
              Listings
            </Badge>
          </CardAction>
        </CardHeader>
        <CardFooter className="text-muted-foreground text-sm">
          Properties currently listed
        </CardFooter>
      </Card>

      {/* REPORTS */}
      <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
        <CardHeader>
          <CardDescription>Total Reports</CardDescription>
          <CardTitle className="text-3xl font-bold">{reports}</CardTitle>
          <CardAction>
            <Badge variant="outline" className="bg-gray-50">
              <IconFlag className="size-4 mr-1" />
              Moderation
            </Badge>
          </CardAction>
        </CardHeader>
        <CardFooter className="text-muted-foreground text-sm">
          Reports pending review
        </CardFooter>
      </Card>

      {/* ACTIVE BOOSTS */}
      <Card className="bg-linear-to-b from-neutral-950/5 to-transparent">
        <CardHeader>
          <CardDescription>Active Boosts</CardDescription>
          <CardTitle className="text-3xl font-bold">{boosts}</CardTitle>
          <CardAction>
            <Badge variant="outline" className="bg-gray-50">
              <IconRocket className="size-4 mr-1" />
              Promotions
            </Badge>
          </CardAction>
        </CardHeader>
        <CardFooter className="text-muted-foreground text-sm">
          Currently boosted properties
        </CardFooter>
      </Card>
    </div>
  );
}
