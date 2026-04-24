const { test, expect } = require('@playwright/test');

const base = process.env.BASE_URL || 'http://127.0.0.1:8788';
const paths = (process.env.PREVIEW_PATHS || '/README/,/docs/ui/README/,/docs/tech/technical-proposal/').split(',').filter(Boolean);

test('landing exposes complete document entrypoints', async ({ page }) => {
  await page.goto(`${base}/`, { waitUntil: 'networkidle' });
  await expect(page.locator('text=完整版本文档')).toHaveCount(1);
  await expect(page.locator('a[href="/docs/tech/technical-proposal.md#preview"]')).toHaveCount(1);
  await expect(page.locator('a[href="/docs/tech/technical-proposal/"]')).toHaveCount(1);
});

for (const path of paths) {
  test(`markdown preview renders ${path}`, async ({ page }) => {
    await page.goto(`${base}${path}`, { waitUntil: 'networkidle' });
    await expect(page.locator('.mdDoc')).toHaveCount(1);
    await expect(page.locator('.mdToc strong')).toContainText('文档目录');
    await expect(page.locator('.mdMeta a')).toHaveCount(1);
    await expect(page).toHaveTitle(/文档预览/);
  });
}
