import { createClient } from '@supabase/supabase-js'
const url=process.env.NEXT_PUBLIC_SUPABASE_URL!, key=process.env.SUPABASE_SERVICE_ROLE_KEY!
if(!url||!key){ console.error('Set Supabase URL and SERVICE ROLE KEY in .env.local'); process.exit(1) }
const s = createClient(url, key); console.log('Seeding demo match…'); await s.from('matches').insert({ state: 'active' }); console.log('Done.')