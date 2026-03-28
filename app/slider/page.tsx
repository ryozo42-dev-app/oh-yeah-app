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

const snap = await getDocs(collection(db,"slider_images"))

const list = snap.docs.map(d=>{

let url = d.data().imageUrl || ""

// 🔥 トークン削除（これが原因）
if(url.includes("&token=")){
url = url.split("&token=")[0]
}

return{
id:d.id,
imageUrl:url
}

})

setSlides(list)

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
background:"#