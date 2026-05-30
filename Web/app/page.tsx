
import type { Metadata } from "next";
import { LoginForm } from "@/components/dashboardComponents/login-form"
import Logo from "@/components/logo/Logo";

export const metadata: Metadata = {
  title: "Homely - Admin Login",
  description: "Sign in to the Homely admin portal",
};

export default function LoginPage() {
  return (
    <div className="flex flex-col min-h-screen items-center justify-center w-full bg-background relative overflow-hidden">
      {/* Decorative colored blobs for the light theme */}
      <div className="absolute top-0 right-0 -mr-20 -mt-20 w-[600px] h-[600px] rounded-full bg-primary/10 blur-[120px] pointer-events-none" />
      <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-[500px] h-[500px] rounded-full bg-secondary/30 blur-[100px] pointer-events-none" />

      <div className="grid lg:grid-cols-2 w-full max-w-6xl rounded-3xl border-0 shadow-[0_20px_50px_rgba(14,165,233,0.1)] bg-card overflow-hidden z-10 relative">
        <div className="flex flex-col justify-center w-full p-8 lg:p-16 bg-card relative z-20">
          <div className="flex items-center mb-10">
              <Logo />
          </div>
          <div className="flex flex-1 items-center justify-center">
            <div className="w-full max-w-md">
              <LoginForm />
            </div>
          </div>
        </div>
        <div className="relative hidden lg:flex flex-col justify-end items-center p-12 overflow-hidden bg-primary/5">
          <div className="absolute inset-0 bg-gradient-to-br from-primary/20 via-primary/5 to-transparent z-10" />
          <img
            src="/login.png?v=4"
            alt="Beautiful property"
            className="absolute inset-0 h-full w-full object-cover"
          />
          <div className="relative z-20 bg-background/80 backdrop-blur-md p-6 rounded-2xl border border-white/50 shadow-lg max-w-md text-center transform hover:scale-105 transition-transform duration-500">
            <h2 className="text-xl font-bold text-foreground mb-2">Welcome to Homely</h2>
            <p className="text-muted-foreground text-sm">Experience the premium property management platform designed for efficiency.</p>
          </div>
        </div>
      </div>
      
      <p className="absolute bottom-6 text-sm text-muted-foreground font-medium">
        &copy; {new Date().getFullYear()} Homely. Engineered with precision.
      </p>
    </div>
  )
}
