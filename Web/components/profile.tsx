"use client"

import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { api } from "@/lib/api"
import { getUserFromToken } from "@/lib/auth"

type ProfileDto = {
  userId: string
  // Add more fields here when backend adds them
  // bio?: string
  // phone?: string
}

export default function Profile() {
  const user = getUserFromToken()

  const [profile, setProfile] = React.useState<ProfileDto | null>(null)
  const [loading, setLoading] = React.useState(true)
  const [saving, setSaving] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)

  // Fetch profile data
  React.useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await api.get<ProfileDto>("/profile/me")
        setProfile(res.data)
      } catch (err) {
        console.error(err)
        setError("Failed to load profile")
      } finally {
        setLoading(false)
      }
    }

    fetchProfile()
  }, [])

  const handleSave = async () => {
    if (!profile) return

    try {
      setSaving(true)
      setError(null)

      await api.put("/profile/me", profile)

      alert("Profile updated successfully")
    } catch (err) {
      console.error(err)
      setError("Failed to update profile")
    } finally {
      setSaving(false)
    }
  }

  if (loading) return <div className="p-6">Loading profile…</div>

  return (
    <div className="flex justify-center px-4">
      <Card className="w-full sm:w-3/4 md:w-2/3 lg:w-1/2">
        <CardHeader>
          <CardTitle>Admin Profile</CardTitle>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* User Info (From JWT) */}
          <div className="flex items-center gap-4">
            <Avatar className="h-16 w-16">
              <AvatarFallback>
                {user?.name?.charAt(0).toUpperCase() ?? "?"}
              </AvatarFallback>
            </Avatar>

            <div>
              <p className="font-medium">{user?.name}</p>
              <p className="text-sm text-muted-foreground">
                {user?.sub}
              </p>
            </div>
          </div>

          {/* Editable Profile Section */}
          {/* Example field — backend can extend ProfileDto */}
          {/* 
          <div className="space-y-2">
            <Label>Bio</Label>
            <Input
              value={profile?.bio ?? ""}
              onChange={(e) =>
                setProfile({ ...profile!, bio: e.target.value })
              }
            />
          </div>
          */}

          {error && (
            <p className="text-sm text-red-500">{error}</p>
          )}

          <Button onClick={handleSave} disabled={saving}>
            {saving ? "Saving..." : "Save Changes"}
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
