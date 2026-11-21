# PRODUCT REQUIREMENTS DOCUMENT
## CAR REPAIR SHOP [ANOMALY] — WORKSHOP INDUSTRIAL UI

**Developer:** Jothem Studio · **Platform:** Roblox · **Version:** 0.2 · **Status:** Ready for UI Prototyping
(Shared by the user 2026-11-18 with a reference collage: HUD, service order clipboard, JAS diagnostic scanner,
battery replacement panel, CCTV CAM 01–04, case file, players (4/4), paused menu, and an "ANOMALY DETECTED" banner.)

**Decisions taken with the user (2026-11-18):**
- Build all 7 MVP modules in two passes. Pass 1: HUD, Service Order (it takes over the decision), Diagnostic Scanner,
  repair panel, report and the co-op list. Pass 2: CCTV and Case File. The user reviews after pass 1.
- **No "ANOMALY DETECTED" banner.** The GDD says never to show it, and §6.5 says the scanner is not an anomaly detector.
  Anomalies only appear as wrong data inside the normal screens.
- **Real tool selection** (§7.5): a tool row, and the wrong tool gets feedback.
- **UI built from shapes, colours and fonts first.** Texture images can come later.

---

## 1. Product overview
Purpose: UI consistent with a night-workshop PS1 horror sim. It should look like real workshop equipment (automotive
service forms, old CRT diagnostic monitors, industrial control panels, CCTV, mechanic paperwork, old workshop
computers, analog security equipment), professional and readable in normal situations. Specific elements may be
disturbed deliberately when an anomaly happens.

Objectives:
1. A visual identity that differs from typical Roblox horror UI.
2. Every screen has its own function and character.
3. Keep focus on the 3D world.
4. Mechanic work should feel authentic.
5. Solo and co-op, 1–4 players.
6. Anomalies tie into the interface in context.
7. Everything works on PC and mobile.

Philosophy: **"Every interface belongs to the workshop."** The Work Order is a physical service form, the scanner is a
diagnostic device, the CCTV is an old security system, and the Case File is an investigation archive. No shared panel
template with only the colour and title changed.

## 2. Art direction
Style: Workshop Industrial / Analog Horror. Dark industrial surfaces, worn paper, aged plastic, monochrome CRT, subtle
analog noise, low-res detail, technical type, fine dividers, restrained warnings, realistic spacing.
Avoid: generic rounded cards, glassmorphism, neon gradients, too many red borders, random glitches, too many
scanlines, decorative horror icons, unnecessary animation, too many background textures.

| Token | Hex | Usage |
|---|---|---|
| Charcoal | #171A18 | Main background |
| Industrial Panel | #292E29 | Control surfaces |
| Deep Olive | #303A31 | Secondary panels |
| Aged Paper | #C5BEA8 | Documents |
| Paper Dark | #AFA58D | Secondary document surfaces |
| Muted Sage | #9A9D78 | Normal accents |
| Brass | #A18E61 | Highlights |
| CRT Green | #A8C79A | Diagnostic data |
| Warning Amber | #C19B53 | Warnings / inconsistent info |
| Muted Red | #A34B43 | Critical status |

Typography: Display (condensed industrial bold: titles), Technical (monospace: timestamps, readings, IDs, part
numbers), Body (simple sans-serif: descriptions, instructions, customer info). Retro type is an accent only; no pixel
font everywhere.
Shapes: rectangles, thin borders, square or slightly irregular corners, document layouts, technical separators, small
indicators. Each screen's layout follows its physical inspiration.

## 3. Modules
1. Main HUD
2. Service Order
3. Diagnostic Scanner
4. Repair Interaction
5. CCTV
6. Case File
7. Multiplayer Status
8. Pause/Settings

Anomaly presentation is integrated into these modules, not a separate dashboard.

## 4. Main HUD
- **Top-left:** shift, in-game time, objective.
- **Top-right:** cash, optional job info.
- **Bottom-left:** interaction prompt and contextual instructions.
- **Bottom-right:** equipped tool and tool selection.

Minimal footprint. Anomaly states (only from explicit anomaly events): the clock stops or shows a wrong time, the
objective text changes, the work order number is inconsistent, an unexpected player name, or a prompt references
something that doesn't exist.

## 5. Service Order
A physical service document. Visual: warm aged paper, dark print, thin form dividers, a mechanical service stamp,
optional handwritten notes, compact vehicle ID.

Contents:
- **Header:** workshop identity, title, order number, status.
- **Vehicle:** model, plate, customer, arrival time.
- **Service:** complaint, requested service, inspection checklist, findings, diagnosis, repair tasks, final decision.

Interactions: open/close, read the complaint and vehicle info, track inspection, see repair instructions, confirm the
repair, submit the vehicle disposition.

Anomalies change the content, never the layout: the name changes, the order number changes, an extra repair request
appears, a future date, previous work history appears, the complaint changes after being read.

## 6. Diagnostic Scanner
A late-1990s automotive diagnostic device: CRT green monochrome, monospace, device buttons, a hardware frame, simple
menus.

Shows: vehicle ID, battery voltage, engine temperature, oil pressure, electrical status, fault codes, scan status,
results.

Interactions: start a scan, rescan, details, navigate readings, back.

