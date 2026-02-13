import Image from 'next/image'
import React from 'react'

const Logo = () => {
  return (
    <div>
      <Image
      src="/logo_homely.png"
      width={300}
      height={100}
      alt='logo'
      className=''
      />
    </div>
  )
}

export default Logo
