---
title: "About"
date: 2026-04-18
draft: false
showDate: false
showReadingTime: false
showWordCount: false
showTableOfContents: false
showTaxonomies: false
showPagination: false
showAuthor: false
---

## What this is

The Scaffold Rack is a hands-on platform for building and operating a modern
homelab — documented publicly as I go. It's a ground-up rebuild of my homelab
into something closer to real platform engineering, and every meaningful
decision, reversal, and dead end gets written up.

Scaffolding is temporary and iterative by nature. The name is a signal: this
is building in public, not a finished reference architecture. If a decision
here turns out to be wrong three months later, the post gets a callout at the
top rather than a silent edit. The value is in the honest record, not the
polished outcome.

## Who I am

I'm Andrew Krull. I've been doing open source systems work for 20+ years —
sysadmin, then DevOps, now platform engineering. Currently a senior engineer
focused on internal platform tooling: GitOps pipelines, observability stacks,
and the kind of infrastructure that other engineers actually want to use.

Self-hosting has been part of my life for a long time. What's changing here
is the rigor — I'm operating my home infrastructure like production:
declarative, version-controlled, observable, recoverable. Not because my
home needs five-nines uptime, but because the discipline is what makes
interesting architectures possible. A homelab that can be rebuilt from git
is a homelab you can experiment on without fear.

## Why I'm writing this

Three reasons, in decreasing order of selfishness:

1. **I learn by writing.** Explaining why something works forces me to
   actually understand it. Half of what I know I learned by writing it down.

2. **There's a gap in the public material.** Plenty of blogs show you the
   finished Kubernetes cluster or the clever Terraform trick. Fewer show
   the month of "why is MetalLB doing that" that came before it. I want
   to fill some of that.

3. **The AI platform story is underdocumented.** I run local inference at
   home, and I'm building toward a self-hosted AI platform with governance,
   observability, and real tooling integration. That's increasingly relevant
   work and almost nobody outside big companies is writing about it.

## What you'll find here

- **Series** covering multi-post arcs: the initial build, the AI platform
  work, specific deep-dives on subsystems that warranted more than one post.
- **Standalone posts** on decisions, tradeoffs, things that broke.
- **Referenced commits.** Posts that change code link to specific SHAs so
  you can see exactly what was done. Nothing is hand-waved.
- **The occasional tangent.** Some of this is technical memoir. I like that.

Code is Apache 2.0. Writing is CC-BY-4.0. Use it, build on it, send corrections.

## Reaching me

Comments are off. They're a maintenance burden I don't want and they tend to
attract the wrong kind of engagement for technical writing.

If something in a post is wrong, unclear, or missing context, open an issue
on the relevant repo at [github.com/scaffoldrack](https://github.com/scaffoldrack).
Issues are better than comments for this kind of material: they're public,
they're tied to specific artifacts, and they don't disappear when the
comment-hosting service shuts down.

For anything else, you can find me on GitHub.
