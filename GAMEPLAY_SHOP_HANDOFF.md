# Car Repair Shop [ANOMALY]: cars, customers, shop front, HUD fixes (handoff 3)

Written 2026-11-21. Read `SESSION_HANDOFF.md` (base game) and `LOBBY_MATCHMAKING_HANDOFF.md` (lobby, matchmaking,
data, UI pass) first. This file covers what came after: imported test cars, real customer cars with random paint
and plates, the shop front (shutters, door, control panel, "open the shop" start), the paper night notice and the
HUD auto-size fix. Built live in Studio over the Roblox MCP. **Nothing saved, nothing published** as of this file.

## 1. Test cars (assets, test only)

| Folder | Car | Source / licence | Notes |
| --- | --- | --- | --- |
| `assets/anomaly_van_test` | VW T3 van | unlicensed redistribution | lobby vans, see handoff 2 §7 |
| `assets/anomaly_bmw_test` | BMW 3 Touring (F31) | licence not confirmed | logos removed |
| `assets/anomaly_slk_test` | Mercedes SLK 55 AMG | **Forza Motorsport 7 rip** | never publish with it |
| `assets/anomaly_camry_test` | Toyota Camry XV80 | licence not confirmed | logos removed, right-hand drive |

Each folder has a `.blend`, an `.fbx` for the Roblox importer and a README (parts, hinge pivots, lights).
All four share one convention: front = −Y in Blender, vehicle left = +X, metres, wheels on z = 0, every door /
hood / boot is a group with its hinge as the pivot, each light is its own part, tyre and rim are separate.
The FBX files carry no textures; colours are set per part name in Studio after import.

## 2. Customer cars

- Templates: `ServerStorage.VehicleTemplates/Estate` (BMW), `Roadster` (SLK), `Saloon` (Camry), plus the old
  placeholder `Sedan` (kept, no longer picked). Generic names on purpose: the work order reads "Blue Estate".
- Each template follows the Sedan contract: invisible anchored `Root` (y 2.2 above the ground pivot) with
  `Hub_/Jack_/Contact_/Prompt_<FL|FR|RL|RR>` attachments, `Scan` attachment, `EngineSound`; `Wheels/WheelFL..RR`
  (pivot = hub, `Tire` + `Rim`, attributes `Pressure`, `Flat`); `Body` model with every part welded to `Root`.
  Door / hood / boot groups keep their hinge pivots (doors do not animate yet).
- Paint: every part with attribute `Paint = true` gets the spec colour. Plates: every `SurfaceGui` named
  `PlateGui` gets the plate text (EU style, built in Studio).
- `ShiftConfig.VEHICLE_TEMPLATES` = the pool; `ShiftService.makeSpec` picks one at random (`spec.Template`) and
  one of 10 colours (`ShiftConfig.COLORS`). Plate format unchanged.
- `VehicleService`: `Spawn` sets attribute `Template`, paints by attribute, writes all plates; `FitWheel` clones
  the car's **own** template wheel (falls back to `RepairAssets.SpareWheel`); `FadeOut` also fades decals.
- Glass matches the lobby vans: Glass material, `#2F3B42`, transparency 0.75, reflectance 0.1.
- Lobby vans (`LobbyCars/CAR 01..03`, `VanTemplate`) got EU plates (`Plate_Front`, `Plate_Rear`).

## 3. Office restored

`Workspace.ShopSetup.Office` (needed by `WaitingRoomService` and `CustomerService`) was in `ServerStorage` after
the map swap. Moved back and fitted to the new map:
- `Office.Waiting` chairs = invisible `Seat`s sitting exactly on the map's own bench seats (`Garage.Seat`).
- `WaitingProps.WallClock` on the waiting-room wall, `Radio` on the bench end, `CctvMonitor` on the service
  window ledge facing into the office.
- The old counter and chair visuals are in `ServerStorage.OfficeLegacy` (not deleted).

## 4. Shop front: shutters, door, panel

Owner: `ServerScriptService.ShopSystem.ShopFrontService` (+ `ShopFrontConfig`). Started from `ShopServer`.

