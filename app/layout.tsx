import "./globals.css"
import { Home, Users, Beer, Utensils, Newspaper, Settings } from "lucide-react"

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ja">
      <body>

        <div className="app">

          <aside className="sidebar">

            <div className="logo">ADMIN</div>

            <nav className="menuList">

              <div className="menuItem">
                <Home size={20}/>
                <span>Dashboard</span>
              </div>

              <div className="menuItem">
                <Users size={20}/>
                <span>Users</span>
              </div>

              <div className="menuItem">
                <Beer size={20}/>
                <span>Drink</span>
              </div>

              <div className="menuItem">
                <Utensils size={20}/>
                <span>Food</span>
              </div>

              <div className="menuItem">
                <Newspaper size={20}/>
                <span>News</span>
              </div>

              <div className="menuItem">
                <Settings size={20}/>
                <span>Settings</span>
              </div>

            </nav>

          </aside>


          <div className="main">

            <header className="header">
              Oh Yeah！管理ツール
            </header>

            <div className="page">
              {children}
            </div>

          </div>

        </div>

      </body>
    </html>
  )
}