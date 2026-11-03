import type { Metadata } from 'next';
import './globals.css';
import InstallApp from './install-app';
export const viewport={themeColor:'#842d50'};
export const metadata:Metadata={title:'БЭЛЭГ Handmade | Сэтгэл шингэсэн гар урлал',description:'БЭЛЭГ Handmade — гар урлалын цүнх, QR дуут карт, сэтгэл шингэсэн бэлгийн багц.',referrer:'no-referrer',robots:{index:false,follow:false},manifest:'/manifest.webmanifest',appleWebApp:{capable:true,statusBarStyle:'default',title:'БЭЛЭГ'},icons:{icon:'/favicon.svg',apple:'/icons/icon-192.png'}};
export default function RootLayout({children}:Readonly<{children:React.ReactNode}>){return <html lang="mn"><body>{children}<InstallApp/></body></html>;}
