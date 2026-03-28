"use client"

import AuthGuard from "../../components/AuthGuard"
import { useEffect,useState } from "react"
import {
collection,
getDocs,
doc,
setDoc
} from "firebase/firestore"
import {
ref,
uploadBytes,
getDownloadURL
} from "firebase/storage"
import { db,storage } from "../../lib/firebase"

type Slide={
id:string
imageUrl:string
}

export default function Slider(){

const [slides,setSlides] = useState<Slide[]>([])
const [showModal,setShowModal] = useState(false)
const [currentSlide,setCurrentSlide] = useState<Slide|null>(null)
const [newImage,setNewImage] = useState<File | null>(null)
const [preview,setPreview] = useState("")

useEffect(()=>{

const load = async()=>{

try{

// 🔥 デバッグログ
const snap = await getDocs(collection(db,"slider_images"))
console.log("slider count:",snap.docs.length)
console.log("slider data:",snap.docs.map(d=>d.data()))

// 🔥 強制ダミー表示（データ来てるか確認）
if(snap.docs.length === 0){
setSlides([
{ id:"test1", imageUrl:"https://via.placeholder.com/300x180" },
{ id:"test2", imageUrl:"https://via.placeholder.com/300x180" }
])
return
}

const list = snap.docs.map(d=>({
id:d.id,
imageUrl:d.data().imageUrl || ""
}))

setSlides(list)

}catch(e){
console.log(e)

// 🔥 エラー時もダミー表示
setSlides([
{ id:"err1", imageUrl:"https://via.placeholder.com/300x180" }
])

}

}

load()

},[])

const handleFile = (e:any)=>{

const file = e.target.files?.[0]
if(!file) return

if(!file.type.includes("jpeg") && !file.type.includes("jpg")){
alert("JPGのみ")
return
}

setNewImage(file)
setPreview(URL.createObjectURL(file))

}

const saveImage = async()=>{

if(!newImage || !currentSlide) return

try{

const storageRef = ref(storage,`slider/${currentSlide.id}.jpg`)

await uploadBytes(storageRef,newImage)

const url = await getDownloadURL(storageRef)

await setDoc(doc(db,"slider_images",currentSlide.id),{
imageUrl:url,
isActive:true
})

setSlides(
slides.map(s=>
s.id===currentSlide.id
? {...s,imageUrl:url}
: s
)
)

setShowModal(false)

}catch(e){
console.log(e)
alert("アップロード失敗")
}

}

return(

<AuthGuard>

<div style={{padding:"30px"}}>

<h1 style={{textAlign:"center"}}>Slider管理</h1>

<div
style={{
maxWidth:"1000px",
margin:"0 auto",
display:"grid",
gridTemplateColumns:"repeat(3,260px)",
columnGap:"60px",
rowGap:"40px",
justifyContent:"center",
marginTop:"30px"
}}
>

{slides.map((s)=>(

<div key={s.id} style={{textAlign:"center"}}>

<img
src={s.imageUrl}
style={{
width:"260px",
aspectRatio:"16 / 9",
objectFit:"cover",
borderRadius:"8px",
background:"#eee"
}}
/>

<button
onClick={()=>{
setCurrentSlide(s)
setPreview("")
setNewImage(null)
setShowModal(true)
}}
style={{
marginTop:"12px",
background:"#7b5a36",
color:"#fff",
padding:"8px 16px",
borderRadius:"6px"
}}
>
画像変更
</button>

</div>

))}

</div>

{showModal && currentSlide && (

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
width:"420px",
textAlign:"center"
}}>

<h3>画像変更</h3>

<img
src={currentSlide.imageUrl}
style={{
width:"100%",
aspectRatio:"16 / 9",
objectFit:"cover"
}}
/>

{preview && (
<img
src={preview}
style={{
width:"100%",
aspectRatio:"16 / 9",
objectFit:"cover",
marginTop:"10px"
}}
/>
)}

<input type="file" onChange={handleFile}/>

<div style={{
marginTop:"20px",
display:"flex",
justifyContent:"space-between"
}}>

<button onClick={()=>setShowModal(false)}>キャンセル</button>

<button onClick={saveImage}>保存</button>

</div>

</div>

</div>

)}

</div>

</AuthGuard>

)

}