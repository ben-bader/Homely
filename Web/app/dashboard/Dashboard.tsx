'use client';
import React from 'react'
import { ChartAreaInteractive } from '../../components/dashboardComponents/chart-area-interactive'
import { DataTable } from '../../components/dashboardComponents/data-table'
import { SectionCards } from '../../components/dashboardComponents/section-cards'
import { useReports } from '@/app/reports/useReports'
import { useTranslations } from 'next-intl'

const Dashboard = () => {
    const t = useTranslations('dashboard')
    const { reports, loading, updateReportStatus } = useReports()

    if (loading) {
        return <p className="text-center">{t('loading')}</p>
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

export default Dashboard