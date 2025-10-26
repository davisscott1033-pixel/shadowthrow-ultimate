import './globals.css'
export const metadata = { title: 'ShadowThrow', description: 'Fair, animated commit→reveal RPS' }
export default function RootLayout({ children }){
  return (<html lang="en"><body className="bg-slate-950 text-slate-100">{children}</body></html>)
}