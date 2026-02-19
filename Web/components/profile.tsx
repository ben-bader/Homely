"use client"

import * as React from "react"
import { useRouter } from "next/navigation" // Import router for redirects
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { api } from "@/lib/api"
import { getUserFromToken } from "@/lib/auth"

type ProfileDto = {
  userId: string
  name?: string
  email?: string
}

export default function AdminProfile() {
  const router = useRouter() // Router for navigation
  const user = getUserFromToken()

  const [profile, setProfile] = React.useState<ProfileDto | null>(null)
  const [loading, setLoading] = React.useState(true)
  const [saving, setSaving] = React.useState(false)
  const [error, setError] = React.useState<string | null>(null)
  const [password, setPassword] = React.useState("")
  const [newPassword, setNewPassword] = React.useState("")
  const [passwordError, setPasswordError] = React.useState<string | null>(null)

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

  const handleSaveProfile = async () => {
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

  const handleChangePassword = async () => {
    if (!password || !newPassword) {
      setPasswordError("Please fill out both fields")
      return
    }

    try {
      setSaving(true)
      setPasswordError(null)

      await api.put("/profile/me/password", { currentPassword: password, newPassword })
      alert("Password updated successfully")
      setPassword("")
      setNewPassword("")
    } catch (err) {
      console.error(err)
      setPasswordError("Failed to update password")
    } finally {
      setSaving(false)
    }
  }

  const handleDeleteAccount = async () => {
    if (!confirm("Are you sure you want to delete your account? This action cannot be undone.")) return
    try {
      setSaving(true)
      await api.delete("/profile/me")
      alert("Account deleted successfully")

      // Clear JWT and redirect to login
      localStorage.removeItem("jwt")
      router.push("/login") // Redirect to login page
    } catch (err) {
      console.error(err)
      alert("Failed to delete account")
    } finally {
      setSaving(false)
    }
  }

  const handleLogout = () => {
    localStorage.removeItem("jwt")
    router.push("/login") // Redirect to login page
  }

  if (loading) return <div className="p-6">Loading profile…</div>

  return (
    <div className="flex flex-col items-center px-4 space-y-8">
      {/* Current Admin Info */}
      <Card className="w-full max-w-4xl">
        <CardHeader>
          <CardTitle>Admin Profile</CardTitle>
        </CardHeader>
        <CardContent className="flex items-center gap-6 p-8">
          <Avatar className="h-20 w-20">
            <AvatarFallback>{user?.name?.charAt(0).toUpperCase() ?? "?"}</AvatarFallback>
          </Avatar>
          <div>
            <p className="text-xl font-medium">{user?.name}</p>
            <p className="text-md text-muted-foreground">{user?.sub}</p>
          </div>
        </CardContent>
      </Card>

      {/* Editable Sections */}
      <div className="flex flex-col lg:flex-row w-full max-w-4xl gap-8">
        {/* User Info Update */}
        <Card className="flex-1">
          <CardHeader>
            <CardTitle>Update Info</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 p-8">
            <div className="space-y-2">
              <Label>Name</Label>
              <Input
                value={profile?.name ?? ""}
                onChange={(e) => setProfile({ ...profile!, name: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label>Email</Label>
              <Input
                type="email"
                value={profile?.email ?? ""}
                onChange={(e) => setProfile({ ...profile!, email: e.target.value })}
              />
            </div>
            {error && <p className="text-sm text-red-500">{error}</p>}
            <Button onClick={handleSaveProfile} disabled={saving}>
              {saving ? "Saving..." : "Save Changes"}
            </Button>
          </CardContent>
        </Card>

        {/* Password Update */}
        <Card className="flex-1">
          <CardHeader>
            <CardTitle>Change Password</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 p-8">
            <div className="space-y-2">
              <Label>Current Password</Label>
              <Input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label>New Password</Label>
              <Input
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
              />
            </div>
            {passwordError && <p className="text-sm text-red-500">{passwordError}</p>}
            <Button onClick={handleChangePassword} disabled={saving}>
              {saving ? "Saving..." : "Update Password"}
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Delete Account */}
      <Button variant="destructive" onClick={handleDeleteAccount} disabled={saving}>
        Delete Account
      </Button>
    </div>
  )
}
