const { chromium } = require('playwright');
const assert = require('node:assert/strict');
(async()=>{
 const browser=await chromium.launch({headless:true});
 for(const width of [375,390,430]) {
  const page=await browser.newPage({viewport:{width,height:844},isMobile:true,hasTouch:true});
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('http://localhost:8000/index.html');
  assert(await page.locator('body.dark').count(), 'Dark mode must be default');
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Page must fit mobile width');
  for(const id of ['expenses','perdiem','mileage','payback','insights','calendar','concur','overview']){
   await page.locator(`[data-screen="${id}"]`).click();
   assert(await page.locator(`#${id}.active`).count());
   assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),`${id} overflows at ${width}`);
  }
  await page.locator('#themeBtn').click();await page.reload();
  assert.equal(await page.locator('body.dark').count(),0,'Theme persists');
  await page.locator('[data-screen="expenses"]').click();
  const f=page.locator('#expenseForm');
  await f.locator('[name="date"]').fill('2026-01-01');
  await f.locator('[name="name"]').fill('Synthetic test purchase');
  await f.locator('[name="amount"]').fill('12.34');
  await f.locator('[name="method"]').selectOption({label:'Other credit card'});
  await f.locator('button[type="submit"], button:not([type])').last().click();
  await page.reload();await page.locator('[data-screen="expenses"]').click();
  assert(await page.locator('#allExpenses').innerText().then(t=>t.includes('Synthetic test purchase')),'Records persist locally');
  assert.deepEqual(errors,[]);
  await page.close();
 }
 await browser.close();console.log('Mobile checks passed: 375, 390, 430 pixels, navigation, themes, local persistence');
})().catch(e=>{console.error(e);process.exit(1)});
