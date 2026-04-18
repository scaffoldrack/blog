# blog

A hands-on platform for building and operating a modern homelab —
documented publicly at [thescaffoldrack.com](https://thescaffoldrack.com).

This repo contains the Hugo source for the blog. Published posts live
under `content/posts/`. The site builds and deploys to GitHub Pages on
every push to `main`, with dev, local prod build, and CI all running
the same pinned Hugo inside a container.

## Stack

- **Hugo** (extended, v0.155.3) — pinned in `Dockerfile`, used in dev and CI
- **Congo** — theme, pulled in as a git submodule on the `stable` branch
- **Docker + docker compose** — the only host dependency for writing
- **GitHub Pages** — hosting (Phase 0; migrates to self-hosted in Phase 3)
- **GitHub Actions** — CI, free for public repos (no cost to this project)
- **GoatCounter** — privacy-respecting analytics, no cookies

## Local development

You need `git`, `make`, and `docker` on your host. That's it — no Hugo install.

Clone with submodules so you get the Congo theme:

```sh
git clone --recurse-submodules git@github.com:scaffoldrack/blog.git
cd blog
```

If you already cloned without `--recurse-submodules`:

```sh
git submodule update --init --recursive
```

Start the dev server:

```sh
make dev
```

First run builds the Hugo image (~30s); subsequent runs reuse the cache.
Site lives at http://localhost:1313 with live reload on file changes.
Drafts are built in dev but excluded from production builds.

### Common tasks

```sh
make help                    # list all commands
make dev                     # live-reload dev server
make build                   # production build to public/ (mirrors CI)
make new POST=hello-world    # new draft post from archetype
make new-page PAGE=colophon  # new standalone page
make shell                   # drop into a shell in the container
make version                 # show pinned Hugo version
make clean                   # remove build artifacts
```

### Why containerized?

Dev and CI run the exact same Hugo binary, pinned in `Dockerfile`. "Works
on my machine" and "works in CI" become the same statement. Bumping Hugo
is a one-line change in one place, and the update automatically flows to
CI on the next push.

This also means contributors don't need a working Hugo install — just
docker. Matches the scaffoldrack ethos of repos that clone-and-work
without environment setup.

## Repo conventions

- **New posts are drafts by default.** Flip `draft: false` when publishing.
- **Music shortcode at top of every post:**
  ```
  {{</* music "Artist — Album" "https://www.youtube.com/watch?v=..." */>}}
  ```
- **Commit references via shortcode, not raw links:**
  ```
  {{</* commit "scaffoldrack/platform" "abc1234" */>}}
  ```
- **Series live as taxonomy entries** (set `series: ["The Rebuild"]` in
  front matter). A post can belong to multiple series.
- **Outdated posts get a callout at the top, never a silent edit.**
- `tmp/` is gitignored staging space; never commit anything from it.

Project-wide conventions live in `scaffoldrack-notes/CONTEXT.md`.

## Deploying

Push to `main`. The workflow at `.github/workflows/deploy.yml` handles
the rest: checks out submodules, builds the Hugo image from this repo's
`Dockerfile`, runs the build inside that image, deploys to Pages.

Manual redeploys are available from the Actions tab → "Deploy Hugo site
to Pages" → "Run workflow".

### Upgrading Hugo

Hugo version is pinned in `Dockerfile` (`ARG HUGO_VERSION=...`). To
upgrade:

1. Edit the `HUGO_VERSION` default in `Dockerfile`
2. Run `make image-build` to force a rebuild
3. Run `make build` locally to verify the site still builds clean
4. Commit and push; CI picks up the new version automatically

The single source of truth for Hugo version is `Dockerfile`. CI pulls
the version from there; dev pulls it from there. No divergence possible.

## GoatCounter setup

The analytics snippet is injected via `layouts/partials/extend-head.html`.
On first deploy, sign up at [goatcounter.com](https://www.goatcounter.com/),
pick a code (e.g. `scaffoldrack`), and replace `GOATCOUNTER_CODE` in that
partial with the actual code. The script only loads on production builds
so local dev traffic isn't counted.

## License

This repo is a mixed content repo:

- **Code** (`layouts/`, `assets/`, config, Dockerfile, Makefile, workflows):
  Apache 2.0 — see [LICENSE-CODE](./LICENSE-CODE)
- **Content** (`content/`, all blog posts and prose): CC-BY-4.0 — see
  [LICENSE-CONTENT](./LICENSE-CONTENT)

When reusing material, please attribute correctly per the applicable
license. The **Congo theme** is under its own MIT license; see
`themes/congo/LICENSE`.
