# Claude Adjutant

An autonomous AI executive assistant. Zero code. Just markdown + Claude Code.

Claude Adjutant runs 24/7 on your hardware, manages your projects, runs growth
experiments, handles email and calendar, and messages you proactively when
something needs your attention. It thinks strategically, delegates execution
to sub-agents, and gets smarter over time.

## How It Works

```
You (Telegram / Slack / Dispatch)
  ↓
Claude Adjutant (Opus, always-on, always responsive)
  ├── Thinks: strategy, priorities, decisions
  ├── Delegates: execution to sub-agents (Sonnet/Haiku)
  └── Never: does manual work itself
        ↓
Knowledge System (markdown files)
  ├── SOUL.md        — personality, values, boundaries
  ├── heartbeat.md   — what to check every 30 minutes
  ├── queue.md       — single coordination point for all work
  ├── knowledge/     — people, projects, goals, decisions
  ├── skills/        — reusable workflows (growth loops, reviews, briefings)
  └── experiments/   — running and completed experiment tracking
```

## What Makes It Different

- **Zero code.** The entire system is markdown files + Claude Code configuration.
  No frameworks, no databases, no custom code.
- **SOUL.md.** A persistent identity document that evolves over time. Not just
  instructions — personality, values, and learned patterns.
- **Heartbeat.** A configurable checklist that runs every 30 minutes, making the
  agent proactive instead of reactive.
- **Queue.** A single markdown file that coordinates all work — sub-agents,
  experiments, scheduled jobs all write to one place.
- **Three-tier memory.** Hot (queue, ≤50 lines), warm (knowledge, loaded on
  demand), cold (archive, searchable). Context never bloats.

## Quick Start

1. Clone this repo to your machine
2. Edit SOUL.md with your personality and boundaries
3. Add your projects to knowledge/projects/
4. Install [Claude Code](https://code.claude.com/docs/en/quickstart)
5. Run: `cd adjutant && claude`

For 24/7 deployment on a headless Mac Mini, see [docs/SETUP.md](docs/SETUP.md).

## Permissions & Security

Claude Adjutant ships with **full autonomous permissions** by default. This means:

- All Bash commands are auto-approved (except `rm -rf /` and `sudo rm -rf`)
- All file operations (read, write, edit) are auto-approved
- All MCP tools (Telegram, Gmail, browser automation) are auto-approved
- `defaultMode: bypassPermissions` — no terminal prompts

**This is intentional.** Claude Adjutant is designed to run headlessly on a dedicated
machine (Mac Mini, server). Terminal permission prompts block execution with no
notification to the user, which breaks the autonomous loop.

**If you want tighter controls**, edit `.claude/settings.json`:
- Change `defaultMode` to `"acceptEdits"` or `"default"` for interactive use
- Remove `"Bash(*)"` and add specific command patterns you trust
- Remove MCP wildcards and add tools individually

The boundaries that matter are in SOUL.md — what the agent will and won't do
is governed by its identity document, not by permission prompts. The agent
respects financial boundaries, communication approval requirements, and
irreversible action guards defined there.

## Architecture

See [docs/architecture.md](docs/architecture.md) for the full design, including
model routing, memory tiers, and the dispatch protocol.

## Requirements

- Claude Code with a Max or Pro subscription
- macOS (launchd) or Linux (systemd) for scheduling
- Optional: Google Workspace CLI (`gws`) for email/calendar
- Optional: Telegram bot for mobile interface

## License

MIT
