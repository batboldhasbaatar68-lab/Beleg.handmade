import type { Metadata } from 'next';
import './globals.css';
export const metadata:Metadata={title:'БЭЛЭГ Handmade | Сэтгэл шингэсэн гар урлал',description:'БЭЛЭГ Handmade — гар урлалын цүнх, QR дуут карт, сэтгэл шингэсэн бэлгийн багц.',referrer:'no-referrer',robots:{index:false,follow:false},icons:{icon:'/favicon.svg'}};
export default function RootLayout({children}:Readonly<{children:React.ReactNode}>){return <html lang="mn"><body>{children}</body></html>;}
