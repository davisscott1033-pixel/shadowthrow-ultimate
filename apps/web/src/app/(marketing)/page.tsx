import Link from 'next/link'
export default function Page(){return (<main className="container py-10">
  <h1 className="text-4xl font-bold">ShadowThrow</h1><p className="text-slate-300">Instant, fair RPS.</p>
  <div className="flex gap-3 mt-6"><Link className="px-4 py-2 bg-white text-slate-900 rounded" href="/watch-now">Watch Now</Link><Link className="px-4 py-2 bg-slate-800 rounded" href="/viewer/demo">Try Demo Viewer</Link></div>
</main>)}