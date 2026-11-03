'use client';
import QRCode from 'qrcode';
import {PDFDocument} from 'pdf-lib';
import type {Config} from './beleg';
import {cardSize} from './card-shapes';
const colors:Record<string,[string,string,string]>={pink:['#f9e6e8','#733244','#b18b4b'],black:['#201b20','#f5dfb4','#c4a163'],burgundy:['#681f37','#fff1e9','#d7b674'],white:['#fffefa','#523a43','#b08b4d']};
function lines(ctx:CanvasRenderingContext2D,text:string,width:number){const out:string[]=[];let line='';for(const word of text.split(/\s+/)){const t=line?line+' '+word:word;if(ctx.measureText(t).width>width&&line){out.push(line);line=word;}else line=t;}if(line)out.push(line);return out;}
export async function cardPng(config:Config,url:string){
 const size=cardSize(config.cardShape),w=size.width,h=size.height,c=document.createElement('canvas');c.width=w;c.height=h;const x=c.getContext('2d')!,[bg,ink,gold]=colors[config.design]||colors.pink;
 const outline=new Path2D(),m=Math.min(w,h)*.025;
 if(size.id==='circle')outline.ellipse(w/2,h/2,w/2-m,h/2-m,0,0,Math.PI*2);
 else if(size.id==='heart'){outline.moveTo(w/2,h*.96);outline.bezierCurveTo(-w*.24,h*.43,w*.05,-h*.20,w/2,h*.15);outline.bezierCurveTo(w*.95,-h*.20,w*1.24,h*.43,w/2,h*.96);outline.closePath();}
 else if(size.id==='arch'){outline.moveTo(m,h-m);outline.lineTo(m,h*.30);outline.bezierCurveTo(m,-h*.08,w-m,-h*.08,w-m,h*.30);outline.lineTo(w-m,h-m);outline.closePath();}
 else if(size.id==='tag'){outline.moveTo(w*.18,m);outline.lineTo(w*.82,m);outline.lineTo(w-m,h*.12);outline.lineTo(w-m,h-m);outline.lineTo(m,h-m);outline.lineTo(m,h*.12);outline.closePath();}
 else outline.roundRect(m,m,w-2*m,h-2*m,Math.min(w,h)*.035);
 x.save();x.clip(outline);x.fillStyle=bg;x.fillRect(0,0,w,h);x.strokeStyle=gold;x.lineWidth=5;x.stroke(outline);
 if(size.id==='tag'){x.beginPath();x.arc(w/2,h*.055,w*.018,0,Math.PI*2);x.stroke();}
 const compact=['circle','heart','landscape','square'].includes(size.id),safe=size.id==='heart'?.64: size.id==='circle'?.72:.82;
 x.globalAlpha=.16;x.fillStyle=gold;for(const [cx,cy] of [[w*.12,h*.24],[w*.88,h*.24],[w*.12,h*.78],[w*.88,h*.78]])for(let a=0;a<5;a++){x.beginPath();x.ellipse(cx+Math.cos(a*1.256)*w*.025,cy+Math.sin(a*1.256)*w*.025,w*.035,w*.016,a*1.256,0,Math.PI*2);x.fill();}x.globalAlpha=1;
 x.textAlign='center';x.fillStyle=ink;x.font=Math.round(w*.024)+'px Georgia';x.fillText('БЭЛЭГ  /  HANDMADE',w/2,h*.17);
 x.font='italic '+Math.round(Math.min(w*.044,h*.037))+'px Georgia';x.fillText('Сэтгэлд үлдэх бэлэг',w/2,h*.24);
 x.font=Math.round(Math.min(w*.034,h*.029))+'px Georgia';lines(x,(config.recipientName||config.recipient)+' танаа',w*safe).slice(0,2).forEach((s,i)=>x.fillText(s,w/2,h*.30+i*h*.035));
 let fs=Math.round(Math.min(w*.026,h*.025));x.font=fs+'px sans-serif';let msg=lines(x,config.text||'Танд зориулсан нандин үгсийг сонсоорой.',w*safe);const maxLines=compact?5:6;while(msg.length>maxLines&&fs>Math.min(w,h)*.016){fs--;x.font=fs+'px sans-serif';msg=lines(x,config.text,w*safe);}
 if(msg.length>maxLines)msg=[...msg.slice(0,maxLines-1),msg[maxLines-1]+'…'];
 msg.forEach((s,i)=>x.fillText(s,w/2,h*.37+i*h*.031));
 const qr=Math.floor(Math.min(w*(size.id==='heart'?.30:.43),h*.25)),qx=(w-qr)/2,qy=h*.55;
 const image=new Image();image.src=await QRCode.toDataURL(url,{width:qr,margin:4,errorCorrectionLevel:'M',color:{dark:'#241b20',light:'#ffffff'}});await image.decode();x.fillStyle='white';x.fillRect(qx-8,qy-8,qr+16,qr+16);x.drawImage(image,qx,qy,qr,qr);
 x.fillStyle=ink;x.font=Math.round(Math.min(w*.022,h*.02))+'px sans-serif';x.fillText('QR кодыг камераар уншуулаарай',w/2,h*.84);
 x.font='italic '+Math.round(Math.min(w*.024,h*.021))+'px Georgia';const sign=config.sender?'Хайр шингээн, '+config.sender:'Сэтгэл шингээн';lines(x,sign,w*(size.id==='heart'?.35:.7)).slice(0,2).forEach((s,i)=>x.fillText(s,w/2,h*.88+i*h*.026));x.restore();return c.toDataURL('image/png');
}
export async function downloadCard(config:Config,url:string,format:'png'|'pdf',name:string){const data=await cardPng(config,url),size=cardSize(config.cardShape);let blob:Blob;if(format==='pdf'){const pdf=await PDFDocument.create(),page=pdf.addPage([size.width/300*72,size.height/300*72]);const img=await pdf.embedPng(data);page.drawImage(img,{x:0,y:0,width:page.getWidth(),height:page.getHeight()});blob=new Blob([new Uint8Array(await pdf.save())],{type:'application/pdf'});}else blob=await(await fetch(data)).blob();const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='BELEG-'+name+'-'+size.id+'.'+format;a.click();setTimeout(()=>URL.revokeObjectURL(a.href),10000);}
