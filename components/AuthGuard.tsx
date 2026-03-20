"use client"

import { useEffect, useState } from "react"
import { auth } from "../lib/firebase"
import { onAuthStateChanged } from "firebase/auth"
import { useRouter, usePathname } from "next/navigation"

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const [loading, setLoading] = useState(true)
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (user) => {
      if (!user && pathname !== "/login") {
        router.push("/login")
      } else {
        setLoading(false)
      }
    })
    return () => unsub()
  }, [pathname])

  if (loading) return null

  return <>{children}</>
}