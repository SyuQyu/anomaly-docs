# Car Repair Shop [ANOMALY]: session handoff

Written 2026-11-18 at the end of a long Claude Code session, so another AI can pick the work up cold.
Read this first, then `PROGRESS.md` (newest first, full detail per milestone) and `VERTICAL_SLICE_PLAN.md`.

## 1. The project

- Roblox horror sim by the user (Jothem Studio). Place **111351856377896**, universe **10777476810**.
- Design source: the user's **GDD v0.2** (repair-first anomaly horror, data-driven Anomaly Director, 1–4 player co-op,
  PS1 low-poly look). Never show "ANOMALY DETECTED"; anomalies only appear as wrong data in normal things.
- UI source: the user's **UI PRD v0.2** ("Workshop Industrial / Analog Horror"), saved in `UI_PRD.md`, turned into a
  design system in `UI_DESIGN_SYSTEM.md`.
- Everything is built live in Roblox Studio through the **Roblox Studio MCP**. There is no local source tree; the
  `.md` files in this folder are the only local record.

### Files in this folder
| File | What |
|---|---|
| `VERTICAL_SLICE_PLAN.md` | Scope, shift flow, the 5 anomalies, milestones M0–M5 with status |
| `PROGRESS.md` | Newest-first log of every milestone: what was built, where, what was tested, what wasn't |
| `UI_PRD.md` | The user's UI PRD + decisions taken with them |
| `UI_DESIGN_SYSTEM.md` | Reference analysis, tokens, type scale, audit, plan, result |
| `PLAYTEST_M5.md` | Playtest guide: publish checklist, session plan, answer key, observer sheet, questions |
| `SESSION_HANDOFF.md` | This file |

## 2. Rules the user set (follow them)

- **Never publish.** Publishing is the user's job.
- **No comments in code** ("JANGAN PERNAH TULIS COMMENT").
- **Never hard-code instances** ("JANGAN PERNAH HARDCODING APABILA ADA INSTANCE NYA"): GUIs, RemoteEvents, props,
  sounds, lights are created as real instances in Studio (via MCP `execute_luau` in Edit), not built by game code.
  Templates (row/line/slip templates) live inside the ScreenGui that clones them.
- Event-driven code, no polling where an event exists. Server is authoritative.
- Tunable numbers and all player-facing text go in config/shared modules (`*Config`, `ShiftShared.COPY`).
- Phones are the limiting device: keep it cheap; text never below 13 design px; modals never scale below 0.72.
- The user writes casual English (sometimes Indonesian). Answer plainly; test in Studio before claiming something
  works; say clearly what wasn't tested.
- Another Studio is often open: **ANMU Chapter 2 (place 81589173556431) is read-only** for this project. Always call
  `list_roblox_studios` first and target the Car Repair Shop instance (its id changes per Studio session).
- Don't send the user's email or personal details to external services.

## 3. Milestone status

| | Status |
|---|---|
| M0 night shop + car | ✅ |
| M1 customer + work order | ✅ |
| M2 tire repair (FIT THE WHEEL, ported from ANMU Chapter 2) | ✅ |
| M3 decision + shift (3 customers, release/quarantine, pay, report; plus GDD inspect + verify steps) | ✅ |
| UI 1 (HUD, service order, scanner + tire gauge, tool row, repair panel, report, players list) | ✅ |
| UI 2 (design system; ledger + work order rebuilt; CCTV; Case File; menu) | ✅ |
| M4 anomalies A1–A5 | ✅ |
| M5 playtest | **Prepped; waiting on the user to publish and play with friends** |

Nothing has been published. Everything was tested solo in Studio only.

## 4. How a shift works

1. Server `ShopServer` starts services; `ShiftService.Start` runs when the first character spawns.
2. A one-time **Night Notice** memo appears on each client (`BriefingUI`).
3. 3 customers in a row. One (random) is anomalous with 1–2 anomalies.
4. Per customer: car drives into bay 1 → customer walks to the counter → **Talk** prompt → dialogue, keys handed over
   → **service order** opens → customer sits in the waiting room.
