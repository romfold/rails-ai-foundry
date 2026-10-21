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
  const request = async (method, path, values) => {
    const csrf = await page.locator('meta[name="csrf-token"]').getAttribute('content');
    const response = await page.request.fetch(`${origin}${path}`, {
      method, form: values, headers: { 'X-CSRF-Token': csrf, Accept: 'text/html' }, maxRedirects: 0
    });
    return { status: response.status(), path: new URL(response.headers().location, origin).pathname };
  };
  await request('POST', '/searches', { q: 'mineagain' });
  check('ownership injection DELETE', await request('DELETE', '/searches/clear', { user_id: '2' }), { status: 302, path: '/searches' });
  await page.reload();
  check('injected clear affects own history', await history(), []);

  const context = await page.context().browser().newContext();
  try {
    const other = await context.newPage();
    await other.goto(`${origin}/searches`);
    await other.getByPlaceholder('Enter your email address').fill('two@example.test');
    await other.getByPlaceholder('Enter your password').fill('local-review-only');
    await other.getByRole('button', { name: 'Go', exact: true }).click();
    await other.waitForURL(`${origin}/searches`);
    check('other user history untouched', await other.locator('.searches__recents a').evaluateAll(nodes => nodes.map(node => new URL(node.href).searchParams.get('q'))), ['privatehistory']);
    await other.goto(`${origin}/searches?q=privateword`);
    check('owner can see private message', await other.locator('#search-results .message').evaluateAll(nodes => nodes.map(node => node.id)), ['message_secret']);
  } finally {
    await context.close();
  }
  return { observations };
}
