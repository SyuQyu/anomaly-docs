# Car Repair Shop [ANOMALY] docs

Read in this order:

1. [SESSION_HANDOFF.md](SESSION_HANDOFF.md): the base game (shift loop, anomalies, where everything lives, rules).
2. [LOBBY_MATCHMAKING_HANDOFF.md](LOBBY_MATCHMAKING_HANDOFF.md): lobby place, cars as rooms, rejoin,
   ProfileStore data, monochrome UI, test van, open items.
3. [GAMEPLAY_SHOP_HANDOFF.md](GAMEPLAY_SHOP_HANDOFF.md): test cars, customer cars with random paint and plates,
   office restored, shop front (shutters, door, control panel, open-the-shop start), paper notice, HUD auto-size fix.
4. [GAMEPLAY_LOOP_HANDOFF.md](GAMEPLAY_LOOP_HANDOFF.md): the full loop from the master implementation prompt
   (arrival, dialogue, bays, battery/radiator repairs, cashier tray, Anomaly Director, tycoon, staff,
   countermeasure), with the tested / not tested / blocked report.
5. [RETAIL_DECOR_HANDOFF.md](RETAIL_DECOR_HANDOFF.md): retail shoppers, backroom / shelf / repair stock, supplier and
   restock, free decoration and build mode, 17 retail anomalies, test results.

Also here (added 2026-11-21):

- [PROGRESS.md](PROGRESS.md): dated log of every change, newest first. **Add your entry at the top.**
- [VERTICAL_SLICE_PLAN.md](VERTICAL_SLICE_PLAN.md), [UI_PRD.md](UI_PRD.md),
  [UI_DESIGN_SYSTEM.md](UI_DESIGN_SYSTEM.md), [UI_REVIEW_2026-11-19.md](UI_REVIEW_2026-11-19.md),
  [PLAYTEST_M5.md](PLAYTEST_M5.md).

## Working together

Rules for people and their AI: [CLAUDE.md](CLAUDE.md). With Claude Code, `.claude/settings.json` pulls when a
session starts and commits + pushes after every reply (`tools/sync-docs.sh`). Clone this repo and open it as the
project folder (or a parent folder with the same hooks) to get that.
