"use client"

import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { toast } from "sonner"
import { getUserFromToken } from "@/lib/auth"
import { api } from "@/lib/api"
import { useTranslations } from "next-intl"

export default function Profile() {
  const t = useTranslations('profile')
  const user = getUserFromToken()
  const userId = user?.id

  const [form, setForm] = React.useState({ name: user?.name || "", email: user?.sub || "" })
  const [passwordData, setPasswordData] = React.useState({
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
  })
  const [avatarUrl, setAvatarUrl] = React.useState<string | null>(null)
  const [avatarLoading, setAvatarLoading] = React.useState(false)
  const fileInputRef = React.useRef<HTMLInputElement>(null)

  // Load current avatar on mount
  React.useEffect(() => {
    api.get("/profile/me")
      .then((res) => {
        if (res.data?.avtarUrl) setAvatarUrl(res.data.avtarUrl)
      })
      .catch(() => {})
  }, [])

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    if (file.size > 2 * 1024 * 1024) {
      toast.error("Le fichier doit être inférieur à 2 Mo")
      return
    }

    const formData = new FormData()
    formData.append("file", file)

    setAvatarLoading(true)
    toast.promise(
      api.put("/profile/me/avatar", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      }).then((res) => {
        if (res.data?.avtarUrl) setAvatarUrl(res.data.avtarUrl)
      }),
      {
        loading: "Téléchargement de la photo...",
        success: "Photo mise à jour !",
        error: "Échec du téléchargement. Réessayez.",
      }
    )
    setAvatarLoading(false)

    // Reset input so the same file can be re-selected if needed
    if (fileInputRef.current) fileInputRef.current.value = ""
  }

  const handleRemoveAvatar = async () => {
    toast.promise(
      api.delete("/profile/me/avatar").then(() => setAvatarUrl(null)),
      {
        loading: "Suppression de la photo...",
        success: "Photo supprimée.",
        error: "Impossible de supprimer la photo.",
      }
    )
  }

  const handleUpdateInfo = async () => {
    if (!userId) { toast.error(t('accountInfo.userNotFound')); return }
    toast.promise(
      api.put(`/users/${userId}`, { name: form.name, email: form.email }),
      {
        loading: t('accountInfo.loadingToast'),
        success: t('accountInfo.successToast'),
        error: t('accountInfo.errorToast'),
      }
    )
  }

  const handlePasswordUpdate = async () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      toast.error(t('password.mismatchError'), {
        description: t('password.mismatchDescription'),
      })
      return
    }
    toast.promise(
      api.put("/auth/change-password", {
        currentPassword: passwordData.currentPassword,
        newPassword: passwordData.newPassword,
      }),
      {
        loading: t('password.loadingToast'),
        success: t('password.successToast'),
        error: t('password.errorToast'),
      }
    )
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
            localStorage.removeItem("jwt")
            window.location.href = "/"
          } catch {
            toast.error(t('danger.errorToast'))
          }
        },
      },
    })
  }

  const userInitial = (user?.name ?? "?").charAt(0).toUpperCase()

  return (
    <div className="flex justify-center py-12 px-4 bg-muted/30 min-h-screen">
      <div className="w-full max-w-2xl space-y-6">

        {/* ── Avatar card ── */}
        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-1">
            <CardTitle className="text-xl">
              Photo de profil
            </CardTitle>
            <CardDescription>
              Cette photo apparaîtra dans la barre latérale et dans toute l'application.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex items-center gap-6">
              <Avatar className="h-20 w-20 text-2xl">
                {avatarUrl && <AvatarImage src={avatarUrl} alt={user?.name ?? "Avatar"} />}
                <AvatarFallback>{userInitial}</AvatarFallback>
              </Avatar>

              <div className="flex flex-col gap-2">
                {/* Hidden file input */}
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/jpeg,image/png,image/webp"
                  className="hidden"
                  onChange={handleAvatarUpload}
                />

                <Button
                  variant="default"
                  size="sm"
                  disabled={avatarLoading}
                  onClick={() => fileInputRef.current?.click()}
                  className="bg-gray-800 hover:bg-gray-700 text-white"
                >
                  Upload
                </Button>

                {avatarUrl && (
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-destructive hover:text-destructive"
                    onClick={handleRemoveAvatar}
                  >
                    Supprimer la photo
                  </Button>
                )}

                <p className="text-xs text-muted-foreground">
                  JPG, PNG ou WebP · max 2 Mo
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* ── Account info card ── */}
        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl">{t('accountInfo.title')}</CardTitle>
            <CardDescription>{t('accountInfo.description')}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-3">
              <Label>{t('accountInfo.nameLabel')}</Label>
              <Input
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
              />
            </div>
            <div className="space-y-3">
              <Label>{t('accountInfo.emailLabel')}</Label>
              <Input
                value={form.email}
                onChange={(e) => setForm({ ...form, email: e.target.value })}
              />
            </div>
            <Button onClick={handleUpdateInfo} className="w-full h-11 rounded-xl">
              {t('accountInfo.saveButton')}
            </Button>
          </CardContent>
        </Card>

        {/* ── Password card ── */}
        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl">{t('password.title')}</CardTitle>
            <CardDescription>{t('password.description')}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-3">
              <Label>{t('password.currentLabel')}</Label>
              <Input
                type="password"
                value={passwordData.currentPassword}
                onChange={(e) =>
                  setPasswordData({ ...passwordData, currentPassword: e.target.value })
                }
              />
            </div>
            <div className="space-y-3">
              <Label>{t('password.newLabel')}</Label>
              <Input
                type="password"
                value={passwordData.newPassword}
                onChange={(e) =>
                  setPasswordData({ ...passwordData, newPassword: e.target.value })
                }
              />
            </div>
            <div className="space-y-3">
              <Label>{t('password.confirmLabel')}</Label>
              <Input
                type="password"
                value={passwordData.confirmPassword}
                onChange={(e) =>
                  setPasswordData({ ...passwordData, confirmPassword: e.target.value })
                }
              />
            </div>
            <Button onClick={handlePasswordUpdate} className="w-full h-11 rounded-xl">
              {t('password.updateButton')}
            </Button>
          </CardContent>
        </Card>

        {/* ── Danger zone card ── */}
        <Card className="rounded-2xl shadow-lg border-red-200">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl text-red-600">{t('danger.title')}</CardTitle>
            <CardDescription>{t('danger.description')}</CardDescription>
          </CardHeader>
          <CardContent>
            <Button
              variant="destructive"
              onClick={handleDelete}
              className="w-full h-11 rounded-xl"
            >
              {t('danger.deleteButton')}
            </Button>
          </CardContent>
        </Card>

      </div>
    </div>
  )
}