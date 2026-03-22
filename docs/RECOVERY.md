# Recovery Runbook

What to do when Adjutant has issues.

## Level 1: Automatic Recovery (No Action Needed)

launchd KeepAlive restarts the channel session if it crashes. Check logs
to see if this is happening frequently:

```bash
tail -100 ~/adjutant/logs/channel-session.err | grep -c "restart"
```

## Level 2: Remote Recovery (From Your Phone)

### Via Remote Control (claude.ai or Claude app)
1. Open claude.ai/code on your phone/browser, or the Claude iOS/Android app
2. Find the "Adjutant" session (green dot = online)
3. Interact directly — same session, same files, same tools
4. If the session shows offline, launchd should restart it within 30 seconds
5. If still offline after a minute, escalate to Level 3 (SSH)

### Via Telegram
If the channel session is running but behaving oddly, message your bot:
"Check your logs and tell me what's wrong"

## Level 3: SSH Recovery

```bash
ssh your-mac-mini.local

# Check what's running
launchctl list | grep adjutant

# Check disk space
df -h

# Check logs
tail -50 ~/adjutant/logs/channel-session.err
tail -50 ~/adjutant/logs/heartbeat.err

# Nuclear restart: stop everything, then let launchd restart
launchctl stop com.adjutant.channel-session
launchctl stop com.adjutant.heartbeat

# If launchd itself is broken, unload and reload
launchctl unload ~/Library/LaunchAgents/com.adjutant.*.plist
launchctl load ~/Library/LaunchAgents/com.adjutant.*.plist
```

## Level 4: Full Reset

If the knowledge system is corrupted or the agent is behaving erratically:

```bash
# Backup current state
cp -r ~/adjutant/knowledge ~/adjutant/knowledge-backup-$(date +%Y%m%d)
cp ~/adjutant/queue.md ~/adjutant/queue-backup-$(date +%Y%m%d).md

# Clear the queue
echo "# Queue\n\n## Urgent\n\n## Action Required\n\n## Informational\n\n## Waiting On" > ~/adjutant/queue.md

# Restart
launchctl stop com.adjutant.channel-session
```

## Common Issues

### Auth Expired
Claude subscription or gws auth may expire. Signs: API errors in logs.
Fix: `claude auth login` and `gws auth login` on the Mac Mini.

### Disk Full
Logs and archive can grow. The memory-maintenance job should handle this,
but if it fails:
```bash
# Clear old logs
find ~/adjutant/logs -name "*.log" -mtime +7 -delete
# Clear old archives
find ~/adjutant/archive -name "*.md" -mtime +90 -delete
```

### Queue Bloated Beyond 50 Lines
The heartbeat should prune this, but if it fails:
```bash
cd ~/adjutant
claude -p "Prune queue.md to under 50 lines. Archive overflow to archive/." \
  --allowedTools "Read,Write,Edit" --model haiku
```
