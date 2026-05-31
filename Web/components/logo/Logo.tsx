import React from 'react'

interface LogoProps {
  variant?: "white" | "colored";
  className?: string;
  imageClassName?: string;
}

const Logo = ({ variant = "colored", className, imageClassName }: LogoProps) => {
  const src = variant === "white" ? "/whitelogo.png?v=4" : "/logo_homely.png?v=4";
  return (
    <div className={`flex items-center justify-center ${className ?? ""}`}>
      <img
        src={src}
        className={imageClassName}
        style={imageClassName ? undefined : { width: "120px", height: "auto" }}
        alt="logo"
      />
    </div>
  )
}

export default Logo
