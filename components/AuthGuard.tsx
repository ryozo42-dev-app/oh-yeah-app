"use client"

import { useEffect, useState } from "react"
import { auth, db } from "@/lib/firebase"
import { onAuthStateChanged } from "firebase/auth"
import { useRouter, usePathname } from "next/navigation"
import { doc, getDoc } from "firebase/firestore"

export default function AuthGuard({ children }: { children: React.ReactNode }) {

  const [loading, setLoading] = useState(true)
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {

    const unsub = onAuthStateChanged(auth, async (user) => {

      // 未ログイン
      if (!user) {
        if (pathname !== "/login") {
          router.push("/login")
        }
        setLoading(false)
        return
      }

      try {
        // role取得
        const snap = await getDoc(doc(db, "users", user.uid))

        if (!snap.exists()) {
          console.warn("ユーザーデータなし")
        }

      } catch (e) {
        console.error("role取得エラー", e)
      }

      setLoading(false)

    })

    return () => unsub()

  }, [pathname])

  if (loading) return null

  return <>{children}</>
}