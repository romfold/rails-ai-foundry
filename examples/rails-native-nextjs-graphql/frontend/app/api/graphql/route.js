export async function POST(request) {
  const authorization = request.headers.get('authorization') || '';
  if (!['Bearer demo-a','Bearer demo-b'].includes(authorization)) {
    return Response.json({error:'Unauthorized'}, {status:401});
  }
  try {
    const body = await request.json();
    if (JSON.stringify(body).length > 16000) return Response.json({error:'Request too large'}, {status:413});
    const upstream = await fetch(`${process.env.RAILS_API_URL || 'http://127.0.0.1:3000'}/graphql`, {
      method:'POST',headers:{'Content-Type':'application/json',authorization},body:JSON.stringify(body),
      cache:'no-store',signal:AbortSignal.timeout(5000)
    });
    return new Response(await upstream.text(), {status:upstream.status,headers:{'Content-Type':'application/json','Cache-Control':'no-store'}});
  } catch { return Response.json({error:'Rails directory unavailable'}, {status:503}); }
}
