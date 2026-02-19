"use client"

import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { toast } from "sonner"
import { getUserFromToken } from "@/lib/auth"
import { api } from "@/lib/api"

export default function Profile() {
  const user = getUserFromToken()

  const [form, setForm] = React.useState({
    name: user?.name || "",
    email: user?.sub || ""
  })

  const [savingInfo, setSavingInfo] = React.useState(false)
  const [savingPassword, setSavingPassword] = React.useState(false)

  const [passwordData, setPasswordData] = React.useState({
    currentPassword: "",
    newPassword: "",
    confirmPassword: ""
  })

  ////////////////////////////////////////////////////////////
  // UPDATE INFO
  ////////////////////////////////////////////////////////////

  const handleUpdateInfo = async () => {
    toast.promise(
      api.put("/profile/me", {
        name: form.name,
        email: form.email
      }),
      {
        loading: "Updating profile...",
        success: "Profile updated successfully!",
        error: "Failed to update profile."
      }
    )
  }

  ////////////////////////////////////////////////////////////
  // UPDATE PASSWORD
  ////////////////////////////////////////////////////////////

  const handlePasswordUpdate = async () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      toast.error("Passwords do not match", {
        description: "Please make sure both passwords are identical."
      })
      return
    }

    toast.promise(
      api.put("/auth/change-password", {
        currentPassword: passwordData.currentPassword,
        newPassword: passwordData.newPassword
      }),
      {
        loading: "Updating password...",
        success: "Password updated successfully!",
        error: "Failed to update password."
      }
    )

    setPasswordData({
      currentPassword: "",
      newPassword: "",
      confirmPassword: ""
    })
  }

  ////////////////////////////////////////////////////////////
  // DELETE ACCOUNT
  ////////////////////////////////////////////////////////////

  const handleDelete = () => {
    toast("Are you absolutely sure?", {
      description: "This action cannot be undone.",
      action: {
        label: "Delete",
        onClick: async () => {
          try {
            await api.delete(`/users/${user?.id}`)

            toast.success("Account deleted successfully")

            localStorage.removeItem("jwt")
            window.location.href = "/"
          } catch {
            toast.error("Failed to delete account")
          }
        }
      }
    })
  }

  return (
    <div className="flex justify-center py-12 px-4 bg-muted/30 min-h-screen">
      <div className="w-full max-w-2xl space-y-12">

        {/* ACCOUNT INFO */}
        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl">Account Information</CardTitle>
            <CardDescription>
              Update your name and email address.
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-6">

            <div className="space-y-3">
              <Label>Name</Label>
              <Input
                value={form.name}
                onChange={(e) =>
                  setForm({ ...form, name: e.target.value })
                }
              />
            </div>

            <div className="space-y-3">
              <Label>Email</Label>
              <Input
                value={form.email}
                onChange={(e) =>
                  setForm({ ...form, email: e.target.value })
                }
              />
            </div>

            <Button
              onClick={handleUpdateInfo}
              className="w-full h-11 rounded-xl"
            >
              Save Changes
            </Button>

          </CardContent>
        </Card>

        {/* PASSWORD */}
        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl">Change Password</CardTitle>
            <CardDescription>
              Make sure your password is strong and secure.
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-6">

            <div className="space-y-3">
              <Label>Current Password</Label>
              <Input
                type="password"
                value={passwordData.currentPassword}
                onChange={(e) =>
                  setPasswordData({
                    ...passwordData,
                    currentPassword: e.target.value
                  })
                }
              />
            </div>

            <div className="space-y-3">
              <Label>New Password</Label>
              <Input
                type="password"
                value={passwordData.newPassword}
                onChange={(e) =>
                  setPasswordData({
                    ...passwordData,
                    newPassword: e.target.value
                  })
                }
              />
            </div>

            <div className="space-y-3">
              <Label>Confirm New Password</Label>
              <Input
                type="password"
                value={passwordData.confirmPassword}
                onChange={(e) =>
                  setPasswordData({
                    ...passwordData,
                    confirmPassword: e.target.value
                  })
                }
              />
            </div>

            <Button
              onClick={handlePasswordUpdate}
              className="w-full h-11 rounded-xl"
            >
              Update Password
            </Button>

          </CardContent>
        </Card>

        {/* DELETE */}
        <Card className="rounded-2xl shadow-lg border-red-200">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl text-red-600">
              Danger Zone
            </CardTitle>
            <CardDescription>
              Deleting your account will permanently remove all your data.
              This action cannot be undone.
            </CardDescription>
          </CardHeader>

          <CardContent>
            <Button
              variant="destructive"
              onClick={handleDelete}
              className="w-full h-11 rounded-xl"
            >
              Delete My Account
            </Button>
          </CardContent>
        </Card>

      </div>
    </div>
  )
}
