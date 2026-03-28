"use client"

import AuthGuard from "@/components/AuthGuard"

import { useEffect,useState } from "react"

import {
collection,
getDocs,
deleteDoc,
updateDoc,
doc,
addDoc,
query,
orderBy
} from "firebase/firestore"

import {
ref,
uploadBytes,
getDownloadURL,
deleteObject
} from "firebase/storage"

import { db, storage } from "@/lib/firebase"

type News={
id?:string
title:string
body:string
imageUrl?:string
date:any
isPublished:boolean
}

export default function News(){

const [news,setNews]=useState<News[]>([])
const [selected,setSelected]=useState<string[]>([])
const [page,setPage]=useState(1)

const [showAdd,setShowAdd]=useState(false)
const [showEditModal,setShowEditModal]=useState(false)

const [editNews,setEditNews]=useState<News|null>(null)

const [modalImage,setModalImage]=useState("")
const [showImageModal,setShowImageModal]=useState(false)

const [newNews,setNewNews]=useState({
title:"",
body:"",
imageUrl:"",
isPublished:true
})

const [newImageFile,setNewImageFile] = useState<File | null>(null)
const [previewAdd,setPreviewAdd] = useState<string | null>(null)

const [editImage,setEditImage] = useState<File | null>(null)
const [preview,setPreview] = useState<string | null>(null)

const perPage=6

/* -------------------------
画像処理（追加）
------------------------- */
const processImage = async (file: File) => {

  const img = new Image()
  img.src = URL.createObjectURL(file)

  await new Promise((resolve) => {
    img.onload = resolve
  })

  const canvas = document.createElement("canvas")
  const ctx = canvas.getContext("2d")

  const maxWidth = 800
  const scale = maxWidth / img.width

  canvas.width = maxWidth
  canvas.height = img.height * scale

  ctx?.drawImage(img, 0, 0, canvas.width, canvas.height)

  const blob: Blob = await new Promise((resolve) => {
    canvas.toBlob((b) => resolve(b!), "image/jpeg", 0.7)
  })

  const fileName = `news_${Date.now()}.jpg`

  const storageRef = ref(storage, `news/${fileName}`)

  await uploadBytes(storageRef, blob)

  const url = await getDownloadURL(storageRef)

  return url
}

const deleteOldImage = async (url: string) => {

  try{

    if(!url) return

    const decoded = decodeURIComponent(url)
    const path = decoded.split("/o/")[1].split("?")[0]

    const imageRef = ref(storage, path)

    await deleteObject(imageRef)

  }catch(e){
    console.log("削除失敗（無視OK）", e)
  }

}

/* -------------------------
load
------------------------- */

useEffect(()=>{

const load = async () => {

  const q = query(
    collection(db,"news"),
    orderBy("date","desc") // ★新しい順
  )

  const snap = await getDocs(q)

  const list = snap.docs.map(d=>{

    const data = d.data()

    return{
      id:d.id,
      title:data.title||"",
      body:data.body||"",
      imageUrl:data.imageUrl||"",
      date:data.date?.toDate?.() || null,
      isPublished:data.isPublished ?? true
    }

  })

  setNews(list)
}

load()

},[])

/* -------------------------
page
------------------------- */

const start=(page-1)*perPage
const end=start+perPage
const view=news.slice(start,end)

const totalPage=Math.ceil(news.length/perPage)
const pages=Array.from({length:totalPage},(_,i)=>i+1)

/* -------------------------
checkbox
------------------------- */

const toggleSelect=(id:string)=>{

if(selected.includes(id)){
setSelected(selected.filter(n=>n!==id))
}else{
setSelected([...selected,id])
}

}

/* -------------------------
delete
------------------------- */

const deleteRow=async(id:string)=>{

if(!confirm("削除しますか？")) return

await deleteDoc(doc(db,"news",id))

setNews(news.filter(n=>n.id!==id))

}

const bulkDelete=async()=>{

if(selected.length===0){
alert("ニュースを選択してください")
return
}

if(!confirm("削除しますか？")) return

for(const id of selected){
await deleteDoc(doc(db,"news",id))
}

setNews(news.filter(n=>!selected.includes(n.id!)))
setSelected([])

}

/* -------------------------
publish toggle
------------------------- */

const togglePublish=async(n:News)=>{

await updateDoc(doc(db,"news",n.id!),{
isPublished:!n.isPublished
})

setNews(
news.map(x=>
x.id===n.id
? {...x,isPublished:!x.isPublished}
: x
)
)

}

/* -------------------------
add
------------------------- */

const addNews = async () => {

  if(!newNews.title){
    alert("タイトルを入力してください")
    return
  }

  let imageUrl = ""

  // ★画像処理
  if(newImageFile){
    imageUrl = await processImage(newImageFile)
  }

  await addDoc(collection(db,"news"),{

    title:newNews.title,
    body:newNews.body,
    imageUrl:imageUrl,
    isPublished:newNews.isPublished,
    date:new Date(),
    createdAt: new Date()

  })

  // リセット
  setShowAdd(false)
  setNewImageFile(null)

  location.reload()

}

/* -------------------------
edit
------------------------- */

const saveEdit = async () => {

  if(!editNews?.id) return

  let imageUrl = editNews.imageUrl || ""

  // ★ 新画像がある場合
  if(editImage){

    // 古い画像削除
    if(editNews.imageUrl){
      await deleteOldImage(editNews.imageUrl)
    }

    // 新画像保存
    imageUrl = await processImage(editImage)
  }

  await updateDoc(doc(db,"news",editNews.id),{

    title:editNews.title,
    body:editNews.body,
    imageUrl:imageUrl,
    isPublished:editNews.isPublished

  })

  setNews(
    news.map(n=>
      n.id===editNews.id
        ? {...editNews,imageUrl}
        : n
    )
  )

  setShowEditModal(false)
  setEditImage(null)
  setPreview(null)

}

/* =========================
UI
========================= */

return(

<AuthGuard>

<div style={{padding:"10px 30px"}}>

<h1 style={{textAlign:"center"}}>News管理システム</h1>

<table style={{
width:"100%",
borderCollapse:"collapse",
background:"#fff",
tableLayout:"fixed"
}}>

<thead>

<tr style={{background:"#ddd"}}>

<th style={{width:"40px",border:"1px solid #ccc"}}>

<input type="checkbox"
onChange={(e)=>{
if(e.target.checked){
setSelected(view.map(n=>n.id!))
}else{
setSelected([])
}
}}
/>

</th>

<th style={{width:"100px",border:"1px solid #ccc"}}>画像</th>
<th style={{width:"300px",border:"1px solid #ccc"}}>タイトル</th>
<th style={{border:"1px solid #ccc"}}>本文</th>
<th style={{width:"140px",border:"1px solid #ccc"}}>日付</th>
<th style={{width:"80px",border:"1px solid #ccc"}}>公開</th>
<th style={{width:"120px",border:"1px solid #ccc"}}>操作</th>

</tr>

</thead>

<tbody>

{view.map((n,i)=>(

<tr key={n.id||i}>

<td style={{border:"1px solid #ddd",textAlign:"center"}}>

<input type="checkbox"
checked={selected.includes(n.id!)}
onChange={()=>toggleSelect(n.id!)}
/>

</td>

<td style={{border:"1px solid #ddd",textAlign:"center"}}>

{n.imageUrl &&(

<img
src={n.imageUrl}
style={{
height:"60px",
width:"80px",
objectFit:"cover",
borderRadius:"6px",
cursor:"pointer"
}}
onClick={()=>{
setModalImage(n.imageUrl || "")
setShowImageModal(true)
}}
/>

)}

</td>

<td style={{border:"1px solid #ddd",padding:"6px"}}>
{n.title}
</td>

<td style={{border:"1px solid #ddd",padding:"6px"}}>
{n.body}
</td>

<td style={{border:"1px solid #ddd",textAlign:"center"}}>

{n.date
? n.date.toLocaleDateString()
: ""
}

</td>

<td style={{border:"1px solid #ddd",textAlign:"center"}}>

<input
type="checkbox"
checked={n.isPublished}
onChange={()=>togglePublish(n)}
/>

</td>

<td style={{border:"1px solid #ddd",textAlign:"center"}}>

<button
onClick={()=>{
setEditNews({...n})
setShowEditModal(true)
}}
>
編集
</button>

<button
onClick={()=>deleteRow(n.id!)}
style={{marginLeft:"6px"}}
>
削除
</button>

</td>

</tr>

))}

</tbody>

</table>

<div style={{marginTop:"10px"}}>
選択 {selected.length} 件
</div>

{/* page */}

<div style={{display:"flex",justifyContent:"center",gap:"6px",marginTop:"15px"}}>

<button onClick={()=>page>1 && setPage(page-1)}>◀</button>

{pages.map(p=>(

<button key={p}
onClick={()=>setPage(p)}
style={{
padding:"4px 10px",
background: page===p ? "#7b5a36" : "#fff",
color: page===p ? "#fff" : "#000",
border:"1px solid #999"
}}
>
{p}
</button>

))}

<button onClick={()=>page<totalPage && setPage(page+1)}>▶</button>

</div>

{/* bottom */}

<div style={{
display:"flex",
justifyContent:"center",
gap:"12px",
marginTop:"20px"
}}>

<button
style={{
background:"#7b5a36",
color:"#fff",
padding:"8px 16px"
}}
onClick={()=>setShowAdd(true)}
>
ニュース投稿
</button>

<button
style={{
background:"#b00020",
color:"#fff",
padding:"8px 16px"
}}
onClick={bulkDelete}
>
一括削除
</button>

</div>

{/* 画像モーダル */}

{showImageModal && (

<div style={{
position:"fixed",
top:0,
left:0,
width:"100%",
height:"100%",
background:"rgba(0,0,0,0.4)",
display:"flex",
alignItems:"center",
justifyContent:"center"
}}>

<div style={{
background:"#fff",
padding:"20px",
borderRadius:"8px",
width:"420px",
textAlign:"center"
}}>

<img src={modalImage}
style={{
maxWidth:"100%",
maxHeight:"320px"
}}
/>

<div style={{marginTop:"15px"}}>
<button onClick={()=>setShowImageModal(false)}>閉じる</button>
</div>

</div>

</div>

)}

{/* 投稿モーダル */}

{showAdd && (

<div style={{
position:"fixed",
top:0,
left:0,
width:"100%",
height:"100%",
background:"rgba(0,0,0,0.4)",
display:"flex",
alignItems:"center",
justifyContent:"center"
}}>

<div style={{
background:"#fff",
padding:"25px",
borderRadius:"8px",
width:"420px"
}}>

<h3 style={{textAlign:"center", marginBottom:"15px"}}>
  ニュース投稿
</h3>

<label>タイトル</label>
<input
value={newNews.title}
onChange={(e)=>setNewNews({...newNews,title:e.target.value})}
style={{width:"100%"}}
/>

<label>本文</label>
<textarea
value={newNews.body}
onChange={(e)=>setNewNews({...newNews,body:e.target.value})}
style={{width:"100%",height:"120px"}}
/>

<div style={{marginTop:"10px"}}>

<label>画像</label>

<input
  type="file"
  accept="image/*"
  onChange={(e)=>{

    const file = e.target.files?.[0]

    if(!file) return

    setNewImageFile(file)

    // ★ここが重要（サムネ生成）
    setPreviewAdd(URL.createObjectURL(file))

  }}
  style={{display:"block", marginTop:"4px"}}
/>

{previewAdd && (

<img
  src={previewAdd}
  style={{
    marginTop:"10px",
    width:"140px",
    height:"140px",
    objectFit:"cover",
    borderRadius:"8px",
    border:"1px solid #ccc"
  }}
/>

)}

</div>

<div style={{marginTop:"10px"}}>

<label>公開</label>

<select
  value={newNews.isPublished ? "true" : "false"}
  onChange={(e)=>setNewNews({
    ...newNews,
    isPublished: e.target.value === "true"
  })}
  style={{display:"block", width:"100%", marginTop:"4px"}}
>
  <option value="true">公開</option>
  <option value="false">非公開</option>
</select>

</div>

<div style={{
marginTop:"20px",
display:"flex",
justifyContent:"space-between"
}}>

<button onClick={()=>setShowAdd(false)}>
キャンセル
</button>

<button onClick={addNews}>
投稿
</button>

</div>

</div>

</div>

)}

{/* 編集モーダル */}

{showEditModal && editNews && (

<div style={{
position:"fixed",
top:0,
left:0,
width:"100%",
height:"100%",
background:"rgba(0,0,0,0.4)",
display:"flex",
alignItems:"center",
justifyContent:"center"
}}>

<div style={{
background:"#fff",
padding:"25px",
borderRadius:"8px",
width:"600px"
}}>

<h3>ニュース編集</h3>

<label>タイトル</label>

<input
value={editNews.title}
onChange={(e)=>setEditNews({...editNews,title:e.target.value})}
style={{width:"100%"}}
/>

<label style={{marginTop:"10px"}}>本文</label>

<textarea
value={editNews.body}
onChange={(e)=>setEditNews({...editNews,body:e.target.value})}
style={{width:"100%",height:"120px"}}
/>

<label style={{marginTop:"10px"}}>画像変更</label>

<input
  type="file"
  accept="image/*"
  onChange={(e)=>{

    if(!e.target.files) return

    const file = e.target.files[0]

    setEditImage(file)
    setPreview(URL.createObjectURL(file))

  }}
/>

{preview && (

<img
  src={preview}
  style={{
    marginTop:"10px",
    width:"140px",
    height:"140px",
    objectFit:"cover",
    borderRadius:"8px",
    border:"1px solid #ccc"
  }}
/>

)}

<label style={{marginTop:"10px"}}>

<input
type="checkbox"
checked={editNews.isPublished}
onChange={(e)=>setEditNews({
...editNews,
isPublished:e.target.checked
})}
/>

公開する

</label>

<div style={{
marginTop:"20px",
display:"flex",
justifyContent:"space-between"
}}>

<button onClick={()=>setShowEditModal(false)}>
キャンセル
</button>

<button onClick={saveEdit}>
保存
</button>

</div>

</div>

</div>

)}

</div>

</AuthGuard>

)

}