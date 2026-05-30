import React from 'react'

interface LogoProps {
  variant?: "white" | "colored";
}

const Logo = ({ variant = "colored" }: LogoProps) => {
  const src = variant === "white" ? "/whitelogo.png?v=4" : "/logo_homely.png?v=4";
  return (
    <div className="flex items-center justify-center">
      <img
        src={src}
        style={{ width: "120px", height: "auto" }}
        alt="logo"
      />
    </div>
  )
}

export default Logo
