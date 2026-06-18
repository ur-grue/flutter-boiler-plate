# Legal pages — automated hosting

This folder holds the app's hosted legal pages so the App Store / Play **"privacy URL"**
exists without you standing up a website by hand.

## How it flows

1. **`/legal`** generates the pages and writes them here:
   - `docs/legal/privacy.html`
   - `docs/legal/terms.html`

   (Self-contained static HTML — no build step, no JS.)

2. **`bash scripts/publish-legal.sh`** publishes them via **GitHub Pages using the
   `docs/` folder source** on the default branch (no `gh-pages` branch). If the GitHub
   CLI is installed it best-effort enables Pages for you; otherwise enable it once under
   **Settings ▸ Pages ▸ Source = "Deploy from a branch" ▸ /docs**. The script prints the
   resulting URLs.

3. The resulting URL pattern is:

   ```
   https://<owner>.github.io/<repo>/legal/privacy.html
   https://<owner>.github.io/<repo>/legal/terms.html
   ```

   The **privacy URL** goes into the store metadata (`fastlane/metadata/{ios,android}/<locale>/`)
   and both URLs go into the in-app legal links via `PRIVACY_URL` / `TERMS_URL` in your
   `dart_define.*.json` (read by `AppConfig`). `/legal` wires all of this for you.

## Don't forget to commit + push

GitHub Pages only serves what's on the branch, so:

```bash
git add docs/legal && git commit -m "Add legal pages" && git push
```

## Private-repo caveat (read this)

**GitHub Pages on a PRIVATE repo requires a paid plan.** If your repo is private and
you're on the free plan, you have two honest options:

- Make the repo **public**, or
- **Host anywhere else** — drop `privacy.html` + `terms.html` on Netlify, Vercel, S3,
  Cloudflare Pages, or your own site, and use that URL in the store metadata + app config.

Either way the only requirement is a stable public URL for the two files.
