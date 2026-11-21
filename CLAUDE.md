# Car Repair Shop [ANOMALY]: rules for every AI working on this game

Several people work on this game from different computers, each with their own AI account. This folder is the
shared memory, kept in sync with https://github.com/SyuQyu/anomaly-docs. Read [README.md](README.md) first.

## Sync

- `.claude/settings.json` runs `tools/sync-docs.sh`: **pull** when a session starts, **commit + push** after every
  reply. Nothing to do by hand while it works.
- If it reports a failure (offline, login, or a teammate edited the same lines), fix it before other work:
  `git pull --rebase`, resolve the conflict keeping BOTH people's entries, then `git push`.
- No Claude Code, or a different AI? Run `git pull` before you start and `git add -A; git commit; git push` after.
- Never force-push and never delete another person's entry.

## Writing progress

- After any piece of work, add a dated entry at the **top** of [PROGRESS.md](PROGRESS.md): what changed, where
  (Studio paths), what was tested and what was not. Put your name or handle in the heading, e.g.
  `## 2026-11-21 (Aizu): ...`.
- Bigger systems get their own handoff file (`*_HANDOFF.md`), linked from README.md.
- Update the "open items" lists when you finish or find something.
- No secrets in this repo (webhook URLs, API keys, cookies). It is public.

## Game rules (short; details in SESSION_HANDOFF.md and the other handoffs)

- Built live in Roblox Studio through the Roblox MCP. Nobody publishes except the owner.
- Never write code comments. Make GUI and other instances as real instances in Studio; code clones templates.
- Tunables go in config ModuleScripts. Server is authoritative. Phones are the limiting device.
- Read a script right before editing it: teammates edit the same place.