5. Player diagnoses: tire gauge (tool 1) on each wheel, scanner (tool 2, prompt at the car's front) → finding written,
   status Diagnosed. Repair: FIT THE WHEEL mini-game (jack [3] → align → nuts in star order with wrench [4] → lower).
   Verify pressure → Verified. Release is locked until Verified; quarantine is always allowed.
6. **Call back** prompt on the seated customer → they walk to the counter → FINAL DISPOSITION (Release / Quarantine /
   Not yet) for the player who called them back.
7. Release = pay 120 + tip 10–40, car drives off. Quarantine = no pay, car fades out; a normal car held costs −1
   reputation, **applied only at the end of the shift**.
8. After 3 customers: **End of Shift ledger** reveals the truth (condition column, findings, unresolved count).
   START NEXT SHIFT restarts.

**Design rule:** the truth (anomalous or not, reputation hit) is never revealed mid-shift. The shift log sent to
clients is redacted (no Truth / Anomalies / Findings / Reputation) until `shift.Ended`.

## 5. Where things live (Studio)

### Shared — `ReplicatedStorage.Shop`
- `ShiftShared`: remote names, STATUS, CHOICES, attribute names (Shift, ShiftLog, CustomerWaiting, ClockAnchorTime,
  ClockAnchorSeconds, ClockRate), pressure rules, `Money` ("$152.00"), `Signed`, and **all copy** in `COPY`
  (Wheels, Faults, Prompts, Gauge, Decision, Findings, Hud, Objectives, Order, Scanner, Briefing, Menu, Cases, Cctv,
  Crew, Report, Notices).
- `ToolShared` (tools Gauge/Scanner/Jack/Wrench on keys 1–4), `RepairShared`, `WorkOrderShared`, `WorkOrderConfig`.
- `UITheme`: colour tokens (Charcoal 171A18, Panel 292E29, Olive 303A31, Paper C5BEA8, PaperDark AFA58D, Sage, Brass,
  Crt A8C79A, Amber C19B53, Red A34B43, Ink 24221D, InkFaded, Light, LightDim…) and fonts (Oswald display,
  RobotoMono technical, Source Sans body, Special Elite stamps).
- `State` (attributes = shared game state), `Remotes`, `UIAssets.SedanPhoto` (stripped car for the case-file photo).

### Server — `ServerScriptService.ShopSystem`
- `ShopServer` (Script): starts Tool, Repair, Workshop, Decision, WaitingRoom services, Shift.
- `ShiftService` + `ShiftConfig`: makeSpec, serve, settle (log entry incl. Colour/ColourHex/Fault/Mileage/Arrived/
  Closed/Anomalies/Findings), run, publish (redacted log), `pendingReputation`. Config `CUSTOMERS = 3`,
  `PLAYTEST_ANALYTICS = true`.
- `CustomerService` + `CustomerConfig` (+ `LOOKS`, `LOOK_SEED_OFFSET`) + `CustomerLooks`: NPC routes, dialogue,
  seat/stand, call-back, `customer.Decider`, anomaly hook calls.
- `VehicleService` (plate label uses `spec.PlateShown or spec.Plate`), `RepairService` + `RepairConfig`,
  `WorkshopService` (gauge, scanner readings), `DecisionService`, `OrderService`, `ToolService`.
- **Anomalies:** `AnomalyConfig` (rarity weights, chances, A2/A3/A4 numbers, `TEST_ANOMALIES` / `TEST_INDEX` test
  switches — keep nil), `AnomalyDefinitions` (data, see §6), `AnomalyService` (Pick, AnomalousIndices, Run, Reveal).
- `WaitingRoomService`: shared wall clock (server-time anchor, can run backwards), true forward clock `Minutes()`,
  radio music/static.
- `PlaytestLog`: `AnalyticsService:LogCustomEvent` → `Decision` and `ShiftEnded`.

### Client — `StarterPlayerScripts.ShopClient`
- `ShopClient` (LocalScript) starts every controller.
- `ShopClientConfig`: all client tunables (GUI names, keys, sizes, colours, CCTV/CASE/MENU/BRIEFING/CLOCK settings).
- `UIFit`: one fit-to-screen rule for modals (`Bind(root, target, scale, {Size, Margin, MarginX, MarginTop,
  MarginBottom, Floor 0.72, Ceiling 1.15})`).
- Controllers: Dialogue, WorkOrder, Repair, RepairWheel, Gauge, Decision, Shift (HUD + ledger), Prompt (custom
  ProximityPrompts), Tool, Scanner, Crew, CCTV, CaseFile, Clock, Pause (menu), Briefing.

### GUIs — `StarterGui` (DisplayOrder)
DialogueGui 10, RepairUI 20, DiagnosticUI 22, MainHUD 25, WorkOrderUI 26, CooperativeUI 30, CCTVUI 35,
ShiftReportUI 40, CaseFileUI 45, PauseMenu 50, BriefingUI 55.

### World — `Workspace.ShopSetup`
- Shop roughly x −142..−84, z 32..140; front wall x = −84 (forecourt beyond). Bay 1 car spot (−102, 0.2, 62).
- `Markers`: Bay1CarSpot, DriverExit, CustomerRoutes, Areas (CanQuery/CanTouch off), **CCTV** (Cam01 Parking,
  Cam02 Service Bay, Cam03 Waiting Room, Cam04 Rear Entrance; attributes Label, Area, Order, FieldOfView).
- `Office`: Counter, Waiting (3 chairs at x −135 facing +X, table), **CctvMonitor** (prompt F / D-pad up),
  **WaitingProps** (WallClock above the chairs, Radio on the table with Music 109558786368038 + Static 8028069841).
- `Lighting.CCTVGrade` (ColorCorrection, enabled locally only while watching).
- Templates: `ServerStorage.VehicleTemplates.Sedan`, `ServerStorage.CustomerTemplates.StandIn` (R15, Idle/Walk/Sit).
- StreamingEnabled is on; the shop fits inside the stream radius.

## 6. Anomalies (M4)

One anomalous customer per shift; 60% one anomaly, 40% two; rarity Common 60 / Uncommon 25. Hook phases: `Spec`,
`Customer`, `Seated`, `Standing`, `Removed`; each definition also has `Reveal(spec)` and `Short`.

| | Id | Rarity | Effect | Where to catch it |
|---|---|---|---|---|
| A1 | WrongPlate | Common | Car's plate one character off the order | Walk round the car vs the order (J) |
| A2 | LowMileage | Common | Scanner odometer 18k–42k km below the order | Scanner F2 details |
| A3 | DifferentPerson | Uncommon | Look (skin/shirt/trousers) changes while unseen in the waiting room, same name | Remember who dropped it off |
| A4 | WrongBody | Uncommon | No idle/walk animation (glides), head follows nearest player ≤ 45 studs | Watch them |
| A5 | ShopReacts | Uncommon | While seated: wall clock runs backwards, radio switches to static | Waiting room or CCTV CAM 03 |

A3 and A4 conflict. A4 is a stand-in: the real "mirrored walk / statue" clips (Mixamo, in Blender) aren't exported
to Roblox yet. To force anomalies for a test, set `AnomalyConfig.TEST_ANOMALIES = {...}` and `TEST_INDEX = n`
(and optionally `ShiftConfig.CUSTOMERS = 1`), then **set them back** (nil / 3).

## 7. Controls

WASD move · E interact · 1–4 tools (gauge, scanner, jack, wrench) · J service order · Tab players · F CCTV monitor
(1–4 / Q E switch, Backspace exit) · Scanner F1 rescan, F2 details, Backspace back · P menu (Resume, Controls, Night
Notice, Case Files, Leave Shift) · Case file Q/E tabs, Up/Down cases · Repair: Space press, Q/R turn, Backspace stop.

## 8. Testing tips (Roblox Studio MCP)

- `execute_luau` runs in its own VM: requiring a game module there gives a separate copy (no shared state). Inject
  state by setting `ReplicatedStorage.Shop.State` attributes on the Server, or drive real prompts.
- Prompts: `prompt:InputHoldBegin()` / `InputHoldEnd()` from the Client after moving the character within range
  (wait ~1 s after `PivotTo`). The Talk prompt is `Customers.CustomerN.HumanoidRootPart.TalkPrompt` (also used for Call back).
- GUI buttons: `user_mouse_input` `moveTo` with an `instance_path` like
  `LocalPlayer.PlayerGui.WorkOrderUI.Disposition.Buttons.QuarantineButton`, then click.
- `script_read` fails in Play mode; read `.Source` with `execute_luau`. Edits made during Play don't persist; Edit
  datamodel isn't available in Play.
- Screenshots sometimes show a grey/black world when Studio isn't focused; GUI still renders.
- The camera ignores direct CFrame writes under the default camera script: bind a RenderStep at Camera+1 to hold it.
- A full repair can be driven by firing `RepairAction` with `at = GetServerTimeNow() + 0.045` (see PROGRESS.md M2/M3).
- First Play load may print "Infinite yield possible … DialogueGui": harmless slow GUI load.

## 9. Open items / next steps

1. **M5 playtest (user):** publish, play per `PLAYTEST_M5.md`, read analytics (Creator Dashboard → Analytics →
   Custom Events `Decision`, `ShiftEnded`), collect answers. Then tune based on results.
2. **Untested:** 2+ players together, phones (only calculated), gamepads, touch, releasing an anomalous car
   (should show UNRESOLVED), A1/A2 seen in the 3D view, radio loudness, the menu's Leave button (kicks the player).
3. **Multiplayer risks** (from reading code): the work order slides in for every player on each status change; only
   the caller decides; anyone can start the next shift; A3 swaps in front of players if someone is always within 20
   studs; A4 follows the nearest player.
4. **Later:** Mixamo NPC animation export (real A4 clips, customer acting), full Anomaly Director (escalation,
   cooldowns, variants), more anomalies (GDD wants 15 × 2 variants), battery and radiator faults, threat encounter,
   Further Inspection / Reject decisions, texture pass for the UI, pause-menu settings (none exist yet).
5. Optional offer made to the user: an online form version of the playtest questions.
