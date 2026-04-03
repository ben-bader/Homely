"use client"

import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { toast } from "sonner"
import { getUserFromToken } from "@/lib/auth"
import { api } from "@/lib/api"
import { useTranslations } from "next-intl"

export default function Profile() {
  const t = useTranslations('profile');
  const user = getUserFromToken()
  const userId = user?.id

  const [form, setForm] = React.useState({ name: user?.name || "", email: user?.sub || "" })
  const [passwordData, setPasswordData] = React.useState({ currentPassword: "", newPassword: "", confirmPassword: "" })

  const handleUpdateInfo = async () => {
    if (!userId) { toast.error(t('accountInfo.userNotFound')); return; }
    toast.promise(api.put(`/users/${userId}`, { name: form.name, email: form.email }), {
      loading: t('accountInfo.loadingToast'),
      success: t('accountInfo.successToast'),
      error: t('accountInfo.errorToast')
    });
  }

  const handlePasswordUpdate = async () => {
    if (passwordData.newPassword !== passwordData.confirmPassword) {
      toast.error(t('password.mismatchError'), { description: t('password.mismatchDescription') });
      return;
    }
    toast.promise(api.put("/auth/change-password", { currentPassword: passwordData.currentPassword, newPassword: passwordData.newPassword }), {
      loading: t('password.loadingToast'),
      success: t('password.successToast'),
      error: t('password.errorToast')
    });
    setPasswordData({ currentPassword: "", newPassword: "", confirmPassword: "" });
  }

  const handleDelete = () => {
    if (!userId) { toast.error(t('danger.userNotFound')); return; }
    toast(t('danger.confirmTitle'), {
      description: t('danger.confirmDescription'),
      action: {
        label: t('danger.confirmLabel'),
        onClick: async () => {
          try {
            await api.delete(`/users/${userId}`);
            toast.success(t('danger.successToast'));
            localStorage.removeItem("jwt");
            window.location.href = "/";
          } catch { toast.error(t('danger.errorToast')); }
        }
      }
    });
  }

  return (
    <div className="flex justify-center py-12 px-4 bg-muted/30 min-h-screen">
      <div className="w-full max-w-2xl space-y-12">
        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl">{t('accountInfo.title')}</CardTitle>
            <CardDescription>{t('accountInfo.description')}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-3"><Label>{t('accountInfo.nameLabel')}</Label><Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} /></div>
            <div className="space-y-3"><Label>{t('accountInfo.emailLabel')}</Label><Input value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} /></div>
            <Button onClick={handleUpdateInfo} className="w-full h-11 rounded-xl">{t('accountInfo.saveButton')}</Button>
          </CardContent>
        </Card>

        <Card className="rounded-2xl shadow-lg">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl">{t('password.title')}</CardTitle>
            <CardDescription>{t('password.description')}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-3"><Label>{t('password.currentLabel')}</Label><Input type="password" value={passwordData.currentPassword} onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })} /></div>
            <div className="space-y-3"><Label>{t('password.newLabel')}</Label><Input type="password" value={passwordData.newPassword} onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })} /></div>
            <div className="space-y-3"><Label>{t('password.confirmLabel')}</Label><Input type="password" value={passwordData.confirmPassword} onChange={(e) => setPasswordData({ ...passwordData, confirmPassword: e.target.value })} /></div>
            <Button onClick={handlePasswordUpdate} className="w-full h-11 rounded-xl">{t('password.updateButton')}</Button>
          </CardContent>
        </Card>

        <Card className="rounded-2xl shadow-lg border-red-200">
          <CardHeader className="space-y-3">
            <CardTitle className="text-xl text-red-600">{t('danger.title')}</CardTitle>
            <CardDescription>{t('danger.description')}</CardDescription>
          </CardHeader>
          <CardContent>
            <Button variant="destructive" onClick={handleDelete} className="w-full h-11 rounded-xl">{t('danger.deleteButton')}</Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}