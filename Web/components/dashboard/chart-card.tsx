"use client"

import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"

import { AnalyticsCard } from "./analytics-card"

type ChartCardProps = {
  data: Array<{ label: string; value: number }>
}

export function ChartCard({ data }: ChartCardProps) {
  return (
    <AnalyticsCard title="Revenue Chart" description="Premium boost revenue and marketplace activity trend.">
      <div className="h-[320px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data}>
            <CartesianGrid vertical={false} stroke="#E2E8F0" />
            <XAxis dataKey="label" tickLine={false} axisLine={false} tick={{ fontSize: 12, fill: "#64748B" }} />
            <YAxis tickLine={false} axisLine={false} tick={{ fontSize: 12, fill: "#64748B" }} />
            <Tooltip cursor={{ fill: "#EEF2FF" }} contentStyle={{ borderRadius: 16, border: "1px solid #E2E8F0" }} />
            <Bar dataKey="value" fill="#4F46E5" radius={[12, 12, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </AnalyticsCard>
  )
}
