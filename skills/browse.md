---
name: browse
description: >
  Real Chromium browser automation via Playwright. Accepts a URL and a task
  description, returns structured text output or saves a screenshot. Use when user
  says "browse", "open this URL", "scrape", "automate this page", "check this
  visually", or "go to [URL]".
user-invocable: true
argument-hint: '"[URL] [task description]" — e.g. "https://example.com get the pricing table"'
---

# Browse

Real browser. Real page. No hallucinated content.

## When to Trigger

- "browse [URL]"
- "open this URL"
- "scrape [URL]"
- "automate this page"
- "check this visually"
- "go to [URL] and [do something]"

## Pre-Flight

Verify runtime is available:
```bash
bunx playwright --version
```
If this fails, tell the user: "Playwright is not installed. Run: `bunx playwright install chromium`"

## Process

### Phase 1: Parse the request

Extract from the argument or user message:
- **URL** — the page to open (must start with `http://` or `https://`)
- **Task** — what to do on the page (read, scrape, screenshot, find element, etc.)

If URL is missing, ask: "What URL should I open?"
If task is missing, ask: "What should I do on that page?"

### Phase 2: Run the browser task

Write a temporary Playwright script to `.tmp/browse-task.js` and run it via `bunx`:

```javascript
// .tmp/browse-task.js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto('{URL}', { waitUntil: 'domcontentloaded', timeout: 30000 });

  // Task-specific logic goes here based on the request:
  // - For "get text": const text = await page.innerText('body'); console.log(text);
  // - For "screenshot": await page.screenshot({ path: '.tmp/browse-screenshot.png' });
  // - For "find X": const el = await page.$eval('{selector}', el => el.textContent);

  await browser.close();
})();
```

Run:
```bash
cd .tmp && ~/.bun/bin/bun add playwright --silent 2>/dev/null; ~/.bun/bin/bun run browse-task.js
```

**HARD RULE: Never write a script that submits a form, clicks a purchase/delete/send button, or posts data without explicit per-action approval from Roi.**

### Phase 3: Output

Return the result in a clean format:

```
## Browse Result — {URL}
**Task:** {what was requested}
**Date:** {today}

{Result text, table, or "Screenshot saved to .tmp/browse-screenshot.png"}
```

If the page fails to load, report: "Could not load {URL}. Error: {message}. Is the URL correct and accessible?"

## Edge Cases

- **Auth-required page** — Report: "This page requires login. I can't authenticate automatically. Try a public URL or log in manually and share the content."
- **JavaScript-heavy SPA** — Use `waitUntil: 'networkidle'` instead of `domcontentloaded` in the script
- **Screenshot requested** — Save to `.tmp/browse-screenshot.png` and report the path
- **URL with no protocol** — Prepend `https://` and proceed
