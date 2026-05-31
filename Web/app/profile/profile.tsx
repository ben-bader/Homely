"use client"

import * as React from "react"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { toast } from "sonner"
import { getUserFromToken } from "@/lib/auth"
import { api } from "@/lib/api"
import { useTranslations } from "next-intl"
import { Camera, Trash2, AlertTriangle } from "lucide-react"

export default function Profile() {
  const t = useTranslations('profile')
  const user = getUserFromToken()
  const userId = user?.id

  const [form, setForm] = React.useState({ name: "", email: user?.username || "" })
  const [passwordData, setPasswordData] = React.useState({ currentPassword: "", newPassword: "", confirmPassword: "" })
  const [profileData, setProfileData] = React.useState<any>(null)
  const [avatarUrl, setAvatarUrl] = React.useState<string | null>(null)
  const [avatarLoading, setAvatarLoading] = React.useState(false)
  const fileInputRef = React.useRef<HTMLInputElement>(null)

  React.useEffect(() => {
    api.get("/profile/me")
      .then((res) => {
        setProfileData(res.data)
        if (res.data?.avatarUrl) setAvatarUrl(res.data.avatarUrl)
      })
      .catch(() => {})
  }, [])

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    if (file.size > 2 * 1024 * 1024) { toast.error("File must be under 2 MB"); return }

    const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dmnsrbaw9/image/upload"
    const formData = new FormData()
    formData.append("file", file)
    formData.append("upload_preset", "homely_unsigned")
    formData.append("folder", `avatars/${userId || "anonymous"}`)
    formData.append("public_id", `avatar_${userId || "anonymous"}_${Date.now()}`)

    setAvatarLoading(true)
    const uploadPromise = fetch(cloudinaryUrl, { method: "POST", body: formData })
      .then(async (response) => { if (!response.ok) throw new Error("Upload failed"); return response.json() })
      .then(async (data) => {
        const newAvatarUrl = data.secure_url
        await api.put("/profile/me", { bio: profileData?.bio || "", address: profileData?.address || "", idDocumentUrl: profileData?.idDocumentUrl || "", avatarUrl: newAvatarUrl })
        setAvatarUrl(newAvatarUrl)
        setProfileData((prev: any) => ({ ...prev, avatarUrl: newAvatarUrl }))
        window.dispatchEvent(new CustomEvent("avatar-updated", { detail: { avatarUrl: newAvatarUrl } }))
      })
      .finally(() => setAvatarLoading(false))

    toast.promise(uploadPromise, { loading: "Uploading photo…", success: "Photo updated!", error: "Upload failed. Try again." })
    if (fileInputRef.current) fileInputRef.current.value = ""
  }

  const handleRemoveAvatar = async () => {
    toast.promise(
      api.put("/profile/me", { bio: profileData?.bio || "", address: profileData?.address || "", idDocumentUrl: profileData?.idDocumentUrl || "", avatarUrl: null })
        .then(() => {
          setAvatarUrl(null)
          setProfileData((prev: any) => ({ ...prev, avatarUrl: null }))
          window.dispatchEvent(new CustomEvent("avatar-updated", { detail: { avatarUrl: null } }))
        }),
      { loading: "Removing photo…", success: "Photo removed.", error: "Failed to remove photo." }
    )
  }

  const handleUpdateInfo = async () => {
    if (!userId) { toast.error(t('accountInfo.userNotFound')); return }
    toast.promise(api.put(`/users/${userId}`, { name: form.name, email: form.email }), { loading: t('accountInfo.loadingToast'), success: t('accountInfo.successToast'), error: t('accountInfo.errorToast') })
  }

  const handlePasswordUpdate = async () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) { toast.error(t('password.mismatchError'), { description: t('password.mismatchDescription') }); return }
    toast.promise(api.put("/auth/change-password", { currentPassword: passwordData.currentPassword, newPassword: passwordData.newPassword }), { loading: t('password.loadingToast'), success: t('password.successToast'), error: t('password.errorToast') })
    setPasswordData({ currentPassword: "", newPassword: "", confirmPassword: "" })
  }

  const handleDelete = () => {
    if (!userId) { toast.error(t('danger.userNotFound')); return }
    toast(t('danger.confirmTitle'), {
      description: t('danger.confirmDescription'),
      action: {
        label: t('danger.confirmLabel'),
        onClick: async () => {
          try {
            await api.delete(`/users/${userId}`)
            toast.success(t('danger.successToast'))
            localStorage.removeItem("access_token"); localStorage.removeItem("refresh_token"); localStorage.removeItem("jwt"); localStorage.removeItem("auth_user")
            globalThis.window.location.href = "/"
          } catch { toast.error(t('danger.errorToast')) }
        },
      },
    })
  }

  const userInitial = (user?.name ?? "?").charAt(0).toUpperCase()

  return (
    <div className="flex justify-center py-8 px-6 animate-fade-up">
      <div className="w-full max-w-xl space-y-6">
        {/* Avatar */}
        <div className="bg-card border rounded-xl p-6">
          <h2 className="text-base font-semibold mb-4">Profile Photo</h2>
          <div className="flex items-center gap-5">
            <Avatar className="h-20 w-20 text-2xl">
              {avatarUrl && <AvatarImage src={avatarUrl} alt={user?.name ?? "Avatar"} />}
              <AvatarFallback className="bg-primary/10 text-primary font-bold text-xl">{userInitial}</AvatarFallback>
            </Avatar>
            <div className="flex flex-col gap-2">
              <input ref={fileInputRef} type="file" accept="image/jpeg,image/png,image/webp" className="hidden" onChange={handleAvatarUpload} />
              <Button size="sm" onClick={() => fileInputRef.current?.click()} disabled={avatarLoading} className="gap-1.5">
                <Camera className="w-3.5 h-3.5" />Upload
              </Button>
              {avatarUrl && (
                <Button variant="ghost" size="sm" className="text-red-500 hover:text-red-600 gap-1.5" onClick={handleRemoveAvatar}>
                  <Trash2 className="w-3.5 h-3.5" />Remove
                </Button>
              )}
              <p className="text-xs text-muted-foreground">JPG, PNG or WebP · max 2 MB</p>
            </div>
          </div>
        </div>

        {/* Account Info */}
        <div className="bg-card border rounded-xl p-6">
          <h2 className="text-base font-semibold mb-1">{t('accountInfo.title')}</h2>
          <p className="text-xs text-muted-foreground mb-4">{t('accountInfo.description')}</p>
          <div className="space-y-4">
            <div className="space-y-1.5"><Label className="text-xs font-medium">{t('accountInfo.nameLabel')}</Label><Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} /></div>
            <div className="space-y-1.5"><Label className="text-xs font-medium">{t('accountInfo.emailLabel')}</Label><Input value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} /></div>
            <Button onClick={handleUpdateInfo} className="w-full">{t('accountInfo.saveButton')}</Button>
          </div>
        </div>

        {/* Password */}
        <div className="bg-card border rounded-xl p-6">
          <h2 className="text-base font-semibold mb-1">{t('password.title')}</h2>
          <p className="text-xs text-muted-foreground mb-4">{t('password.description')}</p>
          <div className="space-y-4">
            <div className="space-y-1.5"><Label className="text-xs font-medium">{t('password.currentLabel')}</Label><Input type="password" value={passwordData.currentPassword} onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })} /></div>
            <div className="space-y-1.5"><Label className="text-xs font-medium">{t('password.newLabel')}</Label><Input type="password" value={passwordData.newPassword} onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })} /></div>
            <div className="space-y-1.5"><Label className="text-xs font-medium">{t('password.confirmLabel')}</Label><Input type="password" value={passwordData.confirmPassword} onChange={(e) => setPasswordData({ ...passwordData, confirmPassword: e.target.value })} /></div>
            <Button onClick={handlePasswordUpdate} className="w-full">{t('password.updateButton')}</Button>
          </div>
        </div>

        {/* Danger Zone */}
        <div className="bg-card border border-red-200 rounded-xl p-6">
          <div className="flex items-center gap-2 mb-1">
            <AlertTriangle className="w-4 h-4 text-red-500" />
            <h2 className="text-base font-semibold text-red-600">{t('danger.title')}</h2>
          </div>
          <p className="text-xs text-muted-foreground mb-4">{t('danger.description')}</p>
          <Button variant="destructive" onClick={handleDelete} className="w-full">{t('danger.deleteButton')}</Button>
        </div>
      </div>
    </div>
  )
}