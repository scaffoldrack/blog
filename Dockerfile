# Hugo dev/build container
# ============================
# Single image used in three places:
#   1. Local dev loop    (docker compose up   → hugo server with live reload)
#   2. Local prod build  (make build          → hugo --minify)
#   3. CI                (GitHub Actions builds from this same Dockerfile)
#
# Pinning rationale: Hugo version is the single most impactful variable in
# reproducing a build. Pinning the binary here means dev and CI are
# byte-identical. If a build passes locally, it passes in CI.
#
# Upgrade process:
#   1. Bump HUGO_VERSION below
#   2. Run `make image-build` to rebuild
#   3. Run `make build` to verify
#   4. Commit and push — CI picks up the new version automatically
# Single source of truth. Only this line changes.
#
# Base image rationale: Debian trixie-slim (Debian 13, current stable
# since Aug 2025, supported through 2030). Hugo's official Linux binaries
# are dynamically linked against glibc; Alpine uses musl libc and can't
# run them without shim layers that break between versions
# (see github.com/gohugoio/hugo/issues/4961). Trixie is on glibc 2.41
# and Hugo's binary runs natively.
#
# trixie-slim is ~80MB vs alpine ~20MB — the extra 60MB is worth it for
# a binary that actually runs. Building Hugo from source would eliminate
# the base-image dependency but adds multi-minute rebuilds on every
# version bump, which fails the 3am test.

FROM debian:trixie-slim

ARG HUGO_VERSION=0.155.3
ARG TARGETARCH=amd64

# git is needed for Hugo's .Lastmod (git-derived page last-modified times)
# and for submodule operations. tzdata is needed for correct post
# timestamps. ca-certificates is needed for HTTPS (Hugo fetches some
# resources at build time, and curl needs valid root certs).
#
# curl is installed, used, then purged. Final image doesn't ship a
# download tool — Hugo is already on disk, so keeping curl around would
# just bloat the image.
RUN set -eux \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      tzdata \
 && curl -fsSL -o /tmp/hugo.tar.gz \
      "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${TARGETARCH}.tar.gz" \
 && tar -xzf /tmp/hugo.tar.gz -C /tmp \
 && mv /tmp/hugo /usr/local/bin/hugo \
 && chmod +x /usr/local/bin/hugo \
 && rm -f /tmp/hugo.tar.gz /tmp/LICENSE /tmp/README.md \
 && apt-get purge -y curl \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && hugo version

# Non-root user. UID 1000 matches the default host user on most Linux
# distros, so bind-mounted files stay writable without chown gymnastics.
# If your host UID differs, the compose file / Makefile pass it in via --user.
RUN useradd --create-home --uid 1000 --user-group hugo

USER hugo
WORKDIR /site

# Hugo server default port; overridden by docker-compose for dev, and
# by the Makefile targets for one-off invocations.
EXPOSE 1313

ENTRYPOINT ["hugo"]
CMD ["server", "--bind", "0.0.0.0", "--buildDrafts", "--disableFastRender"]
