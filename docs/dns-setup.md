# DNS setup — thescaffoldrack.com → GitHub Pages

One-time DNS and GitHub Pages configuration to get `thescaffoldrack.com`
serving the Hugo site over HTTPS. This is the sequence that was verified
working on 2026-04-18; subtle ordering issues exist if steps are done in a
different order.

## Decision: apex, not www

Canonical URL is `https://thescaffoldrack.com/` (apex).
`www.thescaffoldrack.com` redirects to apex. GitHub Pages handles the
redirect automatically once both records are in place.

## Records to create

Apply these at the registrar (GoDaddy for `thescaffoldrack.com`).

### A records at the apex (@)

```
Type   Host   Value            TTL
A      @      185.199.108.153  1 Hour
A      @      185.199.109.153  1 Hour
A      @      185.199.110.153  1 Hour
A      @      185.199.111.153  1 Hour
```

All four are required for redundancy. These are GitHub Pages' current
IP addresses; check GitHub's documentation if doing this fresh a year
from now, as they have changed historically.

### AAAA records at the apex (IPv6)

```
Type   Host   Value                    TTL
AAAA   @      2606:50c0:8000::153      1 Hour
AAAA   @      2606:50c0:8001::153      1 Hour
AAAA   @      2606:50c0:8002::153      1 Hour
AAAA   @      2606:50c0:8003::153      1 Hour
```

### CNAME for www → apex

```
Type    Host   Value                   TTL
CNAME   www    scaffoldrack.github.io  1 Hour
```

Just the hostname — no `https://`, no path, no trailing dot.

## Sequence (order matters)

This is the order that was verified working. Following a different order
runs into known failure modes documented under "Gotchas" below.

### 1. Push the repo to GitHub

Including `static/CNAME` (contains `thescaffoldrack.com`) and the
`.github/workflows/deploy.yml` workflow. The workflow triggers on push
to `main` and on manual dispatch.

### 2. Enable GitHub Pages with Actions as the source

On first push the workflow **will fail** at `actions/configure-pages@v5`
with "Get Pages site failed. Please verify that the repository has Pages
enabled." This is expected — Pages isn't configured yet and the action
doesn't auto-enable.

Fix: Settings → Pages → Source: **GitHub Actions**. Save.

Then re-run the failed workflow from the Actions tab. It will succeed
this time and the site goes live at the default Pages URL
(`https://scaffoldrack.github.io/blog/`).

### 3. (Optional but recommended) Verify the domain at the org level

Organizations → scaffoldrack → Settings → Security → Verified and
approved domains → Add a domain → `thescaffoldrack.com`. GitHub gives a
TXT record; add it at the registrar; click Verify.

This binds `thescaffoldrack.com` to the `scaffoldrack` org exclusively,
preventing another GitHub user from claiming the domain if we ever
delete the repo while DNS still points here. Once verified, the TXT
record can stay in place permanently (or be removed — verification
persists either way).

### 4. Apply DNS records at the registrar

Remove GoDaddy's default parked A record and any default wildcard CNAME
first. Editing the default records sometimes leaves stale entries —
delete and re-add is cleaner. Then apply the records from the tables
above.

### 5. Verify DNS propagation

```sh
dig +short thescaffoldrack.com A
dig +short thescaffoldrack.com AAAA
dig +short www.thescaffoldrack.com CNAME
dig +short @1.1.1.1 thescaffoldrack.com A    # bypass local cache
```

Expected: A returns the four `185.199.108-111.153` IPs (order may vary);
AAAA returns the four `2606:50c0:8000-8003::153` addresses; www CNAME
resolves to `scaffoldrack.github.io.` (trailing dot).

GoDaddy propagation is usually seconds to minutes. If `dig` still shows
parked IPs, check for local resolver caching.

### 6. Set the custom domain in Pages settings

Only after DNS is pointing at GitHub. Settings → Pages → Custom domain:
`thescaffoldrack.com` → Save. DNS check should succeed immediately since
DNS is already correct. A green check appears.

The `static/CNAME` file in the repo makes this persist across
deployments.

### 7. Wait for the certificate to provision

**This step is easy to skip and causes the most painful failure mode.**

