"use client"

import "./globals.css"
import { Home, Users, Beer, Utensils, Newspaper, Image } from "lucide-react"
import Link from "next/link"
import AuthGuard from "@/components/AuthGuard"

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ja">
      <body>

        <AuthGuard>

          <div className="app">

            {/* サイドバー */}
            <aside className="sidebar">

              <div className="logo">ADMIN</div>

              <nav className="menuList">

                <Link href="/dashboard" className="menuItem">
                  <Home size={20}/>
                  <span>Dashboard</span>
                </Link>

                <Link href="/users" className="menuItem">
                  <Users size={20}/>
                  <span>Users</span>
                </Link>

                <Link href="/drinks" className="menuItem">
                  <Beer size={20}/>
                  <span>Drink</span>
                </Link>

                <Link href="/foods" className="menuItem">
                  <Utensils size={20}/>
                  <span>Food</span>
                </Link>

                <Link href="/news" className="menuItem">
                  <Newspaper size={20}/>
                  <span>News</span>
                </Link>

                <Link href="/slider" className="menuItem">
                  <Image size={18}/>
                  <span>Slider</span>
                </Link>

              </nav>

            </aside>

            {/* メイン */}
            <div className="main">

              <header className="header">
                Oh Yeah！管理ツール
              </header>

              <div className="page">
                {children}
              </div>

            </div>

          </div>

        </AuthGuard>

      </body>
    </html>
  )
}