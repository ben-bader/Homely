
import { LoginForm } from "@/components/login-form"
import Logo from "@/components/logo/Logo";
export default function LoginPage() {
  return (
    <div className="flex flex-col lg:p-16 h-screen items-center justify-center w-full">
    <div className="grid lg:grid-cols-2 w-full h-full rounded-lg border">
      <div className="flex flex-col justify-center w-full">
        <div className="flex items-center my-auto">
            <Logo />
        </div>
        <div className="flex flex-1 items-center justify-center">
          <div className="w-full max-w-xs">
            <LoginForm />
          </div>
        </div>
      </div>
      <div className="bg-muted relative hidden lg:block">
        <img
          src="/login.png"
          alt="Image"
          className="absolute inset-0 h-full w-full object-cover dark:brightness-[0.2] dark:grayscale rounded-r-lg"
        />
      </div>
    </div>
       </div>
  )
}
