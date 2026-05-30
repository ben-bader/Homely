"use client";

import React, { useState, useMemo, useCallback } from "react";
import { useLocale } from "next-intl";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerClose,
  DrawerTrigger,
} from "@/components/ui/drawer";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";
import { PaginationFooter } from "@/components/ui/pagination";
import { FaEye } from "react-icons/fa";
import { api } from "@/lib/api";
import { useUsers } from "@/app/users/useUsers";
import { getUserFromToken } from "@/lib/auth";

/* ------------------------------------------------------------------ */
/*  Constants                                                           */
/* ------------------------------------------------------------------ */

const PERMISSIONS = [
  { key: "properties", label: "Properties" },
  { key: "reports", label: "Reports" },
  { key: "boosts", label: "Boosts" },
  { key: "visit_requests", label: "Visit Requests" },
  { key: "activity_monitoring", label: "Activity Monitoring" },
  { key: "chats", label: "Chats" },
  { key: "manage_parameters", label: "Manage Parameters" },
];

const ROLES = ["USER", "AGENT", "ADMIN"];

type PermissionMap = Record<string, boolean>;

interface CreatedUser {
  id?: string;
  name: string;
  email: string;
  role: string;
}

/* ------------------------------------------------------------------ */
/*  Admin user type (reuse from useUsers or define locally)            */
/* ------------------------------------------------------------------ */

type AdminUser = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
  createdAt: string | number;
  permissions?: PermissionMap;
};

type Language = "en" | "fr";

const dict = {
  en: {
    title: "Admin Manager",
    userDetails: "User Details",
    permissions: "Permissions",
    fullName: "Full Name *",
    emailAddress: "Email Address *",
    phoneNumber: "Phone Number",
    password: "Password *",
    role: "Role",
    selectRole: "Select role",
    creating: "Creating...",
    createBtn: "Create User & Continue →",
    backBtn: "← Back",
    finishBtn: "Finish & Save →",
    successTitle: "User created successfully",
    successDesc: "{name} ({email}) registered as {role} with {count} permission{plural}.",
    successEmail: "A verification email has been sent to their inbox.",
    createAnother: "Create Another User",
    adminsTitle: "Admins",
    total: "Total",
    active: "Active",
    inactive: "Inactive",
    searchPlaceholder: "Search admins...",
    noResults: "No admins found",
    colName: "Name",
    colEmail: "Email",
    colRole: "Role",
    colJoined: "Joined",
    colStatus: "Status",
    colManage: "Manage Permissions",
    btnOpen: "Manage ▼",
    btnClose: "Close ▲",
    page: "Page",
    of: "of",
    details: {
      title: "User Info",
      desc: "Full details for this admin",
      yes: "Yes",
      no: "No",
      close: "Close"
    },
    panel: {
      selectAll: "Select all",
      clear: "Clear",
      saved: "Saved ✓",
      saveChanges: "Save changes →",
      grantedInfo: "{count} of {total} permissions granted"
    },
    permLabels: {
      properties: "Properties",
      reports: "Reports",
      boosts: "Boosts",
      visit_requests: "Visit Requests",
      activity_monitoring: "Activity Monitoring",
      chats: "Chats",
      manage_parameters: "Manage Parameters"
    }
  },
  fr: {
    title: "Gestion des Admins",
    userDetails: "Détails de l'Utilisateur",
    permissions: "Autorisations",
    fullName: "Nom Complet *",
    emailAddress: "Adresse E-mail *",
    phoneNumber: "Numéro de Téléphone",
    password: "Mot de passe *",
    role: "Rôle",
    selectRole: "Choisir un rôle",
    creating: "Création...",
    createBtn: "Créer l'Utilisateur & Continuer →",
    backBtn: "← Retour",
    finishBtn: "Terminer & Enregistrer →",
    successTitle: "Utilisateur créé avec succès",
    successDesc: "{name} ({email}) enregistré en tant que {role} avec {count} autorisation{plural}.",
    successEmail: "Un e-mail de vérification a été envoyé dans sa boîte de réception.",
    createAnother: "Créer un autre utilisateur",
    adminsTitle: "Administrateurs",
    total: "Total",
    active: "Actif",
    inactive: "Inactif",
    searchPlaceholder: "Rechercher des admins...",
    noResults: "Aucun administrateur trouvé",
    colName: "Nom",
    colEmail: "E-mail",
    colRole: "Rôle",
    colJoined: "Rejoint le",
    colStatus: "Statut",
    colManage: "Gérer les Autorisations",
    btnOpen: "Gérer ▼",
    btnClose: "Fermer ▲",
    page: "Page",
    of: "sur",
    details: {
      title: "Info Utilisateur",
      desc: "Détails complets de cet administrateur",
      yes: "Oui",
      no: "Non",
      close: "Fermer"
    },
    panel: {
      selectAll: "Tout sélectionner",
      clear: "Effacer",
      saved: "Enregistré ✓",
      saveChanges: "Enregistrer →",
      grantedInfo: "{count} sur {total} autorisations accordées"
    },
    permLabels: {
      properties: "Propriétés",
      reports: "Signalements",
      boosts: "Boosts",
      visit_requests: "Demandes de visite",
      activity_monitoring: "Suivi des activités",
      chats: "Chats",
      manage_parameters: "Gérer les paramètres"
    }
  }
};