After setting the custom domain, "Enforce HTTPS" appears greyed out
with text like "Unavailable for your site because a certificate has not
yet been issued." Wait for the cert to provision — usually a few
minutes, occasionally up to 15.

**Do NOT re-trigger the deploy workflow during this window.** See
"Gotchas: the `http://` baked-in trap" below.

### 8. Enable Enforce HTTPS

Once the "Enforce HTTPS" checkbox becomes available (not greyed),
enable it. Save.

### 9. Re-run the deploy workflow

Actions → Deploy Hugo site to Pages → Run workflow → main.

This is the step that makes the custom-domain site work correctly.
`actions/configure-pages@v5` now returns `https://thescaffoldrack.com/`
as `base_url`; the Hugo container bakes `https://` into every URL it
generates; the site deploys with correct absolute links.

### 10. Verify end-to-end

```sh
curl -sI https://thescaffoldrack.com/ | grep -iE '^(HTTP|strict-transport)'
curl -sI http://thescaffoldrack.com/ | grep -iE '^(HTTP|location)'
curl -sI https://www.thescaffoldrack.com/ | grep -iE '^(HTTP|location)'
curl -vI https://thescaffoldrack.com/ 2>&1 | grep -iE 'issuer|subject:'
```

Expected:

- HTTPS apex returns `HTTP/2 200` with an HSTS header
- HTTP apex returns 301 to HTTPS
- `www` returns 301 to apex
- Cert issuer contains `Let's Encrypt`

Hard-refresh the site in a browser (Ctrl+Shift+R) to confirm rendering.
Navigate between pages; check the browser console for any 404s or
mixed-content warnings.

## Gotchas

### The `http://` baked-in trap

**Symptom:** Site loads at `https://thescaffoldrack.com/` but looks
unstyled. `curl` shows the HTML has `http://` URLs in canonical tags,
script/stylesheet `src`/`href`, and OpenGraph. Browser blocks the HTTP
script as mixed content.

**Cause:** `actions/configure-pages@v5` returns `http://` in its
`base_url` output when the custom domain is set but Enforce HTTPS is
not yet active. The workflow's `--baseURL` flag then passes `http://`
to Hugo, which bakes it in. HTTPS getting enabled later doesn't
retroactively fix the deployed artifact.

**Fix:** Re-run the workflow after Enforce HTTPS is enabled. This is
why step 9 comes after step 8.

**Long-term fix (not yet applied):** drop `--baseURL` from the workflow
entirely and let `config/_default/hugo.toml`'s `baseURL` be the single
source of truth. The config already has `https://thescaffoldrack.com/`;
removing the flag would make the workflow immune to `configure-pages`'s
protocol-reporting behavior. See CONTEXT.md §7 action items.

### DNS check failed when custom domain set before DNS

**Symptom:** Pages settings shows "DNS check failed" in red when
setting the custom domain.

**Cause:** Custom domain was set before DNS was pointed at GitHub.

**Fix:** Apply DNS records first, then set custom domain. Avoids the
DNS check retry loop entirely.

### "Get Pages site failed" on first workflow run

**Symptom:** First workflow run fails at `configure-pages@v5` with a
404 error.

**Cause:** Pages is not enabled on the repo. `configure-pages@v5` does
not auto-enable.

**Fix:** Enable Pages manually (Settings → Pages → Source: GitHub
Actions), re-run the failed workflow.

### Browser sees old nav/layout after deploy

**Symptom:** New changes (added menu items, layout tweaks) don't show
up after a successful deploy.

**Cause:** GitHub Pages serves behind Fastly with moderate HTML
caching; browser also caches the HTML document.

**Fix:** Hard refresh (Ctrl+Shift+R / Cmd+Shift+R) or incognito window.
Nothing to fix on the server side; real users pick up changes on their
next visit after TTL expires.

## When we migrate to self-hosted (Phase 3)

The only change needed will be replacing the A/AAAA records above with
records pointing at the self-hosted ingress IP. The `www` CNAME stays
as-is pointing at the same target (now the self-hosted equivalent of
`scaffoldrack.github.io`). The `static/CNAME` file in the repo gets
removed since it's Pages-specific. Verified domain at the GitHub org
level can stay — it's only relevant if Pages is ever re-used for this
domain.

Everything else — the site itself, the container workflow, the theme,
content — migrates unchanged.
