const { test, expect } = require('@playwright/test');

const base = process.env.BASE_URL || 'http://127.0.0.1:8788';
const platforms = ['wechat', 'android', 'ios'];
const routes = [
  'home',
  'records',
  'inr',
  'me',
  'login',
  'inr-settings',
  'inr-methods',
  'test-settings',
  'dose-settings',
  'after-dose-rule',
  'notifications',
  'account',
  'profile',
  'help',
];

test.describe('static prototype route coverage', () => {
  test.use({ viewport: { width: 390, height: 844 }, isMobile: true, deviceScaleFactor: 3 });

  test('root landing links to UI and Docs portals', async ({ page }) => {
    await page.goto(`${base}/`, { waitUntil: 'networkidle' });
    await expect(page.locator('.portalLanding')).toContainText('统一入口');
    await expect(page.locator('.portalLanding')).toContainText('UI 原型');
    await expect(page.locator('.portalLanding')).toContainText('Docs 文档');
    await expect(page.locator('a[href="/ui/"]')).toHaveCount(1);
    await expect(page.locator('a[href="/docs/"]')).toHaveCount(1);
  });

  test('ui and docs portal routes render', async ({ page }) => {
    await page.goto(`${base}/ui/`, { waitUntil: 'networkidle' });
    await expect(page.locator('.landing')).toContainText('抗凝小助手 UI 原型入口');

    await page.goto(`${base}/docs/`, { waitUntil: 'networkidle' });
    await expect(page.locator('.docsLanding')).toContainText('Docs 文档中心');
    await expect(page.locator('.docsIndexGrid')).toContainText('architecture report');
  });

  for (const prefix of ['', '/ui']) {
    for (const platform of platforms) {
      for (const route of routes) {
        test(`${prefix || 'legacy'}/${platform}/${route} renders centralized prototype shell`, async ({ page }) => {
          await page.goto(`${base}${prefix}/${platform}/${route}/`, { waitUntil: 'networkidle' });
          await expect(page.locator('.app-shell')).toHaveCount(1);
          await expect(page.locator('.device')).toHaveClass(new RegExp(platform));
        });
      }
    }
  }
});
