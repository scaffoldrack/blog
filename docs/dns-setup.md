# DNS setup — thescaffoldrack.com → GitHub Pages

One-time DNS configuration to get `thescaffoldrack.com` serving the Hugo
site from GitHub Pages over HTTPS. Do this at whatever registrar is
authoritative for the domain.

## Decision: apex, not www

Canonical URL is `https://thescaffoldrack.com/` (apex). `www.thescaffoldrack.com`
redirects to apex. This is already recorded in an ADR.

## Records to create

### A records at the apex (@)

GitHub's Pages IPs. All four are required for redundancy:

```
Type   Host   Value            TTL
A      @      185.199.108.153  3600
A      @      185.199.109.153  3600
A      @      185.199.110.153  3600
A      @      185.199.111.153  3600
```

### AAAA records at the apex (IPv6, optional but recommended)

```
Type   Host   Value                    TTL
AAAA   @      2606:50c0:8000::153      3600
AAAA   @      2606:50c0:8001::153      3600
AAAA   @      2606:50c0:8002::153      3600
AAAA   @      2606:50c0:8003::153      3600
```

### CNAME for www → apex

```
Type    Host   Value                  TTL
CNAME   www    scaffoldrack.github.io 3600
```

GitHub Pages handles the www-to-apex redirect automatically once the
repo's Pages settings have `thescaffoldrack.com` as the custom domain
(the `static/CNAME` file already in the repo sets this on first deploy).

## Steps

1. Push the repo to `github.com/scaffoldrack/blog` (including `static/CNAME`
   and the `.github/workflows/deploy.yml` workflow).
2. Trigger the first deploy — either by pushing to `main`, or from the
   Actions tab → "Run workflow". First deploy will fail or warn about
   custom domain; that's fine.
3. Settings → Pages in the repo:
   - Source: **GitHub Actions** (should already be set by first workflow run)
   - Custom domain: **thescaffoldrack.com** (paste, click Save)
   - "Enforce HTTPS" checkbox: wait until it becomes available (can take
     up to 24h after DNS propagates), then enable it
4. Apply the DNS records above at the registrar.
5. Wait for propagation — usually minutes, occasionally an hour. Check
   with `dig thescaffoldrack.com` or `https://www.whatsmydns.net/`.
6. Verify the site loads at both:
   - `https://thescaffoldrack.com/`
   - `https://www.thescaffoldrack.com/` (should redirect to apex)
7. Enable "Enforce HTTPS" in Pages settings once available.

## Verifying the cert

Cert provisioning happens automatically once DNS is pointing at GitHub.
You can check:

```sh
curl -vI https://thescaffoldrack.com/ 2>&1 | grep -E '(HTTP|subject|issuer)'
```

The issuer should be `Let's Encrypt`.

## Troubleshooting

- **"DNS check failed" in Pages settings** — DNS hasn't propagated yet,
  or records are wrong. Verify with `dig thescaffoldrack.com +short` and
  compare to the IPs above.
- **Cert won't provision** — remove custom domain in Pages, wait 5
  minutes, re-add it. Known GitHub Pages quirk.
- **www isn't redirecting** — check the CNAME points at
  `scaffoldrack.github.io`, not `scaffoldrack.github.io/blog` or
  similar. Just the hostname.

## When we migrate to self-hosted (Phase 3)

The only change needed will be replacing the A/AAAA records above with
records pointing at the self-hosted ingress IP. The `www` CNAME stays
as-is but points at the same target. CNAME file in the repo gets
removed since it's Pages-specific.

Everything else — the site itself, the container workflow, the theme,
content — migrates unchanged.
