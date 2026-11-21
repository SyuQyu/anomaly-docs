# Car Repair Shop [ANOMALY]: vertical slice plan

Written 2026-11-18, from GDD v0.2. Place: 111351856377896 (universe 10777476810).

## 1. What the slice must prove

One question: **is it fun to do a normal repair, notice that something is wrong, and decide what to do about it?**

If that loop works with 5 anomalies, it will work with 97. If it doesn't, the Director, campaign and threat
systems won't save it. So the slice skips everything that does not help answer that question.

## 2. Scope

**In:**
- One short night shift, about 10 minutes, solo first (server-authoritative, so co-op can be switched on later).
- **3 customers in a row, same car model, same fault (flat tire).** Two are normal and one is anomalous; which
  one is random. Changed from the "1 customer" idea: with one customer there is no normal to compare against,
  and the GDD's main rule is that anomalies only read against a baseline.
- Arrival, keys, work order, repair, a final decision (**Release** or **Quarantine** only), pay and an end-of-shift report.
- 5 cheap anomalies, picked by a small weighted table (the Director's data format, without its full logic).

**Out (later phases):** the full Director (escalation, pacing, conflicts), Further Inspection / Reject, the threat
and downed/rescue, battery and radiator, economy and upgrades, story and campaign, perspective anomalies.

## 3. What the place has now

- A shop blockout at about x -138..-84, z 36..136: three bays on the front wall (x = -84), each with a `Gate` and
  a `RollingGate`, a back room at z ≈ 136, concrete walls, plus a Baseplate and Terrain.
- One R15 `Rig` with an `Animate` script at (-123, 0, 132).
- No scripts, GUIs, sounds or cars. ReplicatedStorage only holds MaterialVariants.
- Lighting is daytime (ClockTime 14.5, no fog). The slice needs night, fog and a PS1 grade.

## 4. Shift flow

```
Shift start (night, shop open, bay 1 door up)
  → Customer N drives/arrives at bay 1 and walks to the counter
  → Talk: their line + hand over keys → WORK ORDER card (name, plate, car colour, mileage, complaint)
  → Player inspects the car: checks tire pressures until the low one is found → FINDING written, DIAGNOSED
  → FIT THE WHEEL mini-game (jack → align → nuts in star order → lower) → REPAIRED
  → Verify: check the new tire's pressure → CHECKED (Release is locked until then)
  → Customer waits in the waiting room (sits, phone, checks watch...)
  → Player calls them back to the counter → DECISION: Release / Quarantine
  → Pay (or not) → they leave → next customer
After 3 customers → end-of-shift report: every decision, what was really going on, money earned
```

## 5. The 5 anomalies

Each one contradicts something the player can check: the work order, what they saw earlier, or the shop itself.

| # | Anomaly | What the player can check it against | Cost |
|---|---|---|---|
| A1 | **Wrong plate:** the car's plate does not match the work order | Work order card | Cheap (text swap) |
| A2 | **Mileage too low:** the odometer reads less than the work order says (or goes down after the repair) | Work order + dashboard | Cheap |
| A3 | **Different person comes back:** a different face/outfit comes to pick up, using the same name | First impression at drop-off | Medium (second avatar) |
| A4 | **Wrong body:** the customer walks mirrored (`Anom_Walk_Mirrored`) and sits perfectly still, not breathing (`Anom_Statue`) | Normal customers | Cheap (animation clips already made) |
| A5 | **The shop reacts:** the waiting-room clock runs backwards while they are there, and the radio switches to static | Earlier in the shift | Cheap |

An anomalous customer gets 1–2 of these, never all of them. Data lives in `AnomalyDefinitions` (id, category,
rarity weight, conflicts, apply/clear functions) so the full Director can read the same format later.

## 6. Decision outcomes (the GDD left these open; this is my proposal)

| | Normal customer | Anomalous customer |
|---|---|---|
| **Release** | Full pay + tip | Pay, but the report says what you let out (in the full game: consequences on a later shift) |
| **Quarantine** | No pay, reputation −1, the customer is angry | Bonus pay, "case file" entry |

The point: quarantining everyone has a cost, so the player has to really look.

## 7. Systems to build

Server (`ServerScriptService`), client (`StarterPlayerScripts`), shared rules and config in `ReplicatedStorage`.

| System | Job |
|---|---|
| `ShiftService` + `ShiftConfig` | Runs the night: customer queue, time, end report |
| `CustomerService` + `CustomerConfig` | Spawns a customer NPC, walks it between points (counter, waiting chairs, bay, exit), plays clips |
| `WorkOrderShared` | Generates the work order (name, plate, colour, mileage, complaint) and its "truth" |
| `AnomalyDefinitions` + `AnomalyService` | Weighted pick for the anomalous customer; applies/clears each anomaly |
| `VehicleService` | Spawns the car in bay 1, plate/odometer/flat tire, jack and wheel points |
| `WheelRepair` (port) | FIT THE WHEEL from ANMU Chapter 2 |
| `DecisionService` + GUI | Release / Quarantine, pay, reputation |
| Client UI | Work order card, decision panel, end report, interaction prompts |
| Atmosphere | Night lighting, fog, shop lights, rain/road ambience, radio, clock |

Instances (markers, GUIs, sounds, prompts) are made as real objects in Studio, not built in code.

## 8. What is reused

- **FIT THE WHEEL** (ANMU Chapter 2 DEV place 70637081826475): `RepairShared` GAMES.WHEEL rules,
  `RepairService` wheel session, `RepairWheelController`, `RepairWheelGui`, `RepairWheelAssets`, `CarJack`.
  This is a port, not a copy: it is tied to ANMU's story, inventory and car. **Chapter 2 must be open in Studio at
  the same time as this place** so I can read its source.
- **NPC animation library** (`AN_NPC_*`, 58 clips in Blender): walk, turns, talk, hand over keys (`KeysReleased`
  marker), pay (`PayGiven`), sit, phone, check watch, plus the anomaly clips. They still need **Phase 4, exporting
  them to Roblox**. Until then customers use a stand-in R15 rig with Roblox's default animations.
- **Object inspect view** from ANMU (§5ah) is the model for looking closely at the plate and odometer, if a plain
  close-up camera isn't enough.

## 9. Milestones

Each milestone ends with a solo Play test.

| | Milestone | Done when |
|---|---|---|
| **M0** ✅ | Night shop + one car | Bay 1 lit at night with fog; a car parked in bay 1 with a flat tire and a readable plate (done 2026-11-18, see PROGRESS.md) |
| **M1** ✅ | Customer + work order | An NPC walks in, talks, hands over keys; the work order card shows; they go and sit |
| **M2** ✅ | Tire repair | FIT THE WHEEL works on this car from start to finish |
| **M3** ✅ | Decision + shift | 3 customers in a row, Release/Quarantine, pay, end report. Also added the GDD's inspect (tire pressure diagnosis) and verify (pressure check after the repair) steps |
| **UI 1** ✅ | UI PRD pass 1 | HUD, service order, diagnostic scanner + tire gauge, tool row, repair panel, report, players list ([UI_PRD.md](UI_PRD.md)) |
| **UI 2** ✅ | UI PRD pass 2 | Design system ([UI_DESIGN_SYSTEM.md](UI_DESIGN_SYSTEM.md)), ledger and work order rebuilt, CCTV (CAM 01–04), Case File, menu |
| **M4** ✅ | Anomalies | One random customer is anomalous with 1–2 of A1–A5; the report reveals the truth. A4 uses a no-animation glide + head that follows you until the Mixamo clips are exported |
| **M5** | Playtest | You and friends play it and say whether spotting the anomaly was fun. Prep done: night notice, analytics events, guide in [PLAYTEST_M5.md](PLAYTEST_M5.md). Needs your publish + session |

M0 and M1 can start now. M2 needs ANMU Chapter 2 open. The real customer animations need the Blender export.

## 10. Decisions for you

1. **Car model:** your own, a Creator Store model, or a low-poly one made in Blender?
2. **Bay:** use the existing bay 1 (z ≈ 62) for the repair? The other two can stay closed for the slice.
3. **Code comments:** your ANMU rule says "no comments". Should the same apply here?
4. **Customers:** OK to use stand-in R15 rigs until the Mixamo characters are exported?
