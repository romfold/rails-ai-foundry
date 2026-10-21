// Playwright CLI run-code snippet; run after signing in and submitting "hello".
async (page) => {
  const origin = new URL(page.url()).origin;
  const observations = [];
  const ids = () => page.locator('#search-results .message').evaluateAll(nodes => nodes.map(node => node.id));
  const check = (name, actual, expected) => {
    if (JSON.stringify(actual) !== JSON.stringify(expected)) throw new Error(`${name}: ${JSON.stringify(actual)}`);
    observations.push({ name, actual });
  };
  check('ordinary match', await ids(), ['message_ordinary']);
  await page.locator('#search-results .message--formatted').waitFor();
  check('own-message formatting', await page.locator('#search-results .message--me').count(), 1);
  await page.getByRole('button', { name: 'Clear search field', exact: true }).click();
  await page.waitForURL(`${origin}/searches`);
  check('clear field', await page.getByRole('searchbox').inputValue(), '');
  check('empty search', await ids(), []);
  await page.locator('a[href="/searches?q=hello"]:visible').click();
  await page.waitForURL(`${origin}/searches?q=hello`);
  check('history navigation', await ids(), ['message_ordinary']);
  await page.getByRole('link', { name: 'Exit search', exact: true }).click();
  await page.waitForURL(`${origin}/rooms/1`);
  check('return to room', new URL(page.url()).pathname, '/rooms/1');

  for (const [query, expected] of [
    ['absentword', []], ['hello!!!', ['message_ordinary']],
    ['salt AND', ['message_ordinary']], ['AND', ['message_ordinary']],
    ['OR', []], ['NOT', []], ['privateword', []],
    ['revocableword', ['message_revocable']], ['beforeword', ['message_lifecycle']]
  ]) {
    const response = await page.goto(`${origin}/searches?q=${encodeURIComponent(query)}`);
    check(`${query} HTTP`, response.status(), 200);
    check(query, await ids(), expected);
  }
  await page.goto(`${origin}/searches?q=windowword`);
  check('newest 100 in existing order', await ids(), Array.from({ length: 100 }, (_, i) => `message_window${i + 1}`));
  await page.waitForFunction(() => document.querySelectorAll('#search-results .message--formatted').length === 100);
  check('all results formatted', await page.locator('#search-results .message--formatted').count(), 100);
  check('private history hidden', await page.locator('a[href="/searches?q=privatehistory"]').count(), 0);
  return { browser: page.context().browser().version(), observations };
}