- **Shutters** are the map's own parts, found by CollectionService tag `ShopShutter`:
  the six `Garage.Rolling.RollingGate` strips (group `Bays`) and `Workspace.WindowShutter` (group `Window`).
  A shutter opens/closes by stretching along its **own Y axis** (the green scale handle) with one edge fixed.
  Attributes on each part: `Group`, `OpenSize`, `ClosedSize`, `FixedSide` (+1 top/right edge fixed, −1 the other),
  `StartOpen`. Bays: 1.9 ↔ 9.75 (the two strips of a bay meet in the middle). Window: 1.9 ↔ 5.15 (down to the ledge).
- **Panel** `Workspace.ShopSetup.Front.ShutterPanel` on the office wall left of the window (seen from inside):
  steel box, yellow `SHUTTER CONTROL` header, two buttons `Bays` and `Window` (label plate, lamp, chrome bezel,
  cap that presses in). Lamp colours = panel attributes `OpenColor` / `ClosedColor`. The E prompt goes to the
  button the camera is looking at.
- **Office door** `Front.OfficeDoor`: hinge on the side away from the handle (`Door.PivotOffset`), swings 88°
  out into the hallway (attribute `OpenAngle`), prompt `DoorPrompt` (E, range 4).
- **Shift start:** bays start open, window starts closed. `ShiftService` waits on
  `ShopFrontService.WaitUntilOpen()` (bays and window both open) before every customer, and calls `SetBusy(true)`
  while a customer is in: the bays and window then cannot close (prompt shows "Locked", notice
  "Locked while a customer is in."). State attribute `ShopOpen` on `ReplicatedStorage.Shop.State`.
- **Guidance:** objective "Open the shop: use the shutter panel in the office" while closed;
  `ShopGuideController` (client) shows the `Guide` billboard ("SHUTTER PANEL ▼") over the panel.
- Wording lives in `ShiftShared.COPY.Shop`, `Objectives.OpenShop`, `Notices.ShutterLocked`, briefing rule 1.

## 5. Night notice as paper

`StarterGui.BriefingUI.Dim.Sheet.PaperHolder` (same structure as `ShiftReportUI`): 9-slice aged paper
`96632668928135`, tiled grain, drop shadow, two tape strips, coffee ring `89735252671740`. Both images generated
procedurally (NumPy/Pillow, no AI, no text); provenance in the GUI attribute `TextureProvenance`.
`BriefingController` reads `sheet.PaperHolder.Paper`.

## 6. HUD auto-size fix (the "bar that keeps stretching")

Cause: a box with `AutomaticSize` grew every relayout because its decorations were sized `1 + offset` to cover
the padding, and a full-size wrapper with children inside makes AutomaticSize unstable (measured: 1,143 px).
Rule from now on: inside an auto-sized box, decorations are **direct children at exactly `(1,0,1,0)`**; padding
goes on an inner element; never nest scale-sized frames.
- `MainHUD.BottomLeft.Prompt`: padding moved to `Content`; `Fill` moved out of `Hold` to a direct child
  (`PromptController` reads its height from the template).
- `BottomLeft.Notice` and `TopRight.Cash` are now `Frame` + inner `Label` (`RepairController`,
  `ShiftController` updated). `TopLeft.ShiftBox` labels moved into `Body`.
- Verified in Studio: all four boxes grow and shrink with their text; the prompt stays 104 px while the hold
  bar fills. **The lobby HUD was not scanned** (its Studio was in Play mode).

## 7. Open items

1. **Save both places.** Nothing from this file is saved.
2. **Not tested in a real playtest** (the MCP play button got stuck): shutters stretching at runtime, BAYS /
   WINDOW buttons on the new strips, the prompt hold bar in game. Studio previews of open and closed shapes passed.
3. Scan and fix the lobby HUD for the same auto-size pattern (`LobbyHud`).
4. Radio: it already plays (`Radio.Body.Music`, volume 0.45, heard within 40 studs). Unclear whether it should be
   louder or silent; ask before changing.
5. Car doors / hood / boot and light switching are not animated or wired (pivots and light parts are ready).
6. A full shift (talk → repair → release/quarantine → three customers) has not been played through on the new cars.
7. Replace or license every test car before publishing (§1).
