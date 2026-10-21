"use client";
import {useState} from 'react';
export default function Page() {
  const [ids,setIds] = useState(''), [identity,setIdentity] = useState('demo-a'), [result,setResult] = useState('');
  async function submit(event) {
    event.preventDefault(); setResult('Loading…');
    try {
      const response = await fetch('/api/graphql', {method:'POST', headers:{'Content-Type':'application/json',Authorization:`Bearer ${identity}`},body:JSON.stringify({query:'query($ids:[ID!]!){ people(ids:$ids){ id name manager { name } } }',variables:{ids:ids.split(',').map(id=>id.trim()).filter(Boolean)}})});
      setResult(JSON.stringify(await response.json(),null,2));
    } catch { setResult('Directory unavailable. Try again.'); }
  }
  return <main style={{maxWidth:720,margin:'3rem auto',fontFamily:'system-ui'}}><h1>Rails directory</h1>
    <p>Next.js delivers the interface. Rails owns authorization, GraphQL and PostgreSQL records.</p>
    <form onSubmit={submit}><label>Demo identity <select value={identity} onChange={e=>setIdentity(e.target.value)}><option>demo-a</option><option>demo-b</option></select></label><p><label>Person IDs <input value={ids} onChange={e=>setIds(e.target.value)} placeholder="1, 2, 3"/></label></p><button>Load directory</button></form>
    <pre aria-live="polite">{result}</pre></main>;
}
