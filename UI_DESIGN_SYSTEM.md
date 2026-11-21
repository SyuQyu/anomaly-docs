# Car Repair Shop [ANOMALY]: UI design system, audit and plan

Written 2026-11-18 from the two reference sheets (the first collage and the "UI DESIGN SHEETS" board) and
`UI_PRD.md`. The references set the art direction. Their text (names, prices, "ANOMALY DETECTED") is not game data.

## Phase 1: what the references say

**One rule across every sheet:** each screen is a real object from a 1990s workshop. Paper things look like paper,
electronic things look like hardware, and the HUD is almost nothing.

| | Paper interfaces (Work Order, Case File, End of Shift) | Device interfaces (Scanner, CCTV, Repair, HUD, Pause) |
|---|---|---|
| Surface | Aged paper `#C5BEA8`, darker paper for second sheets, slight edge shading | Charcoal / panel `#171A18` / `#292E29`, a bezel around a screen |
| Ink | Near-black ink, faded ink for labels | CRT green `#A8C79A` on near-black, or light grey on panel |
| Type | Condensed bold titles; mono for numbers, IDs and times; sans for prose | Mono for everything on a screen; condensed caps for hardware labels |
| Lines | 1 px rules between rows, a 2 px rule under headers, boxes around summary numbers | Thin olive/sage lines, inset screen frame |
| Marks | A rotated rubber stamp, checkboxes, a gear logo, a paper clip | LEDs, REC dot, battery icon, function-key labels `[F1]` |
| Corners | Square | Square, or a small radius on hardware shells only |
| Colour use | Red only for a stamp or one critical value | Green for data, amber for "check this", red for REC / critical |

**Hierarchy seen in every reference:**
1. Identity line (whose document/device: "JOTHEM AUTO REPAIR", "JAS DIAGNOSTIC SYSTEM", "CAM 02 - Service Bay").
2. The document number or status at the top right (WORK ORDER No., SHIFT REPORT No., REC).
3. Key facts in label : value rows, aligned on a colon column.
4. Grouped detail below a section heading, then the one action or verdict (stamp, Total Payment, OK).

**Layouts are different per screen:** the work order is a two-column form, the scanner is a screen + button row +
side buttons, CCTV is a big feed + a vertical camera list, the case file is a folder with tabs and a pinned photo,
end of shift is a ledger with four summary boxes and a table, pause is a plain list on the dark world.

**Navigation patterns:** documents open/close with one key (J) or an X; devices use labelled function keys
(`[F1] Help [F2] Details [ESC] Back`); CCTV picks cameras from a list (or 1-4); the case file switches tabs
(Evidence / Records / Notes); the pause menu is a vertical list with the selected row filled.

**States:** normal (ink / green), selected (filled bar, e.g. CAM 02 and "Resume"), warning (amber text), critical
(muted red), disabled (faded ink / dimmed). Anomaly state = the same layout with wrong content (PRD §12).

**Not used from the references:** the red "ANOMALY DETECTED" alert (sheet 9). The GDD forbids it and it stays out.

## Phase 2: design system (Roblox)

### Colour tokens (`ReplicatedStorage.Shop.UITheme.Colors`)
| Token | Hex | Use |
|---|---|---|
| Charcoal | 171A18 | screen backgrounds, device shells |
| Panel | 292E29 | HUD boxes, device buttons |
| Olive | 303A31 | strips, selected rows on dark |
| Paper / PaperDark | C5BEA8 / AFA58D | documents / second sheets, stat boxes |
| Ink / InkFaded | 24221D / 5C5647 | print / labels on paper |
| Light / LightDim | D9D3C0 / 8C8A7C | text on dark |
| Sage | 9A9D78 | normal accents, OK |
| Brass | A18E61 | highlights, selected outlines |
| Crt / CrtDim / CrtScreen | A8C79A / 5F7757 / 0D150F | scanner and CCTV screens |
| Amber | C19B53 | warnings, objective title |
| Red | A34B43 | stamps, REC, critical only |

### Type scale (design px at a 720 px tall screen; the UIScale fit multiplies them)
| Role | Font | Sizes |
|---|---|---|
| Document title | Oswald Bold | 30 |
| Section heading | Oswald Bold | 15-16, caps |
| Field label | RobotoMono | 14 |
| Field value / reading | RobotoMono Bold | 15-26 |
| Prose (complaint, notes) | Source Sans Pro | 17 (italic for quotes) |
| Stamp | Special Elite | 22-28, rotated -6° |
| HUD numbers | RobotoMono Bold | 16-26 |

**Floor:** nothing smaller than 13 design px, and documents never scale below 0.72, so on-screen text stays
at 10 px or more on a phone (Roblox units are points there). When a document can't fit at that scale, its body
scrolls instead of shrinking further.

### Spacing, lines, sizes
- Spacing steps: 4, 8, 12, 16, 24, 32. Paper margins 24, device bezels 14-18.
- Rules: 1 px ink at 0.65 transparency between rows; 2 px ink under a document header.
- Boxes: 1 px stroke, no corner radius on paper. Device shells may have 8 px corners, screens 2 px.
- Touch targets: 44 px minimum after scaling.
- Modal sizes: ledger 760×500, work order 680×440, scanner 600×400, CCTV 860×500, case file 760×480,
  so all of them fit an iPhone landscape (750×381) at scale ≥ 0.72.

