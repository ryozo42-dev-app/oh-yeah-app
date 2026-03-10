"use client"

export default function Drinks(){

return(

<div style={{padding:"40px"}}>

<h1>ドリンク管理</h1>

<table
style={{
borderCollapse:"collapse",
width:"600px",
marginTop:"20px"
}}
>

<thead>

<tr>

<th style={{border:"1px solid #ccc",padding:"10px"}}>名前</th>
<th style={{border:"1px solid #ccc",padding:"10px"}}>英語名</th>
<th style={{border:"1px solid #ccc",padding:"10px"}}>価格</th>

</tr>

</thead>

<tbody>

<tr>

<td style={{border:"1px solid #ccc",padding:"10px"}}>ハイネケン</td>
<td style={{border:"1px solid #ccc",padding:"10px"}}>Heineken</td>
<td style={{border:"1px solid #ccc",padding:"10px"}}>¥650</td>

</tr>

</tbody>

</table>

</div>

)

}