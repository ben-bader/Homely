"use client"

import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { getUserFromToken } from "@/lib/auth"

export default function Profile() {
  const user = getUserFromToken()

  const [name, setName] = React.useState(user?.name ?? "")
  const [email, setEmail] = React.useState(user?.sub ?? "")

  const handleSave = () => {
    // Just local alert, no backend call
    alert("Profile changes saved locally (not persisted)")
  }

  return (
    <div className="flex justify-center">
      <Card className="w-full sm:w-3/4 md:w-2/3 lg:w-1/2">
        <CardHeader>
          <CardTitle>Your Profile</CardTitle>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* User Info */}
          <div className="flex items-center gap-4">
            <Avatar className="h-16 w-16">
              <AvatarFallback>{name?.charAt(0).toUpperCase() ?? "?"}</AvatarFallback>
            </Avatar>

            <div>
              <p className="font-medium">{name}</p>
              <p className="text-sm text-muted-foreground">{email}</p>
            </div>
          </div>

          {/* Editable Form */}
          <div className="space-y-2">
            <Label>Name</Label>
            <Input value={name ?? ""} onChange={(e) => setName(e.target.value)} />
          </div>

          <div className="space-y-2">
            <Label>Email</Label>
            <Input value={email ?? ""} onChange={(e) => setEmail(e.target.value)} />
          </div>

          <Button onClick={handleSave}>
            Save Changes
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
