"use client"

import { useEffect, useState } from "react"
import { auth } from "../lib/firebase"
import { onAuthStateChanged } from "firebase/auth"
import { useRouter } from "next/navigation"

export default function AuthGuard({ children }: { children: React.ReactNode }) {

  const [loading, setLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {

    const unsub = onAuthStateChanged(auth, (user) => {

      if (!user) {
        router.replace("/login") // ← 強制リダイレクト
      } else {
        setLoading(false)
      }

    })

    return () => unsub()

  }, [])

  if (loading) return null

  return <>{children}</>
}