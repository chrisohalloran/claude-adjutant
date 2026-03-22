# Claude Adjutant Setup Guide

An autonomous AI executive assistant. Zero code. Just markdown + Claude Code.

## Prerequisites

- [Claude Code](https://code.claude.com/docs/en/quickstart) v2.1.80+ installed
  with a Max or Pro subscription (claude.ai login required — API key auth alone
  is not sufficient for Channels)
- macOS (for launchd scheduling) — Linux works with systemd equivalents
- A machine that stays on (Mac Mini, server, VPS)

> **Note:** Telegram/Slack channels are in Claude Code's research preview.
> Availability may change. The core agent (heartbeat, queue, knowledge system)
> works without channels — you just interact via terminal instead.

## Step 1: Install CLI Tools

### Google Workspace CLI (email, calendar, drive)

```bash
# Install gws
npm install -g @anthropic-ai/google-workspace-cli
# Or via the official repo:
# https://github.com/googleworkspace/cli

# Authenticate
gws auth login

# Test
gws gmail messages list --max-results 5
gws calendar events list --max-results 5
```

### GitHub CLI (if managing repos)

```bash
brew install gh
gh auth login
```

### Telegram Channel Plugin

```bash
# In a Claude Code session:
/plugin install telegram@claude-plugins-official

# Configure your bot token (get from @BotFather on Telegram):
/telegram:configure <your-bot-token>

# Pair your account:
# 1. Message your bot on Telegram
# 2. Get the pairing code
# 3. In Claude Code:
/telegram:access pair <code>
/telegram:access policy allowlist
```

## Step 2: Copy the Claude Adjutant Folder

```bash
# Clone the repo (or copy the template)
git clone https://github.com/yourusername/adjutant.git ~/adjutant
```

## Step 3: Personalise

Edit these files:

1. **SOUL.md** — Update the identity, voice, and boundaries sections to match
   your personality and preferences. The Learned Patterns section grows over time.

2. **knowledge/owner.example.md** — Copy to `knowledge/owner.md` and fill in your profile.

3. **knowledge/projects/_active.md** — Add your products and projects.

4. **knowledge/goals/quarterly.md** — Set your current priorities.

## Step 4: Test Locally

**Important:** If you have `ANTHROPIC_API_KEY` set in your environment, unset it.
Claude Adjutant uses your Max/Pro subscription, not API credits. The API key will cause
standalone processes (heartbeat, morning briefing) to fail with "credit balance
too low."

```bash
# Check if API key is set (should be empty)
echo $ANTHROPIC_API_KEY

# If set, unset it for this session
unset ANTHROPIC_API_KEY

# Or permanently remove it from your shell profile (~/.zshrc, ~/.bashrc)
```

```bash
cd ~/adjutant

# Test the main agent (interactive)
claude

# The heartbeat starts automatically in any session (configured in CLAUDE.md).
# To test the standalone heartbeat process:
./scripts/run-with-lock.sh heartbeat-test -p "$(cat heartbeat.md)" --model sonnet --max-turns 10

# Verify it worked:
grep "Last Heartbeat" queue.md
cat logs/heartbeat-test.log

# Test with Telegram channel
claude --channels plugin:telegram@claude-plugins-official --model opus --effort medium
```

## Step 5: Deploy Schedules

```bash
# Generate plists from templates (replaces $HOME with your actual home dir)
for f in schedules/templates/*.template.plist; do
  out=~/Library/LaunchAgents/$(basename "$f" .template.plist).plist
  sed "s|\$HOME|$HOME|g" "$f" > "$out"
done

# Load them
launchctl load ~/Library/LaunchAgents/com.adjutant.channel-session.plist
launchctl load ~/Library/LaunchAgents/com.adjutant.heartbeat.plist
launchctl load ~/Library/LaunchAgents/com.adjutant.morning-briefing.plist
launchctl load ~/Library/LaunchAgents/com.adjutant.memory-maintenance.plist

# Verify they're running
launchctl list | grep adjutant
```

## Step 6: Verify

1. Send a message to your Telegram bot — you should get a response
2. Open claude.ai/code — you should see "Adjutant" with a green dot (online)
3. Click into the session from the web — you can interact from both Telegram
   AND the web UI simultaneously
4. Wait 30 minutes — the heartbeat should process queue.md
5. Check logs: `tail -f ~/adjutant/logs/channel-session.log`

## How to Access Claude Adjutant

Once deployed, you have four ways to interact — all hitting the same session:

| Interface | How | Best for |
|-----------|-----|----------|
| **Telegram** | Message your bot | Quick requests from phone |
| **claude.ai/code** | Open the "Adjutant" session | Full web UI, diff view, long interactions |
| **Claude iOS/Android app** | Open the "Adjutant" session | Mobile access with full UI |
| **SSH + terminal** | `ssh mac-mini.local` then `claude --continue` | Emergency recovery, debugging |

Remote Control (--remote-control) is what makes the web and mobile access work.
It connects claude.ai and the Claude app to your LOCAL session — your files,
MCP servers, and tools all stay on your machine. Nothing runs in the cloud.

### Requirements for Remote Control
- Claude.ai login (not API key auth)
- Claude Code v2.1.51+
- Team/Enterprise: admin must enable Remote Control in Claude Code admin settings
- Your Mac Mini must be awake and connected to the internet

### If the web UI shows "offline"
The local session has stopped or lost network. Recovery options:
1. launchd KeepAlive should restart it automatically — wait 30 seconds
2. SSH in and check: `launchctl list | grep adjutant`
3. Force restart: `launchctl stop com.adjutant.channel-session`
4. If network dropped for >10 minutes, Remote Control times out — launchd
   restarts the process and a new Remote Control session is created

## Updating

Edit any markdown file and the changes take effect on the next session or
heartbeat run. No restart needed for knowledge/ or skill changes.

For settings or hook changes, restart the channel session:
```bash
launchctl stop com.adjutant.channel-session
# launchd KeepAlive restarts it automatically
```

## Troubleshooting

### Channel session not responding
```bash
# Check if it's running
launchctl list | grep adjutant

# Check logs
tail -50 ~/adjutant/logs/channel-session.err

# Force restart
launchctl stop com.adjutant.channel-session
```

### Connect via SSH (from another machine)
```bash
ssh your-mac-mini.local
cd ~/adjutant
claude --continue  # Resume the most recent session
```

### Connect via Remote Control (from phone/browser)
Open claude.ai/code or the Claude mobile app. Look for the "Adjutant"
session — it should show a computer icon with a green status dot when
online. Click into it to interact.

If the session doesn't appear, the local process may have stopped.
SSH in and check `launchctl list | grep adjutant`.
