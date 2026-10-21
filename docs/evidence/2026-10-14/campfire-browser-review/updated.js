// Run after mutate.rb update, with the existing signed-in session.
async (page) => {
  const origin = new URL(page.url()).origin;
  const observations = [];
  for (const [query, expected] of [
    ['freshword', ['message_fresh']], ['beforeword', []],
    ['afterword', ['message_lifecycle']], ['revocableword', []], ['privateword', []]
  ]) {
    const response = await page.goto(`${origin}/searches?q=${query}`);
    const ids = await page.locator('#search-results .message').evaluateAll(nodes => nodes.map(node => node.id));
    if (response.status() !== 200 || JSON.stringify(ids) !== JSON.stringify(expected)) {
      throw new Error(`${query}: HTTP ${response.status()}, ${JSON.stringify(ids)}`);
    }
    observations.push({ query, status: response.status(), ids });
  }
  return { observations };
}
