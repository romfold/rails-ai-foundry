// Run in the signed-in Review One browser. CSRF and normal authentication remain enabled.
async (page) => {
  const origin = new URL(page.url()).origin;
  const observations = [];
  const check = (name, actual, expected) => {
    if (JSON.stringify(actual) !== JSON.stringify(expected)) throw new Error(`${name}: ${JSON.stringify(actual)}`);
    observations.push({ name, actual });
  };
  const history = () => page.locator('.searches__recents a').evaluateAll(nodes => nodes.map(node => new URL(node.href).searchParams.get('q')));
  await page.goto(`${origin}/searches`);
  const request = async (method, path, values) => page.evaluate(async ({ method, path, values }) => {
    const response = await fetch(path, {
      method, credentials: 'same-origin',
      headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/x-www-form-urlencoded', Accept: 'text/html' },
      body: new URLSearchParams(values)
    });
    return { status: response.status, path: new URL(response.url).pathname };
  }, { method, path, values });
  check('ownership injection POST', await request('POST', '/searches', { q: 'ownedword', user_id: '2' }), { status: 200, path: '/searches' });
  await page.reload();
  check('injected request belongs to signed-in user', (await history())[0], 'ownedword');
  for (let index = 0; index < 11; index++) {
    check(`history POST ${index}`, (await request('POST', '/searches', { q: `term${index}` })).status, 200);
  }
  await page.reload();
  check('ten most recent queries', await history(), Array.from({ length: 10 }, (_, i) => `term${10 - i}`));
  await request('POST', '/searches', { q: 'term1' });
  await page.reload();
  check('repeat changes recency without duplication', await history(), ['term1', ...Array.from({ length: 9 }, (_, i) => `term${10 - i}`)]);
  return { observations };
}
