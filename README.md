<!-- foundation:identity -->
# Trailmark Research

A user submits a research question and an agent works through it step by step every step and its result is recorded and rendered as a live timeline, ending in a synthesized answer.

- Site: https://trailmark-research.api.holode.xyz
- Support: support@trailmark-research.api.holode.xyz
<!-- /foundation:identity -->

## What this is

A user submits a research question and an agent works through it step by step; every step and its result is recorded and rendered as a live timeline, ending in a synthesized answer.

## Who it is for

- Researcher (any visitor, no account needed)
- Research Agent (runs steps through a provider adapter)
- Operator (sees all runs, framework admin)

## Main features

- **Submit a research question** — Visitor enters a question; a run is created with a planned step list and execution kicks off.
- **Watch the run** — Run page shows a timeline of steps with live status; page refreshes while the run is active.
- **Review the result** — Completed run shows the final answer plus every step's input, output, and timing.

## Core entities

- ResearchRun
- ResearchStep

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Requires Ruby, PostgreSQL, and the usual Rails toolchain. See `bin/setup` if present.

## Demo

One completed demo run about the Vela pulsar with all steps recorded, so the timeline renders fully without any provider call.

## Deploy notes

Production `config.hosts` is derived from `domain` in `config/foundation.yml`. Keep that value aligned with the real host or every request will 403.
