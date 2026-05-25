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
    <form onSubmit={login} className={cn("flex flex-col gap-6", className)} {...props}>
      <FieldGroup>
        <div className="flex flex-col items-center gap-1 text-center">
          <h1 className="text-2xl font-bold">Login to your account</h1>
          <p className="text-muted-foreground text-sm text-balance">
            Enter your email below to login to your account
          </p>
        </div>
        <Field>
          <FieldLabel htmlFor="email">Email</FieldLabel>
          <Input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="m@example.com"
            required
          />
        </Field>
        <Field>
          <div className="flex items-center">
            <FieldLabel htmlFor="password">Password</FieldLabel>
            <a
              href="/forgot-password"
              className="ml-auto text-sm underline-offset-4 hover:underline"
            >
              Forgot your password?
            </a>
          </div>
          <Input
            id="password"
            type="password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </Field>
        <Field>
          <Button type="submit" disabled={loading}>
            {loading ? "Logging in..." : "Login"}
          </Button>
        </Field>
        {error && <p className="text-red-500">{error}</p>}
      </FieldGroup>
    </form>
  );
}
