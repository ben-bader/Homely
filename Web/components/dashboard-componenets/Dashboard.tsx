import React, { useEffect, useState } from 'react'
import { ChartAreaInteractive } from '../chart-area-interactive'
import { DataTable } from '../data-table'
import { SectionCards } from '../section-cards'
import { api } from '@/lib/api'
import {useReports} from '@/hooks/useReports'

const Dashboard = () => {
    const { reports, loading, updateReportStatus } = useReports()
    if (loading) {
        return <p className="text-center">Loading Dashboard…</p>
    }
    return (
        <div className="flex flex-col gap-4">
            <SectionCards />
            <div className="flex flex-col gap-4 px-4 lg:px-6">
                <ChartAreaInteractive />
                <DataTable
                    data={reports}
                    onStatusChange={async (reportId, status) => updateReportStatus(reportId, status)}
                />
            </div>
        </div>
    )
}

export default Dashboard;
