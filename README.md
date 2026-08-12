<!-- foundation:identity -->
# Trailmark Research

A user submits a research question and an agent works through it step by step; every step and its result is recorded and rendered as a live timeline, ending in a synthesized answer.

- Site: https://trailmark-research.api.holode.xyz
- Support: support@trailmark-research.api.holode.xyz
<!-- /foundation:identity -->

## What this is

Submit a research question, and an agent decomposes it into steps, executes each step against a provider, and records every step's status, output, and duration on a timeline. Completed runs show the synthesized answer plus the full trail.

## Who it is for

- Researcher (any visitor, no account needed)
- Research Agent (runs steps through a provider adapter)
- Operator (sees all runs via the admin surface)

## Main features

- **Submit a research question** — A visitor enters a question; the run is planned into four steps and executed.
- **Watch the run** — The run page shows a live timeline; it auto-refreshes while the run is active.
- **Review the result** — Completed runs show the final answer plus every step's assignment, output, status, and timing.
- **Provider adapter** — A demo adapter runs out of the box with zero configuration; an HTTP adapter is included for any OpenAI-compatible chat API.

## Core entities

- ResearchRun
- ResearchStep

## Provider configuration

The agent talks to an LLM through a provider adapter. Two adapters ship:

| Name | ENV selector | What it does |
| --- | --- | --- |
| `demo` (default) | `RESEARCH_PROVIDER_NAME=demo` | Deterministic results, no network, no credentials. Default in previews. |
| `http` | `RESEARCH_PROVIDER_NAME=http` | Calls any OpenAI-compatible `/chat/completions` endpoint (OpenAI, OpenRouter, DeepSeek, Groq, ...). |

To run against a real provider, set on the host (values live in the operator's secret store, never in this repo):

```bash
RESEARCH_PROVIDER_NAME=http
RESEARCH_PROVIDER_URL=https://api.openai.com/v1/chat/completions   # or OpenRouter/DeepSeek/etc.
RESEARCH_PROVIDER_API_KEY=<key>
RESEARCH_PROVIDER_MODEL=gpt-4o-mini                                 # or deepseek-chat, etc.
RESEARCH_PROVIDER_TEMPERATURE=0.2                                   # optional
```

Add a new provider by implementing `ResearchProviders::Base#execute(step, context)` and registering it in `config/initializers/research_providers.rb`.

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Requires Ruby, PostgreSQL, and the usual Rails toolchain. See `bin/setup` if present.

## Demo

`db/seeds.rb` seeds one completed demo run about the Vela pulsar so the timeline renders fully without any provider call. New runs use the demo adapter by default, so the whole flow works offline.

## Deploy notes

Production `config.hosts` is derived from `domain` in `config/foundation.yml`. Keep that value aligned with the real host or every request will 403.
