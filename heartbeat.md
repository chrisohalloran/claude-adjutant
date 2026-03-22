# Heartbeat

Run every 30 minutes. Check each item. Act on anything that needs attention.
Only message the owner if something is actionable — no "all clear" noise.
Delegate any work that takes more than 2 tool calls to a sub-agent.

## Queue (always check first)
- [ ] Read queue.md → process Urgent items immediately (message the owner)
- [ ] Process Action Required items older than 24hrs
- [ ] Move completed Informational items to knowledge/ files
- [ ] Prune queue.md to ≤50 lines (archive overflow to archive/)

## Channels
- [ ] Unread Telegram messages → respond or delegate
- [ ] Unread Slack mentions → respond or delegate

## Email + Calendar (via gws CLI)
<!-- primary account — every heartbeat, flag urgent -->
<!-- secondary account — every heartbeat, flag urgent -->
<!-- other accounts — once daily (morning) -->
- [ ] Calendar events in next 2 hours → prep notes if meeting needs it
- [ ] GTD inbox processing: delete spam, categorise (Action/Waiting/Reference), respond to actionable, draft responses needing the owner approval. Use Haiku for bulk processing.

## Experiments
- [ ] Read experiments/_active.md → any reached decision criteria? → message the owner
- [ ] Any experiment stalled >48hrs with no new data? → flag in queue.md

## Projects
- [ ] Read knowledge/projects/_active.md → deadlines within 24hrs? → remind the owner
- [ ] Check outbox/ → deliverables ready that haven't been sent? → notify

## Open Loops
- [ ] Read knowledge/open-loops.md → anything pending >7 days? → escalate
- [ ] Items marked "waiting on" where response may have arrived? → check

## Inbox
- [ ] Files in inbox/ not yet processed? → delegate processing to sub-agent

## System Health
- [ ] Disk space >90%? → alert the owner
- [ ] Any scheduled jobs failed since last heartbeat? → report
- [ ] Channel session still responsive? → flag if issues detected

## Queue Maintenance
- [ ] If queue.md exceeds 50 lines → compress old items, archive detail
- [ ] If any knowledge/*.md file exceeds 100 lines → delegate pruning to Haiku

## Karp Loop Experiments
- [ ] Check for active Karp Loop runs: find status.json files under ~/dev/products/*/output/karp-loop/
- [ ] Any loop_status "blocked"? → Urgent: report to the owner with the validation log
- [ ] Any loop_status "pass"? → Action Required: report results, propose next experiment

## Growth & Revenue
- [ ] Check affiliate-tracker.md → any pending applications or follow-ups due?
- [ ] Check experiments/_active.md → any experiments ready to measure or iterate?
- [ ] Any new content or SEO opportunities spotted during email/web checks?

## Custom Checks
<!--
Add your own checks here. The agent also adds checks when you ask
"remind me to check X" or "keep an eye on Y."
Format: - [ ] Description of what to check → action if triggered
-->
