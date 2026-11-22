# Gameplay loop handoff (master implementation prompt, 2026-11-21 → 22)

Gameplay place **82609083848662** (universe 10777476810). Built live through the Roblox Studio MCP by Aizu + Claude.
**Nothing is published.** Day-by-day detail and test logs: [PROGRESS.md](PROGRESS.md) (entries 2026-11-21 and
2026-11-22). Backup of every Shop script from before this work: `ServerStorage.ScriptBackups.2026-11-21_BeforeGameplayLoop`
(48 disabled ModuleScripts). The map, HUD and earlier systems were kept; nothing of the map was moved or deleted.

## The loop in one paragraph

Open the shutters → a car drives up the road and stops out front → the customer gets out, walks to you, talks
(greeting by personality, complaint) → you pick *What happened? / How long? / I'll take a look / Not available* →
accept = keys + work order, the car drives into a free bay (queues if all 3 are full), the customer sits in the
waiting room → inspect (gauge, scanner) → repair (tire, battery or radiator; progress is kept on the car) → rescan
to verify → ring the counter bell → the customer walks to the window, talks, the cash tray opens → stamp RELEASE
(they pay into the tray, the bank gets it, tray closes) or QUARANTINE (no pay, car held). An anomalous customer can
**lock** the tray (no payment possible, only quarantine resolves it), and an anomaly during the 2.6 s payment window
cancels the payment. After 3 customers: wages, shift report with the truth and the anomaly findings.

## Where things are

Server `ServerScriptService.ShopSystem`, shared `ReplicatedStorage.Shop`, client
`StarterPlayer.StarterPlayerScripts.ShopClient`. Live state = attributes on `ReplicatedStorage.Shop.State`
(`WorkOrder`, `Shift`, `ShiftLog`, `Workshop`, `CashierTray`, `CctvEvents`, `ShopOpen`, `CustomerWaiting`).
Start order in `ShopServer`: Economy, Cashier, AnomalyDirector, Upgrade, Staff, Countermeasure, Tool, Repair,
Workshop, Decision, Dialogue, WaitingRoom, ShopFront, Shift.

| Part | New | Changed (existing) |
|---|---|---|
| Arrival, bays, dialogue | `BayService`, `DialogueService`, `DialogueGui.Choices`, markers `Markers.Arrival`, `Bay2CarSpot`, `Bay3CarSpot` | `CustomerService` (state machine), `ShiftService.serve`, `VehicleService` (`DriveAlong`, `Rebase`), `CustomerConfig`, `ShiftConfig`, `DialogueController` |
| Repairs | `ProcedureShared`, `ProcedureService`, `ProcedureUI`, `ProcedureController`, `Root.Engine` + `EnginePrompt` on car templates | `WorkshopService` (scan diagnoses/verifies, tire stock), `RepairConfig`, `ShiftShared` copy, `WorkOrderConfig` |
| Cashier | `Front.Cashier` model, `CashierService`, `CashierConfig` | `DecisionService` (refuses release when `TrayLocked`), `DecisionController` (greyed stamp) |
| Anomaly Director | `AnomalyDirector`, `AnomalyCatalog`, `CctvAnomalyController`, `ServerStorage.AnomalyTemplates`, `AnomalyCctv`, `AnomalyDebug` (Studio only) | `AnomalyConfig.DIRECTOR`, `AnomalyService.Reveal`, `CCTVController` |
| Tycoon + staff | `TycoonConfig`, `EconomyService`, `UpgradeService`, `StaffService`, `WorkshopShopUI` + controller, `ShopTerminal`, `StaffTemplates`, `Markers.Staff`, `EconomyDebug` (Studio only) | `PlayerDataConfig.TEMPLATE.Workshop`, `ShiftController` (HUD cash = bank) |
| Countermeasure | `CountermeasureService`, `CountermeasureController`, remote `Countermeasure` | `ShiftShared` notices |

### Customer states (`CustomerConfig.STATES`, model attribute `State`, car attribute `CustomerState`)

VehicleArriving → VehicleStopping → CustomerExiting → CustomerApproachingPlayer → AwaitingInteraction →
JobOffered → JobAccepted / JobDeclined → (Waiting) → CustomerCalled → CustomerApproachingCashier → CashierDialogue →
Payment → TransactionCompleted / TransactionLocked → CustomerDeparting.

### Anomaly Director

