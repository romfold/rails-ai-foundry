// Same criterion for healthy and deliberately faulty copies; do not invert it for the fault.
async (page) => {
  const origin = new URL(page.url()).origin;
  const response = await page.goto(`${origin}/searches?q=privateword`);
  if (response.status() !== 200) throw new Error('Visibility check did not reach Search');
  const ids = await page.locator('#search-results .message').evaluateAll(nodes => nodes.map(node => node.id));
  if (ids.length) throw new Error(`Private-message disclosure: ${JSON.stringify(ids)}`);
  return { status: 200, privateMessageIds: ids };
}