/* ------------------------------------------------------------------ */
/*  Helpers                                                             */
/* ------------------------------------------------------------------ */

function parseDate(value: string | number | null | undefined): Date | null {
  if (!value) return null;
  if (typeof value === "number") return new Date(value);
  if (typeof value === "string" && !value.endsWith("Z") && !value.includes("+"))
    return new Date(value + "Z");
  return new Date(value);
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      <span className="text-sm font-medium">{value}</span>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/*  Inline Permissions Panel (shown below the row)                     */
/* ------------------------------------------------------------------ */

function PermissionsPanel({
  user,
  permissions,
  onToggle,
  onSelectAll,
  onClearAll,
  onSave,
  t,
}: {
  user: AdminUser;
  permissions: PermissionMap;
  onToggle: (key: string) => void;
  onSelectAll: () => void;
  onClearAll: () => void;
  onSave: () => void;
  t: any;
}) {
  const [saved, setSaved] = useState(false);
  const grantedCount = Object.values(permissions).filter(Boolean).length;

  function handleSave() {
    onSave();
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  }

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-3">
          {/* User pill */}
          <div className="w-7 h-7 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xs font-semibold">
            {user.name.charAt(0).toUpperCase()}
          </div>
          <div>
            <p className="text-xs font-semibold text-foreground leading-none">{user.name}</p>
            <p className="text-[11px] text-muted-foreground mt-0.5">{user.email}</p>
          </div>
          <div className="flex items-center gap-2 ml-1">
            <span className="text-xs font-semibold uppercase tracking-widest text-muted-foreground">{t.permissions}</span>
            {grantedCount > 0 && (
              <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                {grantedCount}
              </span>
            )}
          </div>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={onSelectAll}
            className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium"
          >
            {t.panel.selectAll}
          </button>
          <span className="text-muted-foreground text-[11px]">·</span>
          <button
            onClick={onClearAll}
            className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium"
          >
            {t.panel.clear}
          </button>
        </div>
      </div>

      {/* Permission tags */}
      <div className="p-4">
        <div className="flex flex-wrap gap-2">
          {PERMISSIONS.map((p) => {
            const on = permissions[p.key];
            const label = t.permLabels[p.key as keyof typeof t.permLabels] || p.label;
            return (
              <button
                key={p.key}
                onClick={() => onToggle(p.key)}
                className={`flex items-center gap-2 px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  on
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                <span
                  className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${
                    on ? "bg-primary-foreground" : "bg-muted-foreground"
                  }`}
                />
                {label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Footer */}
      <div className="flex items-center justify-between px-4 py-2.5 border-t bg-muted/40">
        <span className="text-[11px] text-muted-foreground">
          {t.panel.grantedInfo.replace("{count}", String(grantedCount)).replace("{total}", String(PERMISSIONS.length))}
        </span>
        <div className="flex items-center gap-3">
          {saved && (
            <span className="text-[11px] text-green-600 font-medium">{t.panel.saved}</span>
          )}
          <Button size="sm" onClick={handleSave}>
            {t.panel.saveChanges}
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/*  Main Component                                                      */
/* ------------------------------------------------------------------ */

export default function AdminManager() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
  const t = dict[lang];
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  /* ---------- Create-user form state ---------- */
  const [step, setStep] = useState<1 | 2>(1);
  const [form, setForm] = useState({ name: "", email: "", phone: "", password: "", role: "USER" });
  const [formPermissions, setFormPermissions] = useState<PermissionMap>(
    Object.fromEntries(PERMISSIONS.map((p) => [p.key, false]))
  );
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);
  const [createdUser, setCreatedUser] = useState<CreatedUser | null>(null);

  /* ---------- Admin table state ---------- */
  const { users, setUsers } = useUsers();
  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [expandedId, setExpandedId] = useState<string | null>(null);
  // Per-admin permission state: { [adminId]: PermissionMap }
  const [adminPerms, setAdminPerms] = useState<Record<string, PermissionMap>>({});

  /* ---------- Filtered admins ---------- */
  const admins = useMemo<AdminUser[]>(
    () =>
      users.filter((u) => u.role?.toUpperCase() === "ADMIN" &&
        [u.name, u.email].join(" ").toLowerCase().includes(search.toLowerCase())
      ),
    [users, search]
  );

  /* ---------- Summary counts ---------- */
  const allAdmins = useMemo(() => users.filter((u) => u.role?.toUpperCase() === "ADMIN"), [users]);
  const totalActive = allAdmins.filter((u) => u.active).length;
  const totalInactive = allAdmins.filter((u) => !u.active).length;

  /* ---------- Per-admin permissions helpers ---------- */
 function getPerms(id: string): PermissionMap {
  if (adminPerms[id]) return adminPerms[id];

  const stored = localStorage.getItem(`permissions_${id}`);
  if (stored) {
    try {
      const parsed = JSON.parse(stored);
      setAdminPerms((prev) => ({ ...prev, [id]: parsed }));
      return parsed;
    } catch {}
  }

  return Object.fromEntries(PERMISSIONS.map((p) => [p.key, false]));
}

  function setPerms(id: string, map: PermissionMap) {
    setAdminPerms((prev) => ({ ...prev, [id]: map }));
  }

  /* ---------- Toggle active ---------- */
  const handleToggle = useCallback(
    async (id: string, currentActive: boolean) => {
      if (currentActive) {
        await api.put(`/admin/users/${id}/deactivate`);
      } else {
        await api.put(`/admin/users/${id}/activate`);
      }
      setUsers((prev) =>
        prev.map((u) => (u.id === id ? { ...u, active: !currentActive } : u))
      );
    },
    [setUsers]
  );

  /* ---------- Save permissions ---------- */
async function handleSavePerms(id: string) {
  const perms = getPerms(id);

  // ✅ save in localStorage
  localStorage.setItem(`permissions_${id}`, JSON.stringify(perms));

  // ✅ ALSO update state (important for instant UI)
  setAdminPerms((prev) => ({ ...prev, [id]: perms }));

  // ✅ if current user → update sidebar permissions
  const user = getUserFromToken();
  if (user && user.id === id) {
    localStorage.setItem("permissions", JSON.stringify(perms));
  }
}

  /* ---------- Table columns ---------- */
  const columns = useMemo<ColumnDef<AdminUser>[]>(
    () => [
      {
        accessorKey: "name",
        header: t.colName,
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xs font-semibold flex-shrink-0">
              {row.original.name.charAt(0).toUpperCase()}
            </div>
            <span className="font-medium text-sm">{row.original.name}</span>
          </div>
        ),
      },
      { accessorKey: "email", header: t.colEmail },
      {
        id: "role",
        header: t.colRole,
        cell: () => <Badge variant="outline">ADMIN</Badge>,
      },
      {
        accessorKey: "createdAt",
        header: t.colJoined,
        cell: ({ row }) =>
          parseDate(row.original.createdAt)?.toLocaleDateString(dateLocale) ?? "—",
      },
      {
        id: "status",
        header: t.colStatus,
        cell: ({ row }) => (
          <Switch
            checked={row.original.active}
            onCheckedChange={() => handleToggle(row.original.id, row.original.active)}
            className="data-[state=checked]:bg-green-500 data-[state=unchecked]:bg-red-500"
          />
        ),
      },
      {
        id: "view",
        header: "",
        cell: ({ row }) => (
          <Drawer direction="right">
            <DrawerTrigger asChild>
              <Button variant="ghost" size="icon">
                <FaEye />
              </Button>
            </DrawerTrigger>
            <DrawerContent className="max-w-md ml-auto h-full p-6">
              <DrawerHeader>
                <DrawerTitle>{t.details.title}</DrawerTitle>
                <DrawerDescription>{t.details.desc}</DrawerDescription>
              </DrawerHeader>
              <div className="space-y-4 mt-6">
                <InfoRow label={t.colName} value={row.original.name} />
                <InfoRow label={t.colEmail} value={row.original.email} />
                <InfoRow label={t.colRole} value={row.original.role} />
                <InfoRow
                  label={t.colJoined}
                  value={parseDate(row.original.createdAt)?.toLocaleString(dateLocale) ?? "—"}
                />
                <InfoRow label={t.colStatus} value={row.original.active ? t.details.yes : t.details.no} />
              </div>
              <DrawerFooter className="mt-auto">
                <DrawerClose asChild>
                  <Button variant="outline" className="bg-black hover:bg-gray-900 text-white border-gray-700">
                    {t.details.close}
                  </Button>
                </DrawerClose>
              </DrawerFooter>
            </DrawerContent>
          </Drawer>
        ),
      },
      {
        id: "manage",
        header: t.colManage,
        cell: ({ row }) => {
          const id = row.original.id;
          const isOpen = expandedId === id;
          return (
            <Button
              size="sm"
              variant={isOpen ? "default" : "outline"}
              onClick={() => setExpandedId(isOpen ? null : id)}
            >
              {isOpen ? t.btnClose : t.btnOpen}
            </Button>
          );
        },
      },
    ],
    [handleToggle, expandedId, t, dateLocale]
  );

  const table = useReactTable({
    data: admins,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  /* ---------- Form handlers ---------- */
  function handleInput(e: React.ChangeEvent<HTMLInputElement>) {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setError("");
  }

  function toggleFormPermission(key: string) {
    setFormPermissions((p) => ({ ...p, [key]: !p[key] }));
  }

  async function handleRegister() {
    const { name, email, phone, password, role } = form;
    if (!name || !email || !password) {
      setError(lang === "fr" ? "Le nom, l'e-mail et le mot de passe sont requis." : "Name, email and password are required.");
      return;
    }
    setLoading(true);
    setError("");
    try {
      const response = await api.post("/auth/register", { name, email, phone, password, role });
      setCreatedUser(response.data);
      setStep(2);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : "Registration failed.";
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  async function handleFinish() {
    if (createdUser?.id) {
      localStorage.setItem(`permissions_${createdUser.id}`, JSON.stringify(formPermissions));
    }
    setSuccess(true);
  }

  function handleReset() {
    setForm({ name: "", email: "", phone: "", password: "", role: "USER" });
    setFormPermissions(Object.fromEntries(PERMISSIONS.map((p) => [p.key, false])));
    setStep(1);
    setSuccess(false);
    setCreatedUser(null);
    setError("");
  }

  const formGrantedCount = Object.values(formPermissions).filter(Boolean).length;

  /* ---------------------------------------------------------------- */
  /*  Render                                                            */
  /* ---------------------------------------------------------------- */

  if (success) {
    return (
      <div className="px-8 space-y-6">
        <h2 className="text-xl font-semibold">{t.title}</h2>
        <div className="rounded-lg border bg-green-50 dark:bg-green-950/30 p-8 flex flex-col items-center text-center gap-3">
          <div className="w-12 h-12 rounded-full bg-green-100 dark:bg-green-900/50 flex items-center justify-center text-green-600 text-xl font-bold">
            ✓
          </div>
          <p className="font-semibold text-foreground">{t.successTitle}</p>
          <p className="text-sm text-muted-foreground">
            {t.successDesc
              .replace("{name}", createdUser?.name || "")
              .replace("{email}", createdUser?.email || "")
              .replace("{role}", createdUser?.role || "")
              .replace("{count}", String(formGrantedCount))
              .replace("{plural}", formGrantedCount !== 1 ? "s" : "")}
          </p>
          <p className="text-xs text-muted-foreground">{t.successEmail}</p>
          <Button variant="outline" className="mt-2" onClick={handleReset}>
            {t.createAnother}
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="px-8 space-y-10">
      {/* ============================================================ */}
      {/*  SECTION 1 — Create user form                                */}
      {/* ============================================================ */}
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold">{t.title}</h2>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <span className={step === 1 ? "text-foreground font-semibold" : ""}>{t.userDetails}</span>
            <span>→</span>
            <span className={step === 2 ? "text-foreground font-semibold" : ""}>{t.permissions}</span>
          </div>
        </div>

        {/* Step 1 */}
        {step === 1 && (
          <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
            <div className="px-4 py-2.5 border-b bg-primary">
              <span className="text-xs font-semibold uppercase tracking-widest text-white">
                {t.userDetails}
              </span>
            </div>
            <div className="p-6 space-y-5">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">
                    {t.fullName}
                  </label>
                  <Input name="name" placeholder="John Doe" value={form.name} onChange={handleInput} />
                </div>
                <div className="space-y-1.5">
                  <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">
                    {t.emailAddress}
                  </label>
                  <Input
                    name="email"
                    type="email"
                    placeholder="john@example.com"
                    value={form.email}
                    onChange={handleInput}
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">
                    {t.phoneNumber}
                  </label>
                  <Input name="phone" placeholder="+212 600 000000" value={form.phone} onChange={handleInput} />
                </div>
                <div className="space-y-1.5">
                  <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">
                    {t.password}
                  </label>
                  <Input
                    name="password"
                    type="password"
                    placeholder="Min. 6 characters"
                    value={form.password}
                    onChange={handleInput}
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">
                  {t.role}
                </label>
                <Select value={form.role} onValueChange={(v) => setForm((f) => ({ ...f, role: v }))}>
                  <SelectTrigger className="w-48">
                    <SelectValue placeholder={t.selectRole} />
                  </SelectTrigger>
                  <SelectContent>
                    {ROLES.map((r) => (
                      <SelectItem key={r} value={r}>
                        {r}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {error && (
                <p className="text-sm text-destructive bg-destructive/10 border border-destructive/20 rounded-md px-3 py-2">
                  {error}
                </p>
              )}

              <div className="flex justify-end">
                <Button onClick={handleRegister} disabled={loading}>
                  {loading ? t.creating : t.createBtn}
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* Step 2 */}
        {step === 2 && (
          <div className="space-y-4">
            <div className="rounded-lg border bg-muted/40 px-4 py-3 flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm font-semibold">
                {createdUser?.name?.charAt(0).toUpperCase()}
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">{createdUser?.name}</p>
                <p className="text-xs text-muted-foreground">{createdUser?.email}</p>
              </div>
              <Badge variant="outline">{createdUser?.role}</Badge>
            </div>

            <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
              <div className="flex items-center justify-between px-4 py-2.5 border-b bg-primary">
                <div className="flex items-center gap-2">
                  <span className="text-xs font-semibold uppercase tracking-widest text-white">
                    {t.permissions}
                  </span>
                  {formGrantedCount > 0 && (
                    <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                      {formGrantedCount}
                    </span>
                  )}
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() =>
                      setFormPermissions(Object.fromEntries(PERMISSIONS.map((p) => [p.key, true])))
                    }
                    className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium text-white/90 hover:text-white"
                  >
                    {t.panel.selectAll}
                  </button>
                  <span className="text-white/60 text-[11px]">·</span>
                  <button
                    onClick={() =>
                      setFormPermissions(Object.fromEntries(PERMISSIONS.map((p) => [p.key, false])))
                    }
                    className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium text-white/90 hover:text-white"
                  >
                    {t.panel.clear}
                  </button>
                </div>
              </div>
              <div className="p-4">
                <div className="flex flex-wrap gap-2">
                  {PERMISSIONS.map((p) => {
                    const on = formPermissions[p.key];
                    const label = t.permLabels[p.key as keyof typeof t.permLabels] || p.label;
                    return (
                      <button
                        key={p.key}
                        onClick={() => toggleFormPermission(p.key)}
                        className={`flex items-center gap-2 px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                          on
                            ? "bg-primary text-primary-foreground border-primary"
                            : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                        }`}
                      >
                        <span
                          className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${
                            on ? "bg-primary-foreground" : "bg-muted-foreground"
                          }`}
                        />
                        {label}
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>

            <div className="flex justify-between">
              <Button variant="outline" onClick={() => setStep(1)}>
                {t.backBtn}
              </Button>
              <Button onClick={handleFinish}>{t.finishBtn}</Button>
            </div>
          </div>
        )}
      </div>

      {/* ============================================================ */}
      {/*  SECTION 2 — Admins table                                    */}
      {/* ============================================================ */}
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <h2 className="text-xl font-semibold">{t.adminsTitle}</h2>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
          <div className="rounded-lg border p-4 bg-muted/50">
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{t.total}</p>
            <p className="text-2xl font-bold text-foreground">{allAdmins.length}</p>
          </div>
          <div className="rounded-lg border p-4 bg-green-50 dark:bg-green-950/30">
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{t.active}</p>
            <p className="text-2xl font-bold text-green-600">{totalActive}</p>
          </div>
          <div className="rounded-lg border p-4 bg-destructive/10">
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{t.inactive}</p>
            <p className="text-2xl font-bold text-destructive">{totalInactive}</p>
          </div>
        </div>

        {/* Search */}
        <Input
          placeholder={t.searchPlaceholder}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />

        {/* Table */}
        <div className="overflow-auto rounded-lg border">
          <Table>
            <TableHeader className="bg-primary">
              {table.getHeaderGroups().map((hg) => (
                <TableRow key={hg.id}>
                  {hg.headers.map((header) => (
                    <TableHead key={header.id} className="text-white">
                      {flexRender(header.column.columnDef.header, header.getContext())}
                    </TableHead>
                  ))}
                </TableRow>
              ))}
            </TableHeader>
            <TableBody>
              {table.getRowModel().rows.length === 0 ? (
                <TableRow>
                  <TableCell
                    colSpan={columns.length}
                    className="text-center text-muted-foreground py-12 text-sm"
                  >
                    {t.noResults}
                  </TableCell>
                </TableRow>
              ) : (
                table.getRowModel().rows.map((row) => (
                  <React.Fragment key={row.id}>
                    <TableRow>
                      {row.getVisibleCells().map((cell) => (
                        <TableCell key={cell.id}>
                           {flexRender(cell.column.columnDef.cell, cell.getContext())}
                        </TableCell>
                      ))}
                    </TableRow>
                    {/* Expanded permissions panel */}
                    {expandedId === row.original.id && (
                      <TableRow>
                        <TableCell colSpan={columns.length} className="p-3 bg-muted/20">
                          <PermissionsPanel
                            user={row.original}
                            permissions={getPerms(row.original.id)}
                            onToggle={(key) =>
                              setPerms(row.original.id, {
                                ...getPerms(row.original.id),
                                [key]: !getPerms(row.original.id)[key],
                              })
                            }
                            onSelectAll={() =>
                              setPerms(
                                row.original.id,
                                Object.fromEntries(PERMISSIONS.map((p) => [p.key, true]))
                              )
                            }
                            onClearAll={() =>
                              setPerms(
                                row.original.id,
                                Object.fromEntries(PERMISSIONS.map((p) => [p.key, false]))
                              )
                            }
                            onSave={() => handleSavePerms(row.original.id)}
                            t={t}
                          />
                        </TableCell>
                      </TableRow>
                    )}
                  </React.Fragment>
                ))
              )}
            </TableBody>
          </Table>
        </div>

        <PaginationFooter
          pageInfo={`${t.page} ${pagination.pageIndex + 1} ${t.of} ${Math.max(table.getPageCount(), 1)}`}
          onPrevious={() => table.previousPage()}
          onNext={() => table.nextPage()}
          canPrevious={table.getCanPreviousPage()}
          canNext={table.getCanNextPage()}
        />
      </div>
    </div>
  );
}