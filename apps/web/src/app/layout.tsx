import './globals.css'
export const metadata = { title: 'ShadowThrow', description: 'Fair, animated commitâ†’reveal RPS' }
export default function RootLayout({ children }){
  return (<html lang="en"><body className="bg-slate-950 text-slate-100 bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100">{children}</body></html>)
}