# Shortcodes

Custom shortcodes for scaffoldrack blog posts. Template logic lives in
`.html` files kept minimal on purpose — Hugo's parser doesn't like nested
escaped shortcode examples inside comments, so all docs live here instead.

## `music`

Renders a subtle "Writing to [Artist — Album]" italic line at the top of
a post, with a music-note glyph in the brand orange. Link only, no iframe,
opens in a new tab.

### Usage

```
{{< music "Boards of Canada — Music Has the Right to Children" "https://www.youtube.com/watch?v=Du5xCSLA5Ks" >}}
```

### Arguments

| Position | Required | Description |
|----------|----------|-------------|
| 0 | yes | Display name (e.g. `Artist — Album`) |
| 1 | yes | URL — YouTube, Spotify, Bandcamp, anything |

If either arg is missing, renders nothing rather than erroring.

### Design rationale

- **Link only, no iframe.** Pages stay light. No third-party tracking
  until the reader clicks through.
- **Music-note glyph in orange.** Draws the eye but doesn't compete
  with post content.
- **Italic.** Reads as a byline-adjacent signal rather than a call to
  action.

---

## `commit`

Renders a linked, monospace short-SHA reference with a subtle orange tint.
Used to link inline to specific commits in scaffoldrack repos.

### Usage

```
{{< commit "scaffoldrack/blog" "abc1234" >}}
{{< commit "scaffoldrack/platform" "a1b2c3d4e5f6" "fix broken gitops apply" >}}
{{< commit "scaffoldrack/platform" "abc1234" "" "git.mercnet.info" >}}
```

### Arguments

| Position | Required | Description |
|----------|----------|-------------|
| 0 | yes | Repo slug (`owner/repo` — e.g. `scaffoldrack/blog`) |
| 1 | yes | SHA (full or short — always displayed as 7 chars) |
| 2 | no  | Optional label text (defaults to short SHA) |
| 3 | no  | Optional host (defaults to `github.com`) |

The fourth argument exists so posts can reference self-hosted Gitea
commits after the Phase 3 migration (e.g. `git.mercnet.info`) without
changing the shortcode.

### Design rationale

- **Short SHA in monospace.** Reads as code rather than prose.
- **Orange-tinted pill background.** Distinct from surrounding text
  without being loud.
- **Always short-form.** Full SHAs in prose are ugly; we store the
  full SHA internally but show 7 chars.
- **New tab with `rel=noopener noreferrer`.** Doesn't break the
  reading flow; doesn't leak referrer.
