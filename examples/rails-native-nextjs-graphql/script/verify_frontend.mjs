import {spawn} from 'node:child_process';
import {once} from 'node:events';
import net from 'node:net';
import assert from 'node:assert/strict';
const pause = ms => new Promise(resolve=>setTimeout(resolve,ms));
async function freePort() {
  const server = net.createServer(); server.listen(0,'127.0.0.1'); await once(server,'listening');
  const port = server.address().port; await new Promise(resolve=>server.close(resolve)); return port;
}
function start(command,args,env) {
  console.log('Running:',command,...args);
  return spawn(command,args,{stdio:'inherit',env:{...process.env,...env}});
}
async function ready(url) {
  for(let count=0; count<150; count++) {
    try { if((await fetch(url)).ok) return; } catch {}
    await pause(200);
  }
  throw new Error(`Server did not become ready: ${url}`);
}
async function stop(child) {
  if(child.exitCode !== null || child.signalCode !== null) return;
  const ended = once(child,'exit'); child.kill('SIGTERM');
  const timer = setTimeout(()=>child.kill('SIGKILL'),5000);
  await ended; clearTimeout(timer);
}
const railsPort=await freePort(), nextPort=await freePort();
const rails=start('bin/rails',['server','-b','127.0.0.1','-p',String(railsPort)],{RAILS_ENV:'test'});
let frontend;
try {
  await ready(`http://127.0.0.1:${railsPort}/health`);
  frontend=start('node',['frontend/node_modules/next/dist/bin/next','start','frontend','-H','127.0.0.1','-p',String(nextPort)],{RAILS_API_URL:`http://127.0.0.1:${railsPort}`,NEXT_TELEMETRY_DISABLED:'1'});
  const base=`http://127.0.0.1:${nextPort}`; await ready(base);
  assert.match(await (await fetch(base)).text(),/Rails directory/);
  const send = authorization => fetch(`${base}/api/graphql`,{method:'POST',headers:{'Content-Type':'application/json',authorization},body:JSON.stringify({query:'{ people(ids: []) { name } }'})});
  assert.equal((await send('invalid')).status,401);
  const response=await send('Bearer demo-a'); assert.equal(response.status,200);
  assert.deepEqual(await response.json(),{data:{people:[]}});
  await stop(rails);
  assert.equal((await send('Bearer demo-a')).status,503);
  console.log('Next.js rendered and proxied authorized Rails GraphQL; unauthorized and unavailable-backend paths passed.');
} finally {
  if(frontend) await stop(frontend);
  await stop(rails);
}
