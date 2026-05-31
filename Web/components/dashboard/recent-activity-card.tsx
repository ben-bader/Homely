import { AnalyticsCard } from "./analytics-card"
import { ActivityFeed, type ActivityItem } from "./activity-feed"

export function RecentActivityCard({ items }: { items: ActivityItem[] }) {
  return (
    <AnalyticsCard title="Activity Feed" description="Recent platform events that need attention.">
      <ActivityFeed items={items} />
    </AnalyticsCard>
  )
}