### Components (template instances in `ReplicatedStorage.Shop.UITemplates`, cloned by controllers)
Field row (label : value), Section heading, Rule, Checkbox line, Stat box, Ledger row, Printed stamp, Key cap,
Device button (key + label), LED, Camera button, Folder tab, Pause row. Each has normal / hover / selected /
disabled colours from the tokens; warning and critical use Amber / Red on the same layout.

### Module identities
- **End of Shift:** a printed ledger page: letterhead, "SHIFT REPORT No.", four summary boxes, a ruled service
  log, shift notes, total and a PAID/CLOSED stamp.
- **Work Order:** a landscape service form on a clipboard: letterhead, order number and stamp at the top right,
  left column customer/vehicle facts and complaint, right column inspection checklist, findings and tasks.
- **Main HUD:** four small corner blocks only (shift clock + objective, cash + job, prompt, tools).
- **Scanner:** a handheld device: label strip, CRT screen with readings, side buttons and LEDs, function keys.
- **Repair:** a compact procedure card: title, step x/y, numbered steps, tool line, progress.
- **CCTV:** an old monitor: grey feed, camera ID + timestamp burnt in, REC, camera list on the right.
- **Case File:** a manila folder with tabs, a pinned photo, record fields and a status line.
- **Players:** a crew roster sheet on a panel.
- **Pause:** a short list on the dimmed world.

## Phase 3: audit of what is built (pass 1)

Screenshots taken in Play on 2026-11-18 at 1222×591.

**Visual**
1. HUD text renders at 10-11 px (13 px design × 0.82 fit): "REP 0", "JOB 1/3", tool keys and the shift label are
   hard to read. Cash has no box (the references frame it).
2. End of Shift is one flat paper rectangle: no letterhead or number, no summary boxes, 170 px of empty space
   under three rows, totals in one weak line, no stamp, no notes. Doesn't read as a ledger.
3. Work Order is a narrow portrait clipboard shrunk to 0.55: body text ~9 px, everything in one long column that
   scrolls, and the stamp sits over the findings text.
4. Scanner is close to the target but the device has no side buttons/LEDs, the brand label is 12 px and the screen
   title is not the device identity.
5. Repair panel has 120 px of empty space under the hint and a rounded "i" badge that matches nothing else.
6. Players list header and rows are fine but the panel is a generic dark card.
7. CCTV, Case File and Pause don't exist.

**Data / logic**
1. The shift log has no vehicle colour, fault or arrival time, so the ledger can't show a "condition" or a case
   record. (Server change: add Colour, Fault, Minutes, Mileage to each entry. Nothing else in the rules changes.)
2. Money is "$0.00" in the HUD but "$152" in the report. One format: "$152.00".
3. "Unresolved cases" isn't counted. Definition used: an anomalous car that was released.
4. The report's "What it was" column reveals the truth: correct, it is only shown after the shift.
5. Nothing broken in the interactions found during the audit.

## Phase 4: plan

**Architecture**
- Keep one ScreenGui per module (PRD §15): MainHUD, WorkOrderUI, DiagnosticUI, RepairUI, ShiftReportUI,
  CCTVUI (new), CaseFileUI (new), CooperativeUI, PauseMenu (new).
- New client module `ShopClient.UIFit`: one place for the fit-to-screen scale (design size, floor 0.72, ceiling 1.15).
- New `ReplicatedStorage.Shop.UITemplates` folder for the shared row/box/stamp/key templates.
- New client controllers: `CCTVController`, `CaseFileController`, `PauseController`.
- Server: `ShiftService` log entry gains Colour/Fault/Minutes/Mileage; new `CctvConfig` camera markers in
  `Workspace.Markers.CCTV` (Cam01-04 parts); a monitor prompt on the office desk.

**Unique layouts:** End of Shift, Work Order, Scanner, CCTV, Case File. **Shared parts:** field rows, stat boxes,
stamps, key caps, rules, device buttons.

**Scripts to change:** ShiftController (report + HUD), WorkOrderController, ScannerController (layout names only),
RepairWheelController (panel only), CrewController (styling), ShopClient (start new controllers), ShiftService
(log fields), ShopClientConfig + ShiftShared COPY (new strings and sizes).

**Responsive:** design at 720 px height; `UIFit` scales each block by the screen; documents keep a 0.72 floor and
scroll inside when they still don't fit; HUD corners keep a 0.8 floor; touch gets X buttons and tap targets ≥ 44.

**Order:** End of Shift → Work Order → HUD → Scanner → Repair → CCTV → Case File → Players → Pause, testing each
in Play at desktop size and at an iPhone landscape size before moving on.

## Phase 5: result (2026-11-18)

All nine are built and Play-tested solo; details and limits in [PROGRESS.md](PROGRESS.md). Differences from the plan:
- Templates stayed inside the ScreenGui that uses them (RowTemplate, LineTemplate, CamTemplate, CaseTemplate…)
  instead of a shared `UITemplates` folder: each one is used by a single screen so far.
- The menu is not a pause: Roblox servers keep running, so it says so.
- CCTV uses the real camera at fixed points, not ViewportFrames (cheaper and it shows live NPCs/cars).
