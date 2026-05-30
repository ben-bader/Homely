"use client";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import {
  Field,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { useState } from "react";

export function LoginForm({
  className,
  ...props
}: React.ComponentProps<"form">) {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

 const login = async (e: React.SyntheticEvent<HTMLFormElement>) => {
  e.preventDefault();

  try {
    setLoading(true);
    setError("");

    const res = await api.post("/auth/login", {
      email,
      password,
    });

    const accessToken = res.data.accessToken;
    const refreshToken = res.data.refreshToken;

    if (!accessToken) throw new Error("Missing access token from login response")

    localStorage.setItem("access_token", accessToken)
    if (refreshToken) {
      localStorage.setItem("refresh_token", refreshToken)
    }

    router.push("/dashboard")
  } catch (err) {
    console.log(err);
    setError("Login failed");
  } finally {
    setLoading(false);
  }
};

  return (
    <form onSubmit={login} className={cn("flex flex-col w-full", className)} {...props}>
      <div className="flex flex-col gap-1 text-left mb-8">
        <h1 className="text-3xl font-bold tracking-tight text-foreground">Sign in</h1>
        <p className="text-muted-foreground text-sm font-medium">
          Enter your email and password to access your dashboard
        </p>
      </div>
      
      <div className="flex flex-col gap-5">
        <Field className="space-y-2">
          <FieldLabel htmlFor="email" className="text-xs font-bold uppercase tracking-wider text-muted-foreground">Email Address</FieldLabel>
          <Input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="m@example.com"
            required
            className="h-12 px-4 rounded-xl transition-all duration-300 bg-subtle-background border-border/60 focus:border-primary focus:ring-4 focus:ring-primary/20 hover:border-primary/40 text-base"
          />
        </Field>
        
        <Field className="space-y-2">
          <div className="flex items-center justify-between">
            <FieldLabel htmlFor="password" className="text-xs font-bold uppercase tracking-wider text-muted-foreground">Password</FieldLabel>
            <a
              href="/forgot-password"
              className="text-xs font-bold text-[#7D9B76] hover:text-[#6B8A64] transition-colors"
>
        
              Forgot password?
            </a>
          </div>
          <Input
            id="password"
            type="password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="h-12 px-4 rounded-xl transition-all duration-300 bg-subtle-background border-border/60 focus:border-primary focus:ring-4 focus:ring-primary/20 hover:border-primary/40 text-base"
            placeholder="••••••••"
          />
        </Field>
<div className="pt-2">
  <Button 
    type="submit" 
    disabled={loading} 
    className="w-full h-12 rounded-xl bg-[#7D9B76] hover:bg-[#6B8A64] text-[#F5F0E8] shadow-[0_4px_14px_0_rgba(125,155,118,0.45)] transition-all duration-300 hover:shadow-[0_6px_20px_rgba(125,155,118,0.3)] hover:-translate-y-0.5 font-bold text-base"
  >
    {loading ? (
      <span className="flex items-center gap-2">
        <span className="h-4 w-4 rounded-full border-2 border-[#F5F0E8] border-t-transparent animate-spin" />
        Logging in...
      </span>
    ) : (
      "Login"
    )}
  </Button>
</div>

        {error && (
          <div className="p-3 rounded-lg bg-destructive/10 border border-destructive/20 animate-in fade-in slide-in-from-top-2">
            <p className="text-destructive text-sm font-bold text-center">{error}</p>
          </div>
        )}
      </div>
    </form>
  );
}