Data-driven (`AnomalyCatalog`), tuned in `AnomalyConfig.DIRECTOR`: chance per trigger, weights, per-event cooldown,
variants, history, anti-repetition (last 3), conflicts, max 2 subtle + 1 major at once, global and major gaps,
escalation by customer and shift, idle loop. One seed per shift (`DIRECTOR.TEST_SEED` to replay; current seed in
`ServerStorage` attribute `AnomalyShiftSeed`). Triggers: arrival, dialogue, inspection, repair steps, after repair,
before cashier, cashier dialogue, cashier transaction, CCTV watching, idle. Customer-bound events only fire on the
shift's anomalous customer (so the report's truth stays consistent); the old A1–A5 are that customer's built-in
profile. "Manifest" events lock the tray; subtle data anomalies don't. CCTV-only events are drawn on the client
under the camera only while that camera is on screen; they never exist on the server. Debug forcing only through
`ServerStorage.AnomalyDebug` (BindableFunction, connected only in Studio; no remote, players can't reach it).

Catalog: WrongLicensePlate, PassengerShadow, RepeatedDialogue, WrongReflection, BatterySignal, MovingTool,
UnknownFigure (CCTV only), FutureFootage (CCTV only), WrongCustomerRecord, SilentPayment, EmptyFootsteps,
MovingEquipment, plus Lurker (physical threat that grabs, can be shoved).

### Economy, staff, countermeasure

All prices and numbers in `ReplicatedStorage.Shop.TycoonConfig`. Bank, stock, rack, staff and countermeasure are one
shared workshop, saved in the **host's** ProfileStore data under `Workshop` (host = first player whose data loads).
Purchases go through RemoteFunction `WorkshopPurchase` (server checks: at the rack, rate limit, money, capacity,
rack level). Rack I holds 6 (tires, batteries), Rack II ($400) holds 14 and adds radiators, which is also what
makes overheating cars start arriving. Mechanic ($300, $40/shift) does tire and battery jobs only, never talks to
customers or touches the till. Security guard ($350, $45/shift) patrols and watches CCTV, tracks at most
`MaxTrackedAnomalies` = 2. Countermeasure ($600): G / R1 / touch SHOVE, server-checked (owned, alive, cooldown 10 s,
reach 8, in front of you), only works on entities marked `Vulnerable` (the Lurker), never on people.

## Final delivery report

### Implemented and tested (solo Studio Play)

- Arrival → stop → customer walks over → dialogue options → accept → bay → waiting room. Decline path.
- Bay reservation and queue code path (bays 1–3); only bay 1 was filled in tests.
- Battery procedure (5 steps) and radiator procedure (6 steps, jack up/down), stock taken from the rack, rescan Verified.
- Cashier: bell → customer walks bench → window → dialogue → tray opens → pay → tray closes; bank updated.
- Mid-payment interrupt cancels the payment and locks the tray; locked tray refuses RELEASE (server and greyed
  stamp), QUARANTINE resolves it.
- Full natural 3-customer shift to the end-of-shift report (quarantined anomaly + 2 paid jobs, findings in notes).
- Director: forced PassengerShadow, UnknownFigure (client-only on CAM 02), MovingEquipment, EmptyFootsteps,
  FutureFootage (CAM 01 only), MovingTool, RepeatedDialogue (tray locked), Lurker, SilentPayment; natural firing
  seen for PassengerShadow, WrongReflection, MovingEquipment, EmptyFootsteps, WrongCustomerRecord, BatterySignal.
- Shop terminal purchases and refusals; mechanic finished a battery job; guard tracked 2 sources and ignored a 3rd.
- Countermeasure: locked before purchase, bound after, hit + repel + cooldown on a real G press.

### Implemented, not tested

- **Co-op with 2–4 players** (Studio can't run two players). Reviewed in code: server is authoritative everywhere;
  dialogue, decisions and purchases are validated per player (token, distance, rate limit); if the deciding player
  dies, leaves or times out, the decision falls back to "Later" and the bell re-arms for anyone. Needs a live test:
  two players at the window/bell, one player buying while another repairs, host leaving.
- **Saves across sessions**: Studio here has no DataStore API access ("data will not be saved"). Code writes the
  workshop into the host's profile on every change. Needs a live check: buy something, rejoin, bank/rack/staff kept.
- WrongLicensePlate in a live shift (its Run/Finding were tested in Edit on a real car; in play it was correctly
  skipped because that customer's profile already had the plate anomaly).
- BatterySignal's Headlights variant, WrongReflection's NoFace / FacingAway variants, Lurker Rusher variant.
- Wages actually charged (no staff hired in the full-shift test; code path seen in the report as Wages 0).
- Security guard reacting to a Lurker; mechanic pausing while a threat is active.
- Phones and gamepad (touch SHOVE button, shop UI, stamp buttons, dialogue options).
- Multiple bays filled at once with the queue actually waiting.
- The report-notes punctuation fix (code change only).

### Planned / not built

- Anything not in the master prompt's phases. No new map areas.
- Host hand-over: if the host leaves, the session keeps going but is no longer saved (warning in the server log).
  A different player becoming the save owner was not built (it would overwrite their own workshop).

### Blocked

- Multiplayer and DataStore testing inside Studio (see above): needs a published DEV copy and real players. The
  owner publishes; nothing was published.

### Known issues / watch in playtests

- A Lurker that gets within 3.4 studs grabs at once, before a shove can land if you walk into it.
- The guard's CCTV-desk patrol point sits behind the office door (he stands outside but counts as at the desk).
- The shop header bank colour is set directly, not through `UITheme`.
- `AnomalyConfig.DIRECTOR.LOG = true` prints `[Director]` lines to the server log; turn off for release if unwanted.
- Seen once each, not reproduced: a stray "Later" choice right after the stamps opened; two cars in one shift that
  looked alike (same colour/model, similar plates; the generator is a plain random draw, FutureFootage can force
  the next car's look).
- Test helpers left on purpose (Studio only, not reachable by players): `ServerStorage.AnomalyDebug`,
  `ServerStorage.EconomyDebug`. Test switches `ShiftConfig.FORCE_FAULT` and `AnomalyConfig.TEST_INDEX` are nil.

## Testing tips (MCP)

- `execute_luau` runs in its own VM: requiring a game module there gives a separate copy. Use the BindableFunctions
  above (Server) to force events or add money.
- The custom prompt controller only shows the prompt the camera looks at, and the first-person camera overrides a
  one-off `Camera.CFrame`. Hold the aim with `RunService:BindToRenderStep(..., Last + 100)` while calling
  `InputHoldBegin/End`, then unbind.
- Server scripts can't be searched or read with the MCP while Play is running; stop Play first.
- Stamp buttons: `LocalPlayer.PlayerGui.WorkOrderUI.Clipboard.Paper.Columns.Right.Decide.Stamps.ReleaseButton` /
  `QuarantineButton` (click with `user_mouse_input`). Dialogue options: keys 1–4.
