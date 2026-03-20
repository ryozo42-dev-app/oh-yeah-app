"use client"

import { useEffect, useState, useRef } from "react"
import { auth, db } from "../lib/firebase"
import { onAuthStateChanged, signOut } from "firebase/auth"
import { doc, getDoc } from "firebase/firestore"

export default function UserMenu(){

  const [name,setName]=useState("")
  const [open,setOpen]=useState(false)
  const [user,setUser]=useState<any>(null)

  const menuRef = useRef<HTMLDivElement>(null)

  /* -------------------------
     ユーザー取得
  ------------------------- */
  useEffect(()=>{

    const load = async(user:any)=>{

      const snap = await getDoc(doc(db,"users",user.uid))

      if(snap.exists()){
        setName(snap.data().name)
      }

    }

    const unsub = onAuthStateChanged(auth,(u)=>{

      if(u){
        setUser(u)
        load(u)
      }else{
        setUser(null)
      }

    })

    return ()=>unsub()

  },[])

  /* -------------------------
     外クリックで閉じる
  ------------------------- */
  useEffect(()=>{

    const handleClickOutside = (e:any)=>{

      if(menuRef.current && !menuRef.current.contains(e.target)){
        setOpen(false)
      }

    }

    document.addEventListener("mousedown", handleClickOutside)

    return ()=>{
      document.removeEventListener("mousedown", handleClickOutside)
    }

  },[])

  /* -------------------------
     ログアウト
  ------------------------- */
  const logout = async()=>{

    await signOut(auth)
    location.href="/login"

  }

  /* -------------------------
     未ログイン時は非表示
  ------------------------- */
  if(!user) return null

  /* =========================
     UI
  ========================= */
  return(

    <div ref={menuRef} style={{position:"relative"}}>

      {/* ▼ ボタン */}
      <div
        onClick={()=>setOpen(!open)}
        style={{
          cursor:"pointer",
          background:"#ffffff",
          color:"#333",
          padding:"6px 12px",
          borderRadius:"8px",
          border:"1px solid #ddd",
          fontWeight:"bold",
          fontSize:"14px",
          minWidth:"120px",
          textAlign:"center",
          boxShadow:"0 2px 6px rgba(0,0,0,0.1)"
        }}
      >
        {name || "User"} ▼
      </div>

      {/* ▼ プルダウン */}
      {open && (

        <div
          style={{
            position:"absolute",
            top:"110%",
            left:"50%",
            transform:"translateX(-50%)",
            background:"#ffffff",
            color:"#333",
            borderRadius:"8px",
            boxShadow:"0 6px 16px rgba(0,0,0,0.15)",
            width:"160px",
            overflow:"hidden",
            zIndex:1000,
            border:"1px solid #eee"
          }}
        >

          {/* パスワード変更 */}
          <div
            style={{
              padding:"8px 10px",
              cursor:"pointer",
              borderBottom:"1px solid #eee",
              fontSize:"14px"
            }}
            onClick={()=>{
              setOpen(false)
              location.href="/password"
            }}
            onMouseEnter={(e)=>e.currentTarget.style.background="#f5f5f5"}
            onMouseLeave={(e)=>e.currentTarget.style.background="#fff"}
          >
            パスワード変更
          </div>

          {/* ログアウト */}
          <div
            style={{
              padding:"8px 10px",
              cursor:"pointer",
              fontSize:"14px"
            }}
            onClick={logout}
            onMouseEnter={(e)=>e.currentTarget.style.background="#f5f5f5"}
            onMouseLeave={(e)=>e.currentTarget.style.background="#fff"}
          >
            ログアウト
          </div>

        </div>

      )}

    </div>

  )
}