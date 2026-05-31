
import type { Metadata } from "next";
import { LoginForm } from "@/components/dashboardComponents/login-form"
import Logo from "@/components/logo/Logo";

export const metadata: Metadata = {
  title: "Homely - Admin Login",
  description: "Sign in to the Homely admin portal",
};

export default function LoginPage() {
  return (
    <div className="flex flex-col min-h-screen items-center justify-center w-full bg-background relative">
      <div className="relative z-10 w-full max-w-md mx-auto px-6">
        {/* Logo + branding */}
        <div className="flex flex-col items-center mb-8">
          <div className="mb-3 flex h-12 w-12 items-center justify-center overflow-hidden rounded-lg border border-border bg-white">
            <Logo imageClassName="h-8 w-8 object-contain" />
          </div>
          <h1 className="text-xl font-semibold text-foreground">Homely</h1>
          <p className="text-sm text-muted-foreground mt-0.5">Admin Portal</p>
        </div>

        {/* Login card */}
        <div className="bg-white border border-border rounded-lg shadow-[0_1px_2px_rgba(16,24,40,0.04),0_4px_12px_rgba(16,24,40,0.04)] p-8">
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-foreground">Sign in</h2>
            <p className="text-sm text-muted-foreground mt-1">
              Enter your credentials to access the dashboard
            </p>
          </div>
          <LoginForm />
        </div>

        {/* Footer */}
        <p className="text-center text-xs text-muted-foreground mt-8">
          &copy; {new Date().getFullYear()} Homely. All rights reserved.
        </p>
      </div>
    </div>
  )
}