Anomalies: unregistered signals, impossible temperatures, unknown component IDs, inconsistent vehicle ID, readings
that change while the scanner is off. **It is not an anomaly detector.**

## 7. Repair Interaction
Contextual and compact. Shows the repair title, current task, required tool, required part, procedure steps,
interaction status and completion feedback.

Example procedure (battery):
1. Secure the vehicle.
2. Disconnect the negative terminal.
3. Remove the old battery.
4. Install the new one.
5. Reconnect.
6. Verify voltage.

Requirements: progress updates on success, feedback on wrong actions, **the selected tool must match the
procedure**, the vehicle stays visible, and progress syncs between players.

## 8. CCTV
Monochrome feeds, camera ID, timestamp, REC indicator, camera selection, subtle noise and low-res treatment.

Cameras: CAM 01 Parking, CAM 02 Service Bay, CAM 03 Waiting Room, CAM 04 Rear Entrance.

Interactions: select a camera, live feed, recordings where supported, back.

Anomalies (server events only): an unidentified figure, a delayed feed, missing frames, an unexpected player position,
a vehicle moving with no driver, footage of an event that hasn't happened yet.

## 9. Case File
Physical folders, document headers, photos, handwritten notes, stamps, record references. No collectible grids.

Contents: case ID, related work orders, customer records, vehicle history, photos, CCTV records, audio records, notes,
evidence status.

Interactions: open a case, examine evidence, compare records, review anomaly events, view unresolved cases. Player
notes may come later.

## 10. Multiplayer Status
Shows each player's name, activity, assigned work order, area, status and downed state.

Shared between players: work orders, repair progress, inventory. Also: ping, interaction ownership, rescue status.

Perspective anomalies may show different players different things; the UI must not falsely suggest that a player is
disconnected.

## 11. Pause/Settings
Resume, Settings, Controls, Accessibility, Leave Shift.

- **Graphics:** quality, visual effects, camera shake, film grain, chromatic aberration.
- **Audio:** master, music, ambient, effects, voice.
- **Accessibility:** subtitles on/off, subtitle size, prompt size, flashing reduction, shake reduction.
- **Gameplay:** interaction sensitivity, camera sensitivity, remapping.

Decorative effects must be adjustable or suppressible.

## 12. Anomaly UI system
Anomalies affect the UI without making it unusable. Possible effects: wrong info, changed work order data, unregistered
diagnostic results, distorted CCTV, unexpected archive entries, a wrong clock, missing content, audio transcript
discrepancies.

Levels:
- **Subtle:** one wrong field, a brief flicker, a small timestamp error.
- **Suspicious:** several inconsistent fields, an unexpected record, distorted CCTV.
- **Critical:** strong interference, unusual content, a warning state, temporary loss of non-essential info. Must never
  block essential actions.

Everything is driven by the Anomaly Director. No independent random glitches.

## 13. Responsive
- **PC:** compact HUD, document layouts, mouse, shortcuts, clear prompts.
- **Mobile:** bigger touch targets, simpler navigation, scrollable documents, contextual buttons, less obstruction.
- Every essential repair must be possible on both. Nothing critical may depend on hover.

## 14. Components
Industrial Header, Service Form, Printed Stamp, Technical Reading, Diagnostic Line, Status Label, Repair Step, Camera
Feed Frame, Evidence Document, Player Status Row, Interaction Prompt, Warning Banner.

Each component has normal, hover, active and disabled states, plus error and anomaly states where they apply. No single
card template for every module.

Quality: consistent type and spacing, clean alignment, clear hierarchy, little decoration, no overlap, readable,
enough contrast, no stretched textures.

## 15. Roblox implementation
ScreenGuis: MainHUD, WorkOrderUI, DiagnosticUI, RepairUI, CCTVUI, CaseFileUI, CooperativeUI, PauseMenu. ModuleScripts
for the theme, components, navigation, UI state and prompts.

- **Server:** work order state, repair validation, vehicle condition, anomaly state, evidence, payment, shared
  progress.
- **Client:** presentation, input, camera effects, local audio, perspective anomalies. The client never decides
  payment, repair success or anomaly selection.

Performance: event-driven, no polling, reuse elements, few image effects, mobile-sized textures, a controlled instance
count.

## 16. MVP scope
Main HUD, Work Order, Diagnostic Scanner, Repair Interaction, CCTV, basic Case File, co-op status.

Anomaly UI tests:
- one changed work order field
- one suspicious diagnostic reading
- one CCTV discrepancy
- one clock anomaly

## 17. Acceptance
- All modules work, and each has its own identity.
- The work order is easy to read, scanner readings are understandable, and repair steps are clear.
- CCTV selection works, case evidence is organised, and multiplayer status is accurate.
- Anomaly effects are event-driven and never block play.
- Desktop and mobile are usable, styling is consistent, and nothing looks like a generic dashboard template.

## 18. Final direction
It should look like a real workshop system from another time. The Service Order feels like paper, the scanner like
hardware, the CCTV like an old security system, and the Case File like an archive. The HUD is nearly invisible in normal
play. When an anomaly appears, these familiar interfaces become unreliable in subtle, deliberate ways. **Not a horror
game UI, but a real workshop interface slowly becoming part of the horror.**
