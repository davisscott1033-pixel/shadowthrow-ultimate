'use client'
import { useEffect, useRef, useState } from 'react'
const C=['rock','paper','scissors'] as const; type Choice = typeof C[number]
function d(a:Choice,b:Choice){ if(a===b)return 0; if((a==='rock'&&b==='scissors')||(a==='paper'&&b==='rock')||(a==='scissors'&&b==='paper'))return 1; return 2 }
export default function Demo(){const [t,setT]=useState(3),[rev,setRev]=useState(false),[a,setA]=useState<Choice>('rock'),[b,setB]=useState<Choice>('paper'),[o,setO]=useState<number|null>(null); const ref=useRef<any>(null)
useEffect(()=>{ setA(C[Math.floor(Math.random()*3)]); setB(C[Math.floor(Math.random()*3)]); setO(null); setRev(false); setT(3);
ref.current=setInterval(()=>setT(v=>{ if(v<=1){clearInterval(ref.current); setRev(true); setO(d(a,b)); return 0 } return v-1 }), 1000); return ()=>clearInterval(ref.current)},[])
return (<main className="container py-10 space-y-6"><h1 className="text-2xl font-semibold">Demo Viewer</h1><div className="grid md:grid-cols-3 gap-6 items-center">
<div className="rounded bg-slate-900 p-6 text-center"><div className="text-sm text-slate-400 mb-2">Player A</div><div className="text-3xl">{rev?a:'❓'}</div></div>
<div className="rounded bg-slate-900 p-6 text-center">{!rev?<div className="text-5xl font-bold">{t}</div>:<div className="text-3xl">Reveal!</div>}</div>
<div className="rounded bg-slate-900 p-6 text-center"><div className="text-sm text-slate-400 mb-2">Player B</div><div className="text-3xl">{rev?b:'❓'}</div></div></div>
{o!==null && <div className="rounded bg-slate-800 p-4 text-center">{o===0?'Draw':o===1?'A wins':'B wins'}</div>}</main>)}