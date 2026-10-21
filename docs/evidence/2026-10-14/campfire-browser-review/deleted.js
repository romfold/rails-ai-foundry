// Run after mutate.rb delete.
async (page) => {
  const origin = new URL(page.url()).origin;
  const observations = [];
  for (const query of ['freshword', 'beforeword', 'afterword']) {
    const response = await page.goto(`${origin}/searches?q=${query}`);
    const count = await page.locator('#search-results .message').count();
    if (response.status() !== 200 || count !== 0) throw new Error(`${query}: HTTP ${response.status()}, count ${count}`);
    observations.push({ query, status: response.status(), count });
  }
  return { observations };
}
