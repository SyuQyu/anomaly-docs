# Car Repair Shop [ANOMALY]: progress log

Place 111351856377896. Newest first. Plan: [VERTICAL_SLICE_PLAN.md](VERTICAL_SLICE_PLAN.md).

## 2026-11-24 (Syu + Claude): full-screen role screen + typewriter fonts (Lobby + Gameplay, not published)

- **New `StarterGui.RoleScreen`** (Lobby) replaces the old `LobbyHud.ClassPanel` popup (deleted). Full screen,
  1600x900 design fitted to the screen. Left: your own avatar (character cloned into `Left.Avatar` ViewportFrame
  on open, destroyed on close; camera tunables are attributes `Turn`, `FieldOfView`, `Distance` on the viewport)
  on a painted pedestal, name and worn role. Middle: current role, one action button (BUY with coin price and
  "NEED x MORE" / WEAR / WEARING; colours are attributes on `ActionButton`), Robux button, LEVELS table (one
  `RowTemplate` cloned per level, current level marked). Right: COLLECTION grid (one `CardTemplate` cloned per role,
  LOCKED / OWNED / WEARING) and a detail panel (lore, bonus at your level, XP bar). Top right: coins + LEAVE.
  Opened by the RoleKeeper NPC prompt and the van ROLE button; LobbyHud and TopbarHud hide while it is open.
  Controller: `StarterPlayerScripts.LobbyClient.RoleScreen` (ModuleScript). New wording in `ClassConfig.COPY`
  (ScreenTitle, Levels, Collection, Need, Wear, Wearing, Owned, Leave, per-role `Lore`), identical in both places.
- **Fonts:** Oswald is gone. Large text = **Special Elite** (worn typewriter), small labels/buttons =
  **Josefin Sans SemiBold**, labels written as spaced caps via `PaintUI.Spaced` (shared, identical both places).
  Lobby 13 titles + 20 labels, Gameplay 30 + 38. Roblox does not allow uploading font files; all fonts are Roblox
  built-ins.
- **Checked in Play:** NPC opens the screen; avatar shows; Mechanic bought with coins (800 -> 50) and worn, all
  three columns update; Clerk shows NEED 1200 MORE; gameplay shop terminal with the new fonts.
  **Not checked:** phones (fit scale only), gamepad navigation of the cards, a real Robux purchase.

## 2026-11-24 (Syu + Claude): all UI moved to the paint style + UI motion (Lobby + Gameplay, not published)

- **Shared `ReplicatedStorage.PaintUI`** (+ `PaintUIConfig`), byte-identical in both places, started by `LobbyClient`
  and `ShopClient`. Driven by CollectionService tags:
  - `PaintButton`: hover grows to 1.05, press squashes to 0.94 (UIScale child `Motion`); the paint image (child with
    attribute `Paint=true`) copies the button's `BackgroundColor3`, so controllers that colour buttons by state
    (shop/restock affordable, hotbar active) keep working unchanged; a `PaintLabel` child mirrors the button's own
    Text / colour / size / font (the paint would otherwise cover the button's text).
  - `PaintPanel`: slides up 16 px and fades its paint in when it opens (Visible or its ScreenGui Enabled).
  - Tags copy with `:Clone()`, so template rows (shop items, restock rows, Aizu's new upgrade row) are covered.
- **Converted recipe:** old 9-slice frame `82209239162563` (buttons) -> paint banner `79113488936779`; panel frame
  `104888855026335` -> paint panel `97262305096663` (Slice 180,140,844,500, scale 0.45); grain hidden; header bars
  and list rows get a paint strip; Merriweather titles -> Oswald Bold (documents keep their serif).
  Gameplay: 38 buttons, 6 panels, 8 headers/rows, 12 fonts, 8 animated panels (Repair, Procedure, Workshop shop,
  Restock, Shift report, Case file, Work order clipboard, Pause side). Lobby: 11 buttons, 4 panels, 4 fonts, all
  lobby panels + role picker buttons animated.
- **Left as they were on purpose:** CCTV screen (owner asked for its old button style), Briefing paper, handheld
  gauge/scanner bodies and the work-order clipboard body (objects, not signs; their buttons are painted),
  `RepairUI.FinishButton`, `PauseMenu.Side` and `BuildModeUI.Root.Hint` (their children are in a layout).
- **Lobby coin counter** moved to its own ScreenGui `TopbarHud` (`ScreenInsets = TopbarSafeInsets`), so it sits in
  the Roblox top bar row on every device.
- **Checked in Play:** lobby bar/list/role picker painted, hover 1.05, panel slide; gameplay HUD hotbar, shop
  terminal panel with header. **Not checked:** every gameplay window one by one (repair, procedure, restock with the
  new upgrade row, build mode, case file, pause), phones, gamepad selection (hover motion is mouse only).

## 2026-11-24 (Aizu + Claude): retail shelves use Aizu's steel rack, upgradable to level 3 (Gameplay 82609083848662, not published)

The Fluids Shelf, Parts Shelf and Tool Display now use Aizu's `Shelf_Level_1/2/3` rack mesh (asset 91925089164317)
instead of the old part-built shelves. Each placed shelf has its own level, 1 to 3. Tire Display and Battery Stand
are unchanged.

- **Templates:** `ReplicatedStorage.Shop.DecorTemplates.FluidShelf` / `PartsShelf` / `ToolShelf` are level 1; `_L2` and
  `_L3` copies are levels 2 and 3 (rack 3.57 / 6.57 / 10.07 studs wide, 10.2 tall). Stock sits on the rack's boards via
  the `Slot<n>` attachments on `Base` (attributes Width / Depth / Rows). The old templates are kept in
  `ServerStorage.TemplateBackups.ShelvesBefore_2026-11-24`. Aizu's three source models are still in Workspace.
- **Upgrade:** stand at the shelf → Restock (E) → the top row "Upgrade to level N", $200 for level 2, $400 for level 3.
  Each level multiplies every product's display capacity (level 2 = x2, level 3 = x3). Stock, products, position
  and stored state are kept. A wider shelf is checked like a new placement: if something is in the way, it is
  refused, nothing is charged, and the message says to move it somewhere wider. Shopper spots grow with the width.
- **Config:** `DecorationConfig.SHELF_LEVELS` (cost, DisplayScale, text), `UPGRADE_COPY`, `LEVEL_ATTRIBUTE`
  ("ShelfLevel" on the model), `LEVEL_TEMPLATE` ("%s_L%d"), `Upgradable = true` on the three items, helpers
  `MaxLevel / ClampLevel / TemplateName / DisplayScale`.
- **Code:** `DecorationService` (level saved in `entry.State.Level`, level-aware spawn / placement / Place / Move,
  `Upgrade(id)`, decor state publishes `StoredLevel`), `PlacementRules` (optional level), `ProductInventoryService`
  (`CapacityOf`, `Upgrade` action on `RetailAction`), `RetailAnomalyCatalog` (EndlessShelf uses the shelf's
  capacity), `BuildModeController` (ghost and checks use the shelf's level), `RestockController` (upgrade row; the
  window follows the shelf when it is respawned).

Tested in solo Play: the three level 1 racks spawn with stock; Parts shelf 1 → 2 → 3 through the remote (caps 6 → 12
→ 18, bank $1000 → $400, fourth upgrade refused); the Fluids $200 button clicked in the Restock window: refused while the
level 3 Parts rack stood next to it (no charge), then upgraded once the rack was stored, and the window stayed open on
the new shelf; stored level 3 shelf kept its level, build ghost was 10.07 wide, server refused spots only a level 1
shelf fits; placed again with all stock, reachable. No console errors. Studio save is off in this place, so the test
upgrades did not persist.
Not tested: phones and gamepad (the upgrade row in the Restock window), multiplayer, a shopper buying from a level 3 rack.

## 2026-11-23 (Syu + Claude): sketch UI repainted after Aizu's review (Lobby + Gameplay, not published)

Aizu: "looks like marker scribbles, not paint on a wall". Every ink texture is swapped for a paint version
(`assets/anomaly_ink_ui/make_paint.py`: solid paint swipe, soft rough edge, dry-brush drag only at the ends, grain and
wall pores; ids in that folder's README) and every PermanentMarker label is now **Oswald Bold** (painted-sign look).
Lobby: 15 images + 9 labels (role picker, van ROLE button, coin counter, RoleBoard sign). Gameplay: 5 images + 3 labels
(cash, shift box, coin counter, role badge). Old ink ids are no longer used anywhere.
Checked in Play: role picker (locked / owned / selected / Robux states) and gameplay HUD.

## 2026-11-23 (Syu + Claude): coins, buyable roles, role NPC in the lobby, coin pickups (Lobby + Gameplay, not published)

Two currencies now, kept apart:
- **Cash** (unchanged): in-shift money / shop bank (`Workshop.Bank`) for garage upgrades, stock and staff at the
  shop terminal (`TycoonConfig`, `EconomyService`, `UpgradeService`).
- **Coins** (new): lobby currency, saved in ProfileStore (`TEMPLATE.Coins`). Used to buy roles.

- **Roles are no longer free.** New players have no role (`Class.Selected = ""`, no bonus, badge hidden). Roles are
  bought with coins (Mechanic 750, Diagnostic 1000, Security 1000, Clerk 1250, `ClassConfig.PRICE`) or with Robux
  (developer products in `ClassConfig.PRODUCTS`: Mechanic 3735167817 / 49 R$, Diagnostic 3735167853 / 79 R$,
  Security 3735167861 / 79 R$, Clerk 3735167872 / 99 R$, created 2026-11-23 through Open Cloud, on sale).
  `Class.Owned` holds what you own.
- **Shared data modules (byte-identical in both places, hash-checked):** `PlayerDataConfig` (Coins, Class.Owned,
  Receipts, MAX_RECEIPTS, RECEIPT_SAVE_TIMEOUT), `ClassConfig` (PRICE, PRODUCTS, NONE, new COPY), new `CoinConfig`
  (SHIFT_REWARD 100, ANOMALY_REWARD 25, pickups 5-15 every 40 s, max 3 at once, 90 s lifetime), `PlayerDataService`
  (AddCoins, BuyClass handler, coins in RecordShift, **sole owner of `MarketplaceService.ProcessReceipt`**: grants a
  role, records the PurchaseId in the profile, returns PurchaseGranted only after `OnAfterSave`; NotProcessedYet on
  error or shutdown). Remotes `SetClass` and `BuyClass` exist only in the lobby.
- **Coin rewards (Gameplay):** +100 per finished shift (RecordShift), +25 to every player when an anomalous car is
  quarantined (`ShiftService.settle` -> `CoinPickupService.RewardAnomaly`), random pickups during the shift:
  `ShopSystem.CoinPickupService` clones `ServerStorage.CoinPickup` at `Workspace.ShopSetup.Markers.CoinSpots`
  (12 spots, move them freely). Client `CoinController` spins coins and shows the HUD counter
  (`MainHUD.TopRight.Coins`). Notices `CoinAnomaly` / `CoinPickup` in `ShiftShared.COPY.Notices`.
- **Lobby:** `Workspace.RoleBoard` = NPC `RoleKeeper` by the filing cabinets next to the side door, `RolePrompt`
  (E) opens the role picker, wall sign "ROLES". Cards show LOCKED + gold coin price button, Robux button (hidden
  while the product id is 0), owned -> SELECT / SELECTED. Coin counter top-right (`LobbyHud.Coins`).
  The van ROLE button still opens the same picker. New icon `ink_coin.png` = `rbxassetid://97872818471379`.
- **Checked in Play:** lobby NPC prompt opens the picker; with 800 test coins, Mechanic bought (800 -> 50) and
  selected; Diagnostic refused with "Not enough coins."; gameplay coin spawned after 20 s, picked up (+7), HUD and
  notice updated.
- **Checked:** the lobby cards show the Robux buttons with prices read from `GetProductInfo` (Studio showed
  45 / 72 / 72 / 90, the price shown to the test account, not the configured price).
- **Not checked:** a completed Robux purchase (receipt -> role granted after save), anomaly reward and shift reward in a real full shift, phone layout
  of the bigger picker. Existing warning seen once: "Maximum event re-entrancy depth exceeded ... UIFit line 15"
  (briefing/report sheet fit, not touched here).
- **Open item:** test a real Robux purchase on a live server once published (Studio purchases are test purchases).

## 2026-11-23 (Syu + Claude): role (class) system + ink-brush sketch UI, first pass (Lobby + Gameplay, not published)

Four work roles, picked in the lobby van, levelled with XP saved in ProfileStore, each with one bonus in the shift.

- **Data (identical in both places, hash-checked):**
  - New `ReplicatedStorage.PlayerData.ClassConfig`: roles `Mechanic`, `Diagnostic`, `Security`, `Clerk`, max level 10,
    XP curve `150 + (level-1)*75`, bonus per level, all wording in `ClassConfig.COPY`, helpers `LevelFor`, `Multiplier`,
    `ForPlayer`, `Best`.
  - `PlayerDataConfig.TEMPLATE.Class = { Selected, Xp = { per role } }`. The lobby copy also got Aizu's `Workshop`
    section, so both copies are the same file again. `CLASS_RATE_SECONDS = 0.5`.
  - `PlayerDataService` (still the only data owner): sanitises `Class`, renders attributes `Class`, `ClassLevel`,
    `ClassXp`, `ClassXpNeeded`, `ClassXp_<role>`; `RecordShift` also gives the selected role `120 + cash*0.5` XP.
    Remote `PlayerData.Remotes.SetClass` exists **only in the lobby** (validated id, rate limited), so the role can not be
    changed mid-shift.
- **Bonuses (Gameplay):**
  - Mechanic: repair holds 10% shorter (+2%/level). Server writes `BaseHold` on the wheel and procedure prompts;
    client `ShopClient.ClassController` sets the local `HoldDuration` from it (no compounding).
  - Diagnostic: gauge/scanner read 15% faster (+3%/level): `WorkshopService` read delays, `GaugeController`,
    `ScannerController`.
  - Security: shove cooldown 10% shorter (+3%/level): `CountermeasureService`.
  - Clerk: tips 10% bigger (+4%/level), best Clerk in the server counts: `ShiftService` settle.
- **UI:**
  - Ink textures made procedurally (`assets/anomaly_ink_ui/make_ink.py`, no AI, no text; ids in that README):
    banners `86190013221458` / `100483889946283`, underline `139982717940189`, panel `91857170570817`,
    ring `124651309308951`, blot `119578760574207`, sketch frame `108316920888323`. White, tinted by `ImageColor3`.
  - Lobby `LobbyHud.ClassPanel` (one `CardTemplate` cloned per role; selected card gets the sketch frame and a red
    stamp button; colours for idle/selected are attributes on `SelectButton`) and `CarPanel.Body.RoleButton`
    (paper brush banner, "ROLE  MECHANIC LV 1"). Car panel hides while the picker is open. Font: PermanentMarker.
  - Gameplay `MainHUD`: Cash and ShiftBox sit on black ink strokes (old frame/grain hidden, not deleted);
    new `TopRight.ClassBadge` (paper brush banner).
- **Checked in Play:** lobby picker opens from the van, switching role updates card + badge; gameplay badge shows,
  Mechanic hold 2.0 -> 1.8 at LV1 and 4.0 -> 2.88 at LV10 on a test prompt; no new errors.
- **Not checked:** XP from a real finished shift (Studio API access is off so profiles are not saved, and the lobby
  role does not carry into a Studio test of the gameplay place); Diagnostic/Security/Clerk numbers in a real shift;
  phone layout of the picker (it is fitted with the `Fit` UIScale like the other lobby panels).

## 2026-11-22 (Aizu + Claude): build mode, shop terminal and restock restyled to the monochrome UI (Gameplay 82609083848662, not published)

These screens were still in the old olive/amber look. They now follow the monochrome UI pass (as `RepairUI` / `MainHUD`):

- **Panels:** `191916` at 0.12 with tiled grain `99310308346139` and 9-slice panel frame `104888855026335`
  (40,40,472,472, scale 0.6), plus a `373734` header bar with a Merriweather title.
- **Buttons:** button frame `82209239162563` (14,14,114,50) plus grain. Light `d3d3d0` keycaps.
- **Text:** greys only. RobotoMono for numbers, SourceSans for prose.

What changed on each screen:

- **`BuildModeUI`:**
  - Banner: header with title + item name; the status line got a small LED (green/red is kept as an instrument colour).
  - The key hint is a row of keycaps, shown only with a keyboard.
  - Tray has a header strip; slots use the button style with a white outline on the selected one.
  - Side buttons have a keycap + `Label` child (the controller now sets `Snap.Label.Text`).
- **`LayoutAssets.ShelfStatus`:** sized in studs (5.6 × 2.4), so labels shrink with distance instead of piling up.
  LED + short title (REACHABLE / BLOCKED / NO WAY IN / NO WAY TO TILL), two short lines (door / till distance;
  spots · seen · lit).
- **`WorkshopShopUI`, `RestockUI`:**
  - Same panel recipe; tabs, close and buy buttons framed.
  - ZIndexBehavior changed Global → Sibling, so the frame/grain layers draw.
  - Tabs 96 wide so all 7 fit the panel.
- Code: `BuildModeController` (LED, item label path, keycap labels, slot outline refresh on select/cancel);
  `LayoutConfig` (shorter label text, grey function LED).
- **✅ Checked in solo Play at 1222×591:** build mode idle and placing (LED green/red), shelf labels (with
  AlwaysOnTop switched off on the live copy, because Studio screenshots skip always-on-top billboards), DECOR tab,
  Restock window.
- **Not checked:** phone sizes, gamepad, the tab row after the 96-px change.

## 2026-11-22 (Aizu + Claude): layout drives the shop: shelf access, functional furniture (Gameplay 82609083848662, not published)

Detail: **[RETAIL_DECOR_HANDOFF.md](RETAIL_DECOR_HANDOFF.md) → "Layout drives the shop"**.

- New `LayoutService` + `ReplicatedStorage.Shop.LayoutConfig`: per shelf access (free browse spots), walking
  distance to door and till, visibility from the door, lit; re-run only on furniture/shop changes or a shopper's
  report. Results as model attributes + `State.Layout`.
- Shoppers pick only reachable shelves, weighted by stock, preference, visibility, light and distance; they share
  browse spots, wait or move on when a shelf is full, and switch shelves (or leave) when one turns out blocked.
- Placement: till/queue/waiting/exit paths stay hard; blocking a shelf only warns; leaving no reachable shelf is refused.
  Path checks now parallel and cached (0.2–0.4 s per placement, was 2.9 s).
- Functional furniture: cabinets/storage shelves add backroom space (can't be stored if stock would overflow),
  workbench speeds repair steps nearby, tool chest speeds the mechanic, chairs/sofa are real waiting seats, lamps
  light shelves, new **CCTV Monitor** item. DECOR tab marks FUNCTION vs COSMETIC; build mode shows status labels.
- Changed: `DecorationService`, `ProductInventoryService`, `RetailCustomerService` + config, `CustomerService`
  (seat choice), `ProcedureService`, `StaffService`, `RepairConfig`, `UpgradeService`, `ShopServer`,
  `DecorationConfig`, `ShiftShared`, client `BuildModeController`, `WorkshopShopController`, `ShiftController`;
  templates `WaitingChair`/`Sofa` (Seats), new `DecorTemplates.CctvMonitor`, `LayoutAssets.ShelfStatus`.
- **✅ Play-tested solo** (real remotes): blocked shelf warning + skip, runtime block → re-check + replacement shelf,
  visibility, last-shelf refusal, stock kept through store/place, crowding (max 2 on a 2-spot shelf), storage
  capacity + store guard, placed chair used by a service customer, workbench hold 1.2 → 0.96 s and back, mechanic
  45 → 38 s with a tool chest, lamp radius, CCTV monitor, save round trip.
- **Not tested:** labels on screen (viewport stopped rendering), phones/gamepad, multiplayer, hard-path refusal
  in practice, a natural battery job at the bench.

## 2026-11-22 (Aizu + Claude): retail shop, stock, free decoration, build mode (Gameplay 82609083848662, not published)

Full detail, data layout and the test table: **[RETAIL_DECOR_HANDOFF.md](RETAIL_DECOR_HANDOFF.md)**.

- **Retail:** supplies aisle with 5 shelves west of the bays; shoppers (4 profiles) browse real shelf stock, carry a
  basket, queue at the same till as service customers and are served with *Ring it up / Refuse*. Hybrid: service
  customers may add shelf items to their repair bill.
- **Stock:** backroom (supplier orders, SUPPLIER tab), display (shelf slots, Restock prompt with +1 / FILL), repair
  reserve (`Workshop.Stock`, untouched by retail). Reservations prevent double-selling; payment settles once.
- **Decoration:** DECOR tab (32 items), build mode on **B** with green/red ghost, rotate, snap, move, store, per-object
  locks, server path check so furniture can't block customers. Appeal / comfort / light have gameplay effects.
- **Anomalies:** 17 retail events in `RetailAnomalyCatalog`, merged into the existing Director (shopper, product,
  cashier and CCTV-only); 3 of them lock the till with the basket kept.
- **✅ Play-tested solo:** spec tests 01–13, 17, 18 (see the handoff). Tests 14 and 15 only simulated (JSON round trip,
  fake lock owner). Test 16 (4 players), phones, gamepad and a real DataStore rejoin **not tested**.
- Fixed while testing: queue thread crash (would have soft-locked the shift), ghost highlight not rendering, PLACE
  button dragging the ghost on PC, hybrid picking empty shelves, basket angle.

## 2026-11-22 (SyuQyu + Claude): full-screen CCTV with map buttons and look controls (Gameplay 82609083848662, not published)

- **CCTV is now full screen** (horror-cam style, in our monochrome look). `StarterGui.CCTVUI.Screen`: `Feed` (camera
  name, timestamp and REC stacked top left, scanlines, vignette, switch flash) fills the screen; `MapPanel` bottom
  right (site map, click a CAM tag to switch); `LookPad` bottom left = four 72 px buttons in the normal panel style
  (grain + metal frame, ▲ ◀ ▼ ▶) laid out like keyboard arrow keys (▲ on top, ◀ ▼ ▶ below; hold to look, the arrow
  lights up while held, colour = button attribute `PressedColor`); `TopRight` in the very top corner has LOG, EXIT,
  the key hint under them and the pop-up event log below. Every group has a `UIScale` named `Fit` set from the screen
  height (`CCTV_UI_REFERENCE_HEIGHT` 900, min 0.65, max 1.25).
- Removed: the desk layout (camera list, controls panel, note, header, `CamTemplate`, `CCTV_DESIGN` and its config).
  Old desk kept in `ServerStorage.UILegacy` (`CCTV_Desk_2026-11-22`, `CCTV_CamTemplate_2026-11-22`); delete when
  nobody needs it.
- Keys: Q / E or LB / RB or 1–4 switch camera; W A S D, arrows, D-pad look; L / Y log; R recording; Backspace / B exit.
  Arrows and D-pad left/right used to switch camera and now look around.
- Look limits per camera: marker attributes `PanYaw` / `PanPitch` (defaults `CCTV_PAN_YAW` 40, `CCTV_PAN_PITCH` 18),
  speed `CCTV_PAN_SPEED` 50 °/s. Each camera remembers where it was pointed. Wording in `ShiftShared.COPY.Cctv`
  (`Exit`, `Log`, `Pan`, `Hint*`; the desk-only strings were removed).
- `CctvAnomalyController` untouched: it still gets `Show(marker)` on every switch, so CCTV-only anomalies keep working.
- **✅ Play-tested solo (PC):** opens from the monitor; W A S D panned ~40° / ~15° and stopped at the limits while the
  character stayed put; holding ◀ with the mouse panned and stopped on release; clicking CAM 03 on the map switched;
  L opened the log; Backspace restored the normal camera and movement. Layout checked at 576, 720 and 1080 px tall.
- **Not tested:** phone touch on the pan buttons and map, gamepad, CCTV-only anomalies with a turned camera.

## 2026-11-20 → 21 (SyuQyu + Claude): cars, customer cars, office, shop front, paper notice, HUD fix (Gameplay 82609083848662 + Lobby 111351856377896, not published)

Written up on 2026-11-22; the work itself came before Aizu's gameplay-loop entries below. Full detail:
**[GAMEPLAY_SHOP_HANDOFF.md](GAMEPLAY_SHOP_HANDOFF.md)**.

- **Test cars:** BMW 3 Touring, Mercedes SLK 55 (Forza 7 rip) and Toyota Camry split in Blender (doors, hood, boot,
  separate lights, tyre/rim), exported to `assets/anomaly_*_test` (local, not in this repo). Test only.
- **Customer cars ✅ Play-tested solo:** templates `ServerStorage.VehicleTemplates/Estate`, `Roadster`, `Saloon`
  (Sedan contract: `Root` + hub/jack/contact/prompt attachments, `Wheels`, welded `Body`). `ShiftConfig.VEHICLE_TEMPLATES`
  random pick, 10 colours; paint = parts with attribute `Paint`, plates = every `PlateGui`. `VehicleService.FitWheel`
  uses the car's own wheel. Glass = lobby van look (transparency 0.75). EU plates also on the lobby vans.
- **Office restored ✅:** `Workspace.ShopSetup.Office` was in ServerStorage after the map swap (shift could not start).
  Chairs sit invisibly on the map's own bench seats; clock, radio, CCTV monitor placed; old visuals in
  `ServerStorage.OfficeLegacy`.
- **Shop front:** `ShopFrontService` + `ShopFrontConfig`. Shutters are the map's own parts tagged `ShopShutter`
  (the six `Garage.Rolling.RollingGate` strips = group `Bays`, `Workspace.WindowShutter` = group `Window`); they open
  and close by stretching along their own Y axis (attributes `OpenSize`, `ClosedSize`, `FixedSide`, `StartOpen`).
  Panel `Front.ShutterPanel` (BAYS / WINDOW buttons, lamps), office door `Front.OfficeDoor` (hinge away from the
  handle, swings into the hallway). Bays start open, window closed; the first customer waits for both; bays and
  window lock while a customer is in. **Tested:** panel prompts, door, lock, shift waiting for the window (on the
  earlier curtain version). **Not tested in Play:** the final stretch-the-strips version (Studio previews of open and
  closed only; the MCP play button got stuck).
- **Night notice as paper ✅:** `BriefingUI.Dim.Sheet.PaperHolder` (aged paper 9-slice, tape, shadow, coffee ring),
  textures generated procedurally, provenance in the GUI attribute `TextureProvenance`.
- **HUD auto-size fix (the prompt bar that kept stretching):** decorations in auto-sized boxes are now direct
  children at exactly `(1,0,1,0)`, padding on an inner element, no nested scale frames. `BottomLeft.Notice` and
  `TopRight.Cash` are now `Frame` + `Label`; `TopLeft.ShiftBox` labels are in `Body`; the prompt `Fill` is a direct
  child (`PromptController` reads its height from the template). ✅ Verified in Studio edit mode (boxes grow and
  shrink, prompt stays 104 px while the hold bar fills); **not checked in Play**. Lobby HUD not scanned yet.
- **Open:** check the shutters and the HUD in Play; scan `LobbyHud` for the same auto-size pattern; radio loudness
  (it plays at 0.45 within 40 studs: louder or silent?); replace or license every test car before publishing.

## 2026-11-22 (Aizu + Claude): master gameplay prompt finished, phases 6–8 (Gameplay place 82609083848662, not published)

Final delivery report (what is tested, what isn't, what is blocked): **[GAMEPLAY_LOOP_HANDOFF.md](GAMEPLAY_LOOP_HANDOFF.md)**.

- **Countermeasure (TEST 09) ✅ Play-tested solo:** before purchase G is not bound and the server answers
  `CounterLocked`; bought at the rack ($600) → G / R1 / touch SHOVE bound; real G press 6 studs in front of a forced
  Lurker → "It staggered back.", Lurker anchored for the stun, then removed (recorded "Repelled by the
  countermeasure"); second press → cooldown notice. Note: a Lurker within 3.4 studs grabs at once (2.5 s stun), so the
  shove must land before it reaches you.
- **Radiator procedure ✅:** rack II + radiator bought → Overheating car (118 °C, P0217) → scan → 6 steps
  (jack up 0.5 studs, wrench ×2, fit radiator: stock 1 → 0, wrench, jack down) → 89 °C, codes clear → rescan Verified.
- **Full natural shift ✅ (3 customers, Overheating forced, customer 1 anomalous):** anomalous customer's tray locked
  at the window by itself (WrongCustomerRecord fired at the counter), greyed RELEASE click did nothing, QUARANTINE →
  tray closed, $0, customer walked out. Customers 2 and 3 released and paid ($227, $200; tray Open → Closing → Closed).
  Shift ended: report with 3 jobs, $427, the quarantined anomaly and its findings in the notes, wages 0 (no staff),
  bank saved in the state (1017).
- **Fixed: customers stuck on the waiting-room bench.** `standUp` cleared `Sit` but the bench `Seat` grabbed the
  customer again on touch, and `goTo` reported success anyway, so the cashier talk played from the bench and a
  quarantined customer never left. `CustomerService.standUp` now disables that seat for `CustomerConfig.SEAT_REARM_SECONDS`
  4 (re-enabled before anyone sits); `goTo` re-paths up to `PATH_RETRIES` 2 when `STUCK_STEPS` 2 steps in a row fail,
  and stands the customer up first if still seated. Tested: customer walks bench → window (0.9 studs off the mark) and
  out after quarantine, every time in the next shift.
- **Fixed: shift-report notes doubled punctuation** ("Halim..", capital after ";"): `ShiftController` trims each
  finding's full stop and lowercases its first letter before joining. Not re-checked on screen.
- Events seen firing on their own this session: PassengerShadow, WrongReflection, MovingEquipment, EmptyFootsteps,
  WrongCustomerRecord (twice). SilentPayment forced (RadioDies) ran clean. WrongLicensePlate's Run/Finding tested in Edit
  on a real car template (both variants); in play it was correctly refused because that customer's profile already had
  the plate anomaly.
- **Test switches reverted:** `ShiftConfig.FORCE_FAULT = nil`, `AnomalyConfig.TEST_INDEX = nil`. A normal shift was
  started afterwards (random fault DeadBattery, no errors). No ZZ leftovers.
- Co-op and saves reviewed in code only (Studio can't run 2 players and has no DataStore access here): see the handoff.

## 2026-11-21 (Aizu + Claude): master gameplay prompt, phases 0–5 (Gameplay place 82609083848662, not published)

Working from the user's "MASTER IMPLEMENTATION PROMPT" (full gameplay loop, cashier, Anomaly Director, tycoon,
staff, countermeasure, co-op). Backups of every Shop script before this work:
`ServerStorage.ScriptBackups.2026-11-21_BeforeGameplayLoop` (48 scripts as disabled ModuleScripts).

**Phase 0 audit (what already existed and is kept):** shift loop (3 customers), customer NPC + routes, work
order, gauge/scanner/jack/wrench tools, FIT THE WHEEL tire repair, release/quarantine stamp decision at the
service window, 5 anomalies (A1–A5), CCTV, case file, end-of-shift report, ProfileStore saves (teammate's
`PlayerDataService`), matchmaking, shutters. Missing: front-of-shop arrival, dialogue choices, multiple bays,
battery/radiator repairs, cashier tray, Anomaly Director, tycoon, staff, countermeasure.

**Phase 1 ✅ Play-tested solo:** customer arrival rebuilt.
- Markers `Workspace.ShopSetup.Markers.Arrival`: `CustomerVehicleSpawn` (road, z 245), `ArrivalPath/1..3`,
  `CustomerVehicleStop` (forecourt in front of bay 2), `CustomerTalkPoint`, `CustomerExitPoint`,
  `DeparturePath/1..3`. Tags `CustomerSpawn`, `CustomerStop`, `CustomerTalkPoint`, `VehicleExit`.
- Three bays: `Bay1CarSpot`, new `Bay2CarSpot` (z 86), `Bay3CarSpot` (z 110), tag `RepairBay`, attribute `BayIndex`.
- `VehicleService.DriveAlong` (multi-point drive with speed ramp, smooth heading, optional reverse),
  `VehicleService.Rebase` (moves the car's jack rest pose when it changes spot). Tunables in `VehicleConfig.DRIVE_*`.
- New `BayService` (free bay, reserve, queue waiters, release). New `DialogueService` + remotes
  `DialogueOptions` / `DialogueChoose` (server validates token, option, distance; timeout 60 s).
- `CustomerService`: state machine on the model attribute `State` (and car attribute `CustomerState`), states in
  `CustomerConfig.STATES`. Car stops out front → customer gets out → pathfinds to the talk point → Talk →
  greeting by personality (Tired / Nervous / Chatty / Curt) → complaint → options *What happened? / How long? /
  I'll take a look / I'm not available*. Accept = keys + work order, car drives into a free bay, customer walks to
  the waiting room. Decline = customer drives off, logged as "Declined", reputation −1 at shift end.
- `DialogueGui.Choices` + `OptionTemplate` (keys 1–4 or click, Modal so the mouse is free).
- Verified: car route road → stop → bay 1 (8 s), customer exit + talk point, dialogue lines and options, accept →
  bay + waiting room + order created; gauge and scan prompts work in the new spot.

**Phase 2 (battery ✅ Play-tested solo; radiator tested 2026-11-22):**
- Faults now picked per customer: `RepairConfig.FAULTS` (FlatTire 4, DeadBattery 3, Overheating 3 needs rack level 2).
  Bad readings (`BAD_BATTERY_*`, `BAD_ENGINE_TEMP_*`, `FAULT_CODES`) are set on the car; the scanner reports them.
- New `ReplicatedStorage.Shop.ProcedureShared` (step lists: battery 5 steps, radiator 6 steps with jack up/down),
  `ProcedureService` (server: engine-bay prompt shows the current step, checks tool, takes the part from the rack,
  keeps progress on the car attribute `ProcedureStep`, so nothing resets if interrupted).
- Each car template got `Root.Engine` attachment + `EnginePrompt`.
- `WorkshopService.scan` diagnoses battery/radiator faults and verifies them after the repair.
- New `ProcedureUI` (copy of the repair card with a step template) + client `ProcedureController` (shows while the
  engine-bay prompt is on screen).
- Tire changes now use a spare tire from the rack (`NoTire` notice when empty).
- Verified: dead-battery car → scan diagnoses → 5 steps (wrench/hands/part) → battery stock 2→1 → rescan → Verified →
  objective "Call … back".
- Test switch `ShiftConfig.FORCE_FAULT` was used here; set back to nil on 2026-11-22.

**Phase 3 cashier ✅ Play-tested solo (normal pay, mid-payment interrupt, locked → quarantine):**
- New `Workspace.ShopSetup.Front.Cashier` on the service-window ledge (no map change): sliding `Tray` (diamond
  plate, lips, `Cash` bundle, attribute `OpenOffset`), `Slot` guard, `LockLamp` (green idle / amber open / red
  locked, colours as attributes), counter bell (`BellDome.PromptPoint.CallPrompt` "Call customer"), markers
  `CustomerCashierPoint` (tag `CashierPoint`), `CashierInteractionPoint`, `CashTrayPosition`. Sounds: bell PSE
  9114132512, tray slide PSE 9125690244, lock clunk 9113437465.
- New `CashierService` + `CashierConfig`: tray states Closed / Opening / Open / Locked / Closing (State attribute
  `CashierTray`), `Open`, `Close`, `Lock`, `Unlock`, `Pay` (2.6 s window that an anomaly can cancel), `Interrupt`,
  bell prompt.
- `CustomerService.callBack` rewritten: Call (bell when the order is Verified, or the seated customer's prompt
  any time) → walks to the window → dialogue → tray opens → stamps. RELEASED = customer pays into the tray, server
  deposits, tray closes, customer leaves. QUARANTINE = tray closes, no pay. Not yet = back to the seat.
- Anomalous customer at the till: if the customer is flagged (`customer.Manifest`, or model attribute
  `AnomalyManifest`, which the Director will set), the tray **locks**, anomaly lines play, order gets
  `TrayLocked = true`, RELEASED is refused by the server and greyed on the stamp ("tray locked · no payment"),
  only QUARANTINE resolves it (then the tray unlocks). If the flag is set during the payment window, the payment
  is cancelled and the tray slams shut.
- Design call: only anomalies that *openly manifest* lock the tray. Subtle data anomalies (wrong plate, low
  mileage, changed look) do not, so the player still has to judge them; the truth stays hidden until the report.
- Seen once, not reproduced: a "Not yet" arrived from the client right after the stamps opened (customer went back
  to sit). Second run behaved. Watch for it in playtests.

**Phase 4 Anomaly Director (core ✅ Play-tested solo with forced events; natural random firing not yet observed):**
- New `AnomalyDirector` (server): data-driven, weighted pick per trigger, chance per trigger
  (`AnomalyConfig.DIRECTOR.TRIGGER_CHANCE`), escalation by customer index and shift number, per-event cooldown,
  anti-repetition (last 3), conflicts, max 1 major + 2 subtle at once, global gap 18 s, major gap 150 s, quiet idle
  loop (25–50 s) firing IdleWorkshop / EnvironmentalTrigger / RandomOpportunity. Shift seed per shift
  (`DIRECTOR.TEST_SEED` to reproduce; current seed in `ServerStorage` attribute `AnomalyShiftSeed`). History
  (event, variant, time, location, customer, vehicle, interaction, resolution, evidence). `ActiveSources()` for the
  security guard. `Force(id, variant)` only through `ServerStorage.AnomalyDebug` (BindableFunction, Studio only).
- New `AnomalyCatalog` (data + run functions): the 12 prototypes, each with triggers, requirements, variants,
  duration, cooldown, detectability, signal: WrongLicensePlate, PassengerShadow (rear seat / camera only),
  RepeatedDialogue (exact / stutter, manifests), WrongReflection (different person / no face / facing away, in
  the service window glass), BatterySignal (scanner / headlights, manifests), MovingTool, UnknownFigure (CCTV only,
  standing / closer each time), FutureFootage (CCTV only, shows the next customer's car, which then really comes),
  WrongCustomerRecord (manifests), SilentPayment (silent / radio dies, manifests), EmptyFootsteps (past the bay /
  behind you), MovingEquipment (slid / turned to face). Customer events only fire on the shift's anomalous
  customer, so the end-of-shift truth stays consistent. Their findings go into the report
  (`spec.EventFindings`, shown through `AnomalyService.Reveal`). Moved props go back at the next shift.
- Triggers wired: arrival, before/during dialogue, inspection (gauge, scan), repair steps and tire jobs, after
  repair, before cashier, cashier dialogue, cashier transaction, CCTV watching (new remote `CctvWatching`), idle.
  The old A1–A5 stay as each anomalous customer's built-in profile.
- CCTV-only: server publishes State attribute `CctvEvents`; models that only clients may draw are replicated in
  `ReplicatedStorage.Shop.AnomalyCctv.Live`. New client `CctvAnomalyController` spawns them locally under
  `Camera.CctvOnly` only while that camera is on screen. Verified: the CAM 02 figure existed on the client only
  while CAM 02 was selected, never on the server or in the normal world.
- Templates: `ServerStorage.AnomalyTemplates.ShadowFigure`, `.Footsteps` (Roblox built-in footstep sound),
  `ReplicatedStorage.Shop.AnomalyCctv.Figure`. Props tagged `AnomalyMovable` (attribute `MoveKind`): office chair,
  two tire stacks, two traffic cones inside the shop.
- Verified forced: PassengerShadow, UnknownFigure (CAM 02 only), MovingEquipment, EmptyFootsteps, RepeatedDialogue
  → cashier tray locked on arrival without opening, FutureFootage (car drawn on CAM 01 only), MovingTool.
  Not yet verified: WrongLicensePlate, WrongReflection, BatterySignal, WrongCustomerRecord, SilentPayment in play.
- Fixed: the service order showed through the CCTV feed window; CCTV now hides `WorkOrderUI` while open.
- Test switch `AnomalyConfig.TEST_INDEX = 1` was used here; set back to nil on 2026-11-22.

**Phase 5 tycoon + staff ✅ Play-tested solo:**
- HUD cash now shows the **workshop bank** (`Workspace` State attribute `Workshop`), not this shift's takings. Starts
  at $0 for a new owner. The report still shows the shift's earnings.
- Shop terminal: prompt `Workspace.ShopSetup.Front.ShopTerminal.ShopPrompt` at the office parts rack (tag
  `PartsRack`). New `StarterGui.WorkshopShopUI` (tabs Parts / Parts Rack / Employees / Security / Defense, rows from
  `ItemTemplate`, bank + rack stock in the header, Backspace or X closes) + client `WorkshopShopController`.
- Server `UpgradeService`: RemoteFunction `WorkshopPurchase` (keys `Part:<name>`, `Rack:Upgrade`,
  `Staff:Mechanic`, `Staff:Security`, `Defense:Countermeasure`); checks you're at the rack, 0.4 s rate limit,
  money, rack capacity, rack level. All prices in `TycoonConfig`. Wages charged at shift end (notice shows paid /
  short).
- Rack: level 1 holds 6 (tires, batteries); level 2 ($400) holds 14 and unlocks radiators, which is also what makes
  overheating cars start arriving (`RepairConfig.FAULTS` MinRack).
- New `StaffService` + templates `ServerStorage.StaffTemplates.Mechanic / Security`, markers
  `Markers.Staff.MechanicHome`, `Markers.Staff.SecurityPatrol/1..5` (5 = CCTV desk, attribute `CctvDesk`).
  - Mechanic ($300, wage $40): waits 6 s after a car is parked, then repairs tire or battery jobs the players haven't
    started, using rack stock; marks the order Verified and tells everyone to call the customer. Never talks to
    customers, never touches the till or the stamps. Stops if a threat is active.
  - Security guard ($350, wage $45, level 2 training $300): patrols, watches the cameras at the desk, every 4 s rolls
    detection on active Director sources (level × event detectability, 3 tries per source, range 60), tracks at most
    **2** at once (`MaxTrackedAnomalies`), warns everyone ("Security: Object out of place, bay 2 (23:44)").
    CCTV-only events only while at the desk.
- Studio-only test hook `ServerStorage.EconomyDebug` (BindableFunction, adds money).
- Verified: bank $1,500 → rack II (real button click), 2 radiators, mechanic, guard, a tire = $275 left; second
  mechanic and the countermeasure refused correctly; unknown key refused. Mechanic did a full battery job
  (5 steps, battery stock 2 → 1, order Verified) while BatterySignal fired on its own mid-job. Guard tracked 2 sources
  and ignored the third.
- Seen: the guard's CCTV-desk point sits behind the office door; it stood just outside the office but still counted
  as "at the desk". Move point 5 or open the door path.

**Economy foundation (part of phase 5):** `ReplicatedStorage.Shop.TycoonConfig` (prices, parts, rack levels,
staff, countermeasure, pay per fault), `EconomyService` (workshop bank, stock, rack level, staff, saved in the
**host's** profile under `Workshop`; `PlayerDataConfig.TEMPLATE.Workshop` added). Payments deposit into the bank.
Free supplier delivery tops up 1 tire + 1 battery at each shift start.

## 2026-11-19: CCTV rebuilt to the user's "security system" reference ✅ (solo Play-tested, not published)

- **New `CCTVUI.Desk`** (design 1280×720, one UIScale fit):
  - Paper header plate: cog + wrench logo, JOTHEM AUTO REPAIR / SECURITY SYSTEM v1.2.
  - CAMERA NETWORK ● ONLINE box.
  - Camera list (`Cams.List`, cards from `CamTemplate` with a thumbnail, code and area).
  - CONTROLS: ▲▼ select, ▶ view recording, X exit monitor, with key hints under each label.
  - The feed window, with burnt-in camera name, blinking REC, a "11/18/1997 11:40:02 PM" style stamp, scanlines,
    vignette and scan bar.
  - EVENT LOG and SITE MAP panels, and a taped paper NOTE with a red stamp.
  - Metal backplate frames mask everything except the feed.
- **Feed framing:** the feed is a window onto the real camera. `frameCamera` widens the FOV and angles the camera
  so each marker's own FieldOfView fills exactly the window.
- **Site map** is drawn from `Markers.Areas` and the CCTV markers (positions and look directions), so it follows
  map changes. Click a tag to switch; the selected tag is green with a view cone.
- **Event log:** a real motion check runs once a second, only while viewing. It looks for players and
  `Workspace.Customers` NPCs that move in a camera's view cone (90 studs, 48°, line of sight). It logs "Motion
  detected." straight away and "No motion." after 5 s still. Also "[SYSTEM] Monitor on. Recording." when the
  monitor opens.
- **View Recording** (R / X / ▶) logs "No tape in the recorder." for now.
- `CCTVController.Log(source, message, color)` is exposed so future anomalies can write to the log.
- **Thumbnails:** each camera card reads a `Thumbnail` attribute (image id) on its marker; until one is set it
  shows NO IMAGE.
- **Compact layout:** below 0.72 scale (phones) it switches to 980×500 with the list, a big feed and an exit button
  only (no map, log or note). That's about 0.76 scale on an iPhone landscape screen.
- Tunables live in `ShopClientConfig.CCTV_*`, copy in `ShiftShared.COPY.Cctv`.

## 2026-11-19: UI pass 3, review + refine ✅ (solo Play-tested at desktop size, not published)

Full findings and changes: [UI_REVIEW_2026-11-19.md](UI_REVIEW_2026-11-19.md).
- Two breakages from the map/lighting rework fixed: `Lighting.CCTVGrade` was missing, which stopped the case file,
  clock, menu and night notice from starting; `DiagnosticUI.Scanner.Side` was missing, so the scanner showed no
  readings.
- The decision is now RELEASED / QUARANTINE rubber stamps inside the work order (`Columns.Right.Decide`), replacing
  the card panel the clipboard used to cover.
- New `HudCover`: the HUD hides under full-screen documents and devices.
- Restyled: dialogue as subtitles, crew as a paper roster, CCTV LED channel list, case file index tabs, menu dim.
  The work order and HUD text are larger.
- **Place state at this point:** the shop structure, Baseplate, terrain and night lighting are missing from the
  Workspace and Lighting (being rebuilt by the user?), so a fresh Play falls through the world. The UI tests used a
  Play-only floor.
- Also 2026-11-19: `Modal` set on one button per modal screen (LaterButton, NewShiftButton, StayButton, case file
  CloseButton, StartButton, CCTV ExitButton), so the first-person mouse is free while they're open.

## 2026-11-18: M5 playtest prep ✅ (solo Play-tested, not published)

Guide, observer sheet and questions: [PLAYTEST_M5.md](PLAYTEST_M5.md). The playtest itself is the user's (publish + friends).

- **Night notice** (`BriefingUI` + `BriefingController`): a paper memo from the owner, shown once when you join. Five
  rules: talk and take keys, find the fault first, compare car/owner with the order, "some cars that come in at night
  are not what they say they are", release vs quarantine (and that holding an honest car costs). Enter / A / Space /
  button closes it. Reread from the menu ("Night Notice", new 3rd item). Copy in `ShiftShared.COPY.Briefing`.
- **Playtest analytics** (`ShopSystem.PlaytestLog`, `ShiftConfig.PLAYTEST_*`): `AnalyticsService:LogCustomEvent`
  `Decision` (1 = right call; fields: Normal/Anomalous, choice, anomaly ids) and `ShiftEnded` (right calls; fields:
  "x/3", reputation, player count). The deciding player is `customer.Decider` (the one who called them back).
- **Fixed a truth leak:** quarantining a normal customer used to show "left angry, Reputation −1" and drop REP on the
  HUD at once, so you knew immediately you'd been wrong. Now both cases say "Car quarantined. X left without it.", the
  reputation is held (`pendingReputation`) and applied when the shift ends, and the mid-shift log has no Reputation.
- **Tested in solo Play:** a natural 3-customer shift with a random pick (customer 2 got A2; all three quarantined):
  report showed Anomaly + "odometer reads lower than the order", reputation −2, 4 analytics events fired, START NEXT
  SHIFT reset to shift 2. A 1-customer normal shift (test settings, restored): HUD stayed REP 0 with the neutral notice,
  report −1. Briefing screenshot checked. Console: only the slow-load "DialogueGui" infinite-yield warning.
- **Multiplayer review** (by reading, not tested): see "Known limits" in the guide (work order slides in for everyone,
  only the caller decides, A3/A4 depend on the nearest player, anyone can start the next shift). StreamingEnabled is on;
  the whole shop fits in the stream radius, so CCTV cameras and props load.

## 2026-11-18: M4 anomalies ✅ (solo Play-tested, not published)

One customer per shift (random, `AnomalyConfig.ANOMALOUS_PER_SHIFT` 1) is anomalous with 1 anomaly (60%) or 2 (40%,
`SECOND_CHANCE`). Weighted by GDD rarity (`RARITY` Common 60 / Uncommon 25 / Rare 10 / VeryRare 5).

**Data format** (`ServerScriptService.ShopSystem.AnomalyDefinitions`, the format the full Director can read later):
each entry has `Id`, `Code`, `Category`, `Rarity`, `Conflicts`, `Short`, `Reveal(spec)` and optional phase hooks
`Spec(spec, rng)`, `Customer(customer)`, `Seated(customer)`, `Standing(customer)`, `Removed(customer)`.
`AnomalyService`: `AnomalousIndices`, `Pick` (weighted, no repeats, honours conflicts both ways), `Run(spec, phase, ...)`
(each hook in a pcall with a warning), `Reveal(spec)` → findings {Id, Code, Short, Text}. Hooks are called from
ShiftService (Spec) and CustomerService (spawned, seated, call-back, removed).

| | Id | Category / rarity | What happens |
|---|---|---|---|
| A1 | WrongPlate | Vehicle / Common | One digit or one end letter of the plate on the car differs from the order (`spec.PlateShown`; work order and scanner keep the real one) |
| A2 | LowMileage | Vehicle / Common | Scanner odometer reads 18,000–42,000 km less than the order's mileage |
| A3 | DifferentPerson | Customer / Uncommon | 10 s after sitting, when no player is within 20 studs, the customer's look changes (skin, shirt, trousers); if never unseen, it changes when called back. Same name |
| A4 | WrongBody | Customer / Uncommon | No idle or walk animation (glides), and the head turns (up to 85°) to follow the nearest player within 45 studs. Stand-in for the mirrored walk / statue clips until the Mixamo export |
| A5 | ShopReacts | Workshop / Uncommon | While they sit: the waiting-room clock runs backwards and the radio switches to static; back to normal when they stand |

A3 and A4 conflict (never together).

**New for this:**
- `CustomerLooks` + `CustomerConfig.LOOKS`: every customer now gets a seeded look (4 skins, 6 shirts, 4 trousers), so a
  face can be remembered (needed for A3).
- `Office.WaitingProps`: a wall clock above the chairs (SurfaceGui hands, client `ClockController`) and a radio on the
  table (Music = "The Saxophone Stayed Late" 109558786368038, Static = 8028069841, both load; EQ'd thin).
- `WaitingRoomService`: shared clock (State `ClockAnchorTime/Seconds/Rate`, server time, so every client agrees), a true
  forward clock for log times (`Minutes()`), radio music/static.
- The shift log sent to clients has no Truth/Anomalies/Findings until the shift ends (they were readable before).
  Log entries carry `Anomalies` and `Findings`. `Closed` is now the real shift clock (was the arrival time).
- Ledger notes list each anomalous order ("Order 0001, Wenny Gunawan: a different person came back."); case file
  Evidence shows "Irregularities", Notes lists the full reveal text.
- Fixed: the ledger/case file showed "Green Green Sedan" (the log's Car already has the colour).
- Test switches: `AnomalyConfig.TEST_ANOMALIES` / `TEST_INDEX` (both nil now).

**Tested in solo Play:**
- A1+A2+A4+A5 on customer 1: plate on car PT 2601 EN vs order PT 2691 EN; odometer 202,854 vs 228,978; no animation
  tracks; seated → radio static, clock rate −1, second hand 24 → 12 over 2 s; head within 0.2–0.7° of the player
  from two positions; call back → music and forward clock back, walked at 7 with no tracks.
- Mid-shift client log had no Truth/Findings.
- A3 in a 1-customer shift (CUSTOMERS was set to 1 for the test, back to 3): look 1-3-4 → 4-2-2 after 10 s out of
  sight; quarantine → ledger "Anomaly" + finding note, case file CONTAINED + irregularity.
- 10,000 picks: 60/40 one/two, Common ≈ 2.3× Uncommon, A3+A4 never together, anomalous customer evenly 1/2/3.
- Console clean.

**Not tested:** a full natural 3-customer shift with a random pick, the release path for an anomalous car
(UNRESOLVED), A1/A2 seen in the 3D view (checked through data), how loud the radio is, 2+ players (stare picks
the nearest), phone.

## 2026-11-18: UI design system + pass 2 ✅ (solo Play-tested, not published)

From the user's second reference sheet ("UI DESIGN SHEETS") and a phased brief. Analysis, tokens, type scale,
audit and plan: [UI_DESIGN_SYSTEM.md](UI_DESIGN_SYSTEM.md). Still no "ANOMALY DETECTED" alert (sheet 9 ignored).

**New shared pieces**
- `ShopClient.UIFit`: one fit-to-screen rule for every modal (design size, floor 0.72, ceiling 1.15, margins incl.
  separate top/bottom). Replaces the per-controller `fitScale` code in the report, work order and case file.
- `ShiftShared.Money` is now "$152.00" everywhere (was "$152" in the report, "$0.00" in the HUD).
- No GUI text below 13 design px left (checked by a sweep). At the 0.72 phone floor that is ≥ 9.4 pt; labels on the
  ledger, work order and case file were raised to 14 (≥ 10 pt).

**End of Shift** (`ShiftReportUI.Dim.Sheet`, rebuilt): printed ledger with letterhead (ring logo, JOTHEM AUTO REPAIR,
SHIFT REPORT No. / closed time), END OF SHIFT, four summary boxes (completed jobs, total earned, reputation, unresolved
cases; red when bad), a ruled service log (#, customer, vehicle colour + model, plate, condition, disposition,
payment), shift notes written from the log, total payment, a rotated SHIFT CLOSED stamp, and under the paper OPEN CASE
FILES + START NEXT SHIFT. Height follows the rows (no empty block). Server: `ShiftService` log entries gained Colour,
ColourHex, Fault, Mileage, Arrived, Closed. "Unresolved" = anomalous car released.

**Work Order** (`WorkOrderUI.Clipboard`, rebuilt): landscape 720×480 form on a dark clipboard with a brass clip.
Letterhead + SERVICE ORDER No. 0001; left column facts (customer, vehicle, plate, mileage, arrived), complaint,
requested service, findings; right column status stamp, boxed inspection checklist, repair tasks, disposition. Fits
between the top-right HUD and the tool row (`ORDER_MARGIN_TOP/BOTTOM`); WorkOrderUI DisplayOrder 6 → 26 so it draws
over the HUD. The decision panel was not changed.

**HUD:** clock 30 bold, objective 16/17, cash in a framed box, tool slots 82×58 with 14/16 text,
`HUD_REFERENCE_HEIGHT` 640 and floor 0.75. Top-right now has MENU beside PLAYERS (`TopRight.Buttons`).

**Scanner:** device 660 wide with a side panel (4 hardware keys, PWR and DATA lamps; DATA is amber while scanning and
green when done), larger readings (20) and labels.

**Repair panel:** bigger labels, square info badge. **Players list:** hint 11 → 14, title 20.

**CCTV (new):** `CCTVUI` + `CCTVController`. Monitor on the office counter (`Office.CctvMonitor`, prompt F / D-pad up,
"Watch cameras"). Four fixed cameras in `ShopSetup.Markers.CCTV` (Cam01 Parking, Cam02 Service Bay, Cam03 Waiting
Room, Cam04 Rear Entrance; attributes Label, Area, Order, FieldOfView). Grey grade `Lighting.CCTVGrade` (local),
bezel, vignette, slow scan bar, burnt-in camera name, blinking REC, a running timestamp from the shift clock, camera
list with keys. 1–4 / Q E / LB RB switch with a short black cut, Backspace / B / EXIT leave. Player controls are
disabled while watching and restored after; the camera is held by a render step only while open.

**Case File (new):** `CaseFileUI` + `CaseFileController`. Manila folder: index of case slips, paper sheet with
CASE FILE #, status stamp, tabs Evidence (painted car photo in a ViewportFrame from `Shop.UIAssets.SedanPhoto`, a
stripped copy of the Sedan; facts and observation), Records (ten fields) and Notes. A case = a quarantined car, plus
any released anomaly once the shift ends. Status: UNDER REVIEW during the shift; after it CONTAINED, CLOSED (no anomaly)
or UNRESOLVED. Opened from the ledger and the menu. Q/E tabs, Up/Down cases, Backspace closes.

**Menu (new):** `PauseMenu` + `PauseController`. P / Select / MENU button. Resume, Controls (key list), Case Files,
Leave Shift (confirm, then the player leaves the server). It says "THE SHIFT KEEPS RUNNING": nothing is paused.

**Tested in solo Play (1222×591):** ledger with three entries (stats, red values, notes, totals), case file empty
state and with two cases (evidence photo, records, notes, tab and case keys), live work order from a real customer and
an injected verified order, HUD, scanner layout, all four CCTV cameras (Cam03 moved after it rendered inside a wall),
leaving CCTV restores camera/HUD/grade, menu open/Controls/Case Files/Resume restores the HUD. Console clean.
**Phone:** checked by calculation from each modal's real design size for 750×381: ledger, work order, case file and
menu fit at ≥ 0.72 after trimming the ledger and folder. Not seen on a real phone. **Not tested:** gamepad, touch,
2+ players, the Leave button (it kicks the player), the scanner reading layout during a real scan.

## 2026-11-18: UI PRD pass 1 ✅ (solo Play-tested, not published)

Built to the user's Workshop Industrial UI PRD ([UI_PRD.md](UI_PRD.md)). The user chose:
- all 7 modules, in two passes (CCTV and Case File come in pass 2, after review)
- no "ANOMALY DETECTED" banner
- real tool selection
- built UI rather than texture images

Colours and fonts live in `ReplicatedStorage.Shop.UITheme`: PRD tokens; Oswald for display text, RobotoMono for
technical data, Source Sans for body text, Special Elite for stamps.

**Screens** (each one is a real instance tree in StarterGui; the old WorkOrderGui, GaugeGui, DecisionGui, ShiftHudGui,
NoticeGui and ShiftReportGui are gone):
- **MainHUD**:
  - Top left: NIGHT SHIFT 01, the clock, and the OBJECTIVE with 2 lines. The first line follows the job ("Find the
    fault…", "Replace the front right tire", "Call X back…"); the second always reads "Keep an eye on the workshop".
  - Top right: cash ($0.00), JOB n/3 · REP, and a PLAYERS button on touch only.
  - Bottom left: notices and a **custom interaction prompt** (all shop prompts are now Style Custom): a key box
    (E / X / TAP), the action, the object, and a hold bar. Tap or click it to use it on mobile.
  - Bottom right: the equipped tool and **tool row** 1 GAUGE · 2 SCAN · 3 JACK · 4 WRENCH (number keys, D-pad left/right,
    or tap; picking the same tool again goes back to HANDS).
  - Corners scale with screen height. The top corners and the prompt hide while the repair panel is open.
- **WorkOrderUI**: a **service order** on a clipboard (J opens and closes it):
  - Header: J mark, SERVICE ORDER, JOTHEM AUTO REPAIR.
  - Order No., Arrived, Vehicle, Plate, Mileage, Customer.
  - Complaint (in quotes) and requested service.
  - **Inspection checklist:** each tire's pressure as it's measured, plus "Diagnostic scan DONE".
  - Findings / diagnosis (keeps the original flat reading).
  - Repair tasks (Replace X tire, Verify tire pressure), ticked as they're done.
  - Disposition, and a rotated stamp (IN PROGRESS / DIAGNOSED / REPAIRED / CHECKED / RELEASED / QUARANTINE).
  - The body scrolls, and the clipboard shrinks on short screens. It opens by itself only when a new order arrives or
    the status changes, not on every pressure reading.
  - The release decision moved in here as **FINAL DISPOSITION** (ORDER 0001, RELEASE / QUARANTINE / NOT YET, with
    coloured top bars). RELEASE is faded out until the job is CHECKED.
- **DiagnosticUI**:
  - **JAS DIAGNOSTIC SCANNER**: dark device body, battery icon, green CRT screen.
    - **VEHICLE STATUS** page: battery V, engine temp °C, oil pressure, electrical, fault codes.
    - **VEHICLE DETAILS** page: vehicle, plate, VIN, odometer, modules.
    - SCANNING… % progress, then SCAN COMPLETE. Buttons: F1 RESCAN, F2 DETAILS/SUMMARY, Backspace BACK (gamepad X/Y/B,
      tap on touch).
    - It closes when you walk 14 studs away. Rescans ask the server again, so M4 can change readings between scans.
  - **DIGITAL TIRE GAUGE**: a handheld with a grey-green LCD, a big PSI number, a bar with the good band, a verdict,
    and a status LED (red / green / amber).
- **RepairUI** (was RepairWheelGui; the same game, restyled): a side panel with TIRE REPLACEMENT / STEP n/4, the 4
  steps (OK / > / pending), a **TOOL** line ("JACK READY", or "USE THE WRENCH [4]" in amber, flashing red when you try
  without it), progress, and the hint split into lines.
- **ShiftReportUI**: the END OF SHIFT paper report (rows 01–03, totals, START NEXT SHIFT).
- **CooperativeUI**: **PLAYERS (n/4)** with signal bars. Each row: headshot, name ("You"), Mechanic, a status dot
  (green idle / amber busy / red down) and the activity ("Changing a tire", "Scanning vehicle"…) or the area ("In
  Service Bay" / "In Office" / "In Waiting Room" / "In Parking"). Opened with Tab (the Roblox player list is turned off)
  or the touch button.
- DialogueGui was restyled to match (dark strip, amber speaker name).

**Tools (PRD 7.5):**
- **Server:** `ToolService` validates the `SelectTool` remote and sets the player attribute `Tool`.
- **What needs which tool:**
  - Check pressure: the gauge.
  - Diagnostic scan: the scanner.
  - Starting a new tire job: the jack.
  - Pumping and lowering: the jack.
  - Nuts: the wrench.
  - Lining up the spare: no tool.
- **Wrong tool:** the notice "Use the right tool: JACK [3]." The repair controller also checks on the client, so it
  doesn't count a pump it would then have to take back.
- **Activity:** `ToolService.SetActivity` sets the player attribute `Activity` for the players list.

**Scanner on the server:**
- New car attributes come from the spec: `Vin`, `Odometer` (the scanner's reading, normally the same as Mileage, so
  M4's mileage anomaly can make them differ), `Battery`, `EngineTemp`, `OilPressure`, `Electrical`, `Modules`,
  `FaultCodes` (JSON).
- The port is `Sedan.Root.Scan.ScanPrompt` ("Plug in scanner / Diagnostic port"), at the **front of the car** with a
  4.5-stud reach. At the door it lost to the wheel prompts, which use the same E key.
- The `ScanRequest` remote handles rescans (it checks the car, the reach, the scanner tool and that the order is open).
- The order records `Checked[wheel]`, `Scanned`, `FindingPsi`, `Repaired` and `Verified`.

**Other:**
- New remotes: `SelectTool`, `ScanRequest`, `ScanResult`.
- The State attribute `CustomerWaiting` drives the "Talk to the customer" objective.
- New: `Markers.Areas` (WaitingRoom / Office / ServiceBay / Forecourt boxes, non-colliding and non-queryable).
- **Gotcha:** while they were queryable, they blocked prompts' line-of-sight. Keep marker boxes `CanQuery = false`.

**Tested in solo Play** (Studio didn't draw the 3D world this session, so only the GUI was seen):
- HUD, prompt and objective at every stage.
- Wrong-tool notices for the gauge, jack and wrench.
- Real number keys switch tools.
- The gauge reading fills the checklist.
- The scanner: progress, both pages, F1, F2, Backspace.
- The repair driven with real Space presses for pumping and tool switches. Resuming after Backspace continues at
  Align.
- Task ticks and the CHECKED stamp, then call-back, disposition, release (with pay notice and cash), quarantine,
  and the report.
- Tab player list.
- No errors.

**Not tested:**
- A real phone or tablet; the scaling is maths only so far.
- Gamepad.
- 2+ players in the list.
- How it all looks over the actual lit 3D shop.

## 2026-11-18: M3, a full shift + inspect and verify steps ✅ (solo Play-tested, not published)

Added the GDD's **diagnosis** and **verification** steps, which the slice plan had skipped, as well as the M3 shift.

**Flow per customer** (3 per shift):
1. **Arrival:** a car drives in through the bay 1 door, then the customer gets out at the driver door (`Markers.DriverExit`)
   and walks to the counter (route `FromCar`). The engine idle plays while the car moves.
2. **Talk:** the same 4 lines as before. The complaint is now vague (pulling to one side, a thumping noise) and doesn't
   say which tire. The work order has a new **FINDING** row, which shows "-" at this point. The customer sits down, and
   their prompt becomes **"Call back"**.
3. **Inspect:** every wheel's prompt reads **"Check pressure"** (hold 0.6 s).
   - A gauge panel counts up to the reading over 1.4 s.
   - Normal tires read 31–34.5 PSI, and the flat reads 3–9.
   - Checking the flat sets FINDING to "Flat tire, rear left", changes the stamp to **DIAGNOSED** and shows the notice
     "Found it…".
   - The flat wheel is **random per car** (FL/FR/RL/RR).
4. **Repair:** only after diagnosis does that wheel's prompt become **"Change tire"** (the M2 game). The stamp then
   reads REPAIRED, with the notice "Tire changed. Check its pressure…".
5. **Verify:** checking the new wheel shows 33 PSI. The stamp changes to **CHECKED**, with the notice "Repair checked. Call the
   customer back…".
6. **Call back:** the customer stands up, walks to the counter (route `ToCounter`) and asks "Is it done?". The
   **decision panel** opens for the player who called them, and the work order card opens beside it.
   - **RELEASE** works only once the job is CHECKED; before that it is greyed out ("Repair not checked yet"). The
     customer pays $120 plus a $10–40 tip and walks back to the car. The car then reverses out and is removed.
   - **QUARANTINE** is always available. The customer gets angry and walks out the front. The car fades out ("kept"). Pay
     is $0, and reputation drops by 1 for a normal customer. M4 adds a bonus for anomalous ones.
   - **NOT YET:** they go back to their chair, and "Call back" is offered again.
7. After 3 customers the **END OF SHIFT** report shows every customer, plate, decision, WHAT IT WAS (always "Normal" until
   M4), pay, total earned and reputation. **START NEXT SHIFT** runs a new one.
- **HUD** (top left): clock · CUSTOMER n/3 · cash · REP, with a till sound when money comes in.
- **Cars:** each one has a random plate (`AB 1234 CD`), colour (5 options), mileage (42k–236k), flat wheel and per-wheel
  pressures. The hand-placed `Bay1Car` is gone; cars spawn from `ServerStorage.VehicleTemplates.Sedan`.

**New / changed (all instances made in Studio):**
- **Server** (`ServerScriptService.ShopSystem`):
  - `ShiftConfig`: counts, timings, pay, colours, pressure ranges, decision reach and timeout.
  - `ShiftService`: runs the night, writes State attributes `Shift` and `ShiftLog`, and listens for the `NewShift` remote.
  - `OrderService`: reads and writes State `WorkOrder`.
  - `DecisionService`: `Ask`/`Cancel`. The server checks the choice: RELEASE needs status Verified, and the player must be
    alive and within 45 studs of the customer. Death, leaving or 90 s without an answer counts as NOT YET.
  - `WorkshopService` was rewritten: prompt modes, the pressure check, diagnosis, verification.
  - `VehicleService` gained `Spawn`, `Drive` (Heartbeat lerp; runs only while a car moves), `FadeOut`, `Pressure` and
    `ClearRemoved`.
  - `RepairService.StopCar`.
  - `CustomerService` gained the call-back, decision and leave flow, and a stand-up fix (it destroys the `SeatWeld`;
    `Humanoid.Sit = false` alone sometimes left them seated).
  - `ShopServer` now just starts the services and the shift.
- **Shared:** new `ReplicatedStorage.Shop.ShiftShared` (remote names, statuses, choices, pressure rules, all the new
  text). In `WorkOrderConfig`, the complaints are vaguer. `RepairShared.TireChanged` was reworded.
- **Remotes:** `TireReading`, `DecisionOpen`, `DecisionChoice`, `DecisionClose`, `NewShift`.
- **Client:** new `GaugeController`, `DecisionController` and `ShiftController`. `WorkOrderController` gained the FINDING
  row, new stamps and `Show()`. `RepairController` notices also look in `ShiftShared`.
- **GUIs:** `GaugeGui`, `DecisionGui`, `ShiftHudGui` and `ShiftReportGui` (with a `RowTemplate`). `WorkOrderGui.Card` is
  394 tall with the new `Finding` row.
- **Markers:** `DriverExit`, plus the routes `FromCar`, `ToCounter` and `ToCar`. `Bay1CarSpot` is now exactly the
  parked car's pivot.
- **Sounds:**
  - `Sedan.Root.EngineSound`: PSE 9113001368, "1991 Range Rover" idle, region 1–14 s.
  - `GaugeGui.HissSound`: PSE 9113046623, an aerosol hiss.
  - `ShiftHudGui.CashSound`: 134810204798705, a "Cash Register" sound by a non-PSE creator. Swap it if you'd rather not
    use it.
  - Wheel templates and `SpareWheel` have a `Pressure` attribute.

**Tested in solo Play:**
- One full shift of 3 customers:
  - Customer 1: diagnosed the front left, repaired it, checked it, and released (real mouse click). $145.
  - Customer 2: diagnosed only. RELEASE was locked, and clicking it did nothing. NOT YET sent them to their chair. A
    second call-back worked, then QUARANTINE (real click). REP −1, they walked out, and the car faded.
  - Customer 3: released. The report showed the right rows and totals, and START NEXT SHIFT (real click) began shift 2
    with a new car.
- The repairs were driven by firing the real `RepairAction` reports, not by mouse. The minigame was already tested by
  hand in M2.
- No errors in the output.

**Not tested / known:**
- Co-op (two players at once), phone and gamepad.
- The car moves by CFrame and doesn't push players: someone standing in the bay doorway as it drives in would be
  clipped.
- Cars arrive with their headlights off, so they're a dark shape.
- A quarantined car just fades away.

## 2026-11-18: M2, tire repair ✅ (solo Play-tested, not published)

Ported from ANMU Chapter 2's FIT THE WHEEL (read from the open PUBLIC Chapter 2 Studio; nothing there was changed).
The ANMU story, inventory and monster-noise hooks were dropped.

**Flow:**
1. Once the customer has handed over the keys, the flat wheel's **"Change tire"** prompt switches on (hold E 0.4 s).
2. **Jack:** pump with Space, click, tap or A in rhythm, 6 pumps. The car really tilts up on a scissor jack for
   everyone. At the top the flat comes off and lies on the floor beside the car.
3. **Line up the spare:**
   - The spare hangs in front of the hub and sways.
   - Move it with the mouse, finger, WASD or the left stick. Turn it with scroll, Q/R, LB/RB or the on-screen
     < > buttons.
   - Hold the orange hole marks on the white stud marks for 0.8 s.
4. **Nuts**, in star order 1-3-5-2-4:
   - Move onto the glowing nut, then circle it clockwise for 2 turns.
   - Too fast and the wrench slips with a clang. The nut keeps its progress.
   - When the last nut is tight, the real new wheel appears on the car.
5. **Lower:** press Space, A or the FINISH button. The car comes down level, the jack clears 2.5 s later, and the work
   order stamp changes **OPEN → REPAIRED**.
- **Co-op:** a second player using the prompt during a job holds the tire. While they hold, the sway is 30% and
  each nut needs 60% of the turns. Ported but **not tested** (needs 2 players).
- **Giving up** (Backspace, B, the X button, or walking 14+ studs away):
  - Before the flat is off, the car drops back onto the flat.
  - After it's off, the car stays on the jack, and the next attempt resumes at the stage it reached.

**Car changes:**
- **Template `Sedan`:**
  - The body and plates are now welded to the anchored `Root`, so tilting `Root` tilts the whole body. Wheels stay
    separate and anchored.
  - Per wheel (FL/FR/RL/RR) there are attachments on `Root`: `Hub_XX` (the wheel centre, LookVector outward, with an
    ObjectValue `Wheel`), `Jack_XX`, `Contact_XX` (where the tire touches the ground) and `Prompt_XX` with a
    disabled `WheelPrompt`.
  - New `Hubs` folder: a brake rotor, flange, 5 studs and a cap behind each wheel, seen when a wheel is off.
  - **Wheel models' pivot = their hub frame.** A leftover PrimaryPart offset had them turned 90°; that is fixed.
- `Workspace.Vehicles.Bay1Car` is a fresh copy of the template. **The flat is no longer posed by hand:**
  `ShopServer` calls `VehicleService.SetFlat(car, "FL")` at start (`CustomerConfig.FAULT_WHEEL`). In Edit the car
  looks healthy; the flat appears in Play.

**New instances:**
- `ServerStorage.RepairTemplates.CarJack`: a scissor jack built from parts. Its `Saddle` holds the PSE sounds
  Pump, Clunk, Clang and Lower.
- `ReplicatedStorage.Shop.RepairAssets`: `Nut`, `Wrench`, `HoleMark`, `StudMark`, `NutGlow` (Highlight), `Lamp`, and
  `SpareWheel` (a healthy wheel whose pivot is its hub frame).
- `ReplicatedStorage.Shop.Remotes`: `RepairStart`, `RepairAction`, `RepairUpdate`, `RepairStop`, `RepairNotice`.
- `StarterGui.RepairWheelGui` (AimArea, Marker ring, Panel with Title/Bar/Percent/Hint, CloseButton,
  TurnLeft/Right, Helper, FinishButton with a keycap, Wrench/Tight/Slip sounds) and `StarterGui.NoticeGui`.

**Scripts:**

| Script | Job |
|---|---|
| `ReplicatedStorage.Shop.RepairShared` | All game rules and numbers (pumps, align tolerances, nut order/turns, slip speed), sway formula, all wording |
| `ServerScriptService.ShopSystem.VehicleConfig` | Lift height (0.45 studs), flat drop (0.27), flat tire / bulge sizes, attachment names |
| `ServerScriptService.ShopSystem.VehicleService` | Car state: `Prepare`, `SetLevel` (tilt about the opposite wheel's contact), `SetFlat`, `RemoveWheel` (lays it on the floor), `FitWheel` |
| `ServerScriptService.ShopSystem.RepairConfig` | Jack timing, sync intervals, reach / stop distance |
| `ServerScriptService.ShopSystem.RepairService` | Sessions, jack posing and lifting, judging every report (the client never decides a result), helper, resume after giving up |
| `ServerScriptService.ShopSystem.WorkshopService` | Hooks each car's wheel prompts. A prompt is on only with an order and a wheel that needs work. On a win it marks the order Repaired |
| `StarterPlayerScripts.ShopClient.RepairController` | Routes start/update/stop to the game's controller; shows notices |
| `StarterPlayerScripts.ShopClient.RepairWheelController` | Camera, spare/nuts/wrench drawing, input, prediction. Hides your body, the work order card and dialogue while open |

**Improvement over the ANMU version:** seating the wrench and every turn report carry the nut number. The server
acknowledges seating, ignores reports for an old nut, and the client asks to resync if no answer comes within 1 s.
This is the "stuck between bolts" problem from ANMU §5bb.

**Tested in solo Play:**
- Whole job by real keyboard and mouse input: 6 pumps → wheel off and on the floor; mouse onto the hub + scroll →
  lined up; mouse circles → all 5 nuts; Space → lowered.
- After the job: all 4 tires on the floor (y 0.20), car level, order Repaired, prompt off, jack gone, camera / FOV /
  HUD / mouse / body restored, card shows REPAIRED.
- Slip: two fast turn reports → slipped, notice shown, progress kept.
- A stale report for an already-finished nut was ignored.
- Giving up at the Jack stage → back on the flat. Giving up at Align → stays jacked, and restarting resumes at Align.
- No errors.

**Not tested:**
- Two players (helper, watching the jack lift).
- Phone (drag, < > buttons, finger circles) and gamepad (stick circles).
- Whether a real mouse's circling speed feels right against the slip limit.
- The walk-away cancel.

**Known looks to tune:** the jack is small next to this car (ANMU scale); the removed flat lies close to the
camera in the Lower view.

## 2026-11-18: M1, customer + work order ✅ (solo Play-tested, not published)

**Flow:**
1. About 4 s after the first player spawns, a customer appears on the forecourt.
2. They walk in through bay 1 to the front counter and wait. Their Talk prompt (E) switches on.
3. Talking plays 4 lines. The speaker shows as "CUSTOMER" until they say their name.
4. With "Here are the keys", the **work order card** slides in on the right with name, plate, vehicle, mileage and
   complaint.
5. They walk to the waiting corner and sit in the first free chair.

**Instances:**
- `Workspace.ShopSetup.Office`:
  - `Counter`, the front counter at z ≈ 45.5, next to bay 1 (customer side z > 46).
  - `Waiting`: chairs `Chair1–3` are real Seats with the attribute `CustomerSeat`, plus a table.
- `Lights.OfficeTube` and `Lights.WaitingTube`, two new tubes over the counter and the chairs.
- `Markers.CustomerRoutes`: folders `Arrive`, `ToWaiting` and `Leave`, each holding numbered invisible points. The
  customer walks them in order. The last `Arrive` point's facing is where they look while at the counter. **Move
  these points if the building changes.**
- `Markers.Bay1CarSpot.Vehicle`, an ObjectValue pointing at the car this customer owns.
- `Workspace.Customers`, the folder customers spawn into.
- `ServerStorage.CustomerTemplates.StandIn`:
  - A plain R15 stand-in with an `Animations` folder (Walk, Idle, Sit, all Roblox defaults) and a
    `HumanoidRootPart.TalkPrompt`.
  - **Placeholder until the Mixamo customers are imported.** The code only needs a Humanoid, a HumanoidRootPart
    with a `TalkPrompt`, and an `Animations` folder with Walk, Idle and Sit.
- `StarterGui.DialogueGui` (`Box` with `Speaker` and `Line`) and `StarterGui.WorkOrderGui` (`Card` with `Fields`
  rows Customer/Plate/Car/Mileage/Complaint, `Tab`, `CloseButton` and `PaperSound`).
- `ReplicatedStorage.Shop`:
  - `Remotes.Dialogue`, a RemoteEvent, server → all clients: (speaker, text, seconds).
  - `State`, whose `WorkOrder` attribute holds the current order as JSON. Clients read it, so late joiners see it too.
- Car attribute `ModelName` = "Sedan"; the car gets `OrderId` when the keys are handed over.

**Scripts** (no comments, per your Roblox rule):

| Script | Job |
|---|---|
| `ReplicatedStorage.Shop.WorkOrderConfig` | Name lists, complaint lines per fault, shift start time 23:40, minutes per order |
| `ReplicatedStorage.Shop.WorkOrderShared` | Builds a work order from a seed + the car's attributes; JSON encode/decode; formatting |
| `ServerScriptService.ShopSystem.CustomerConfig` | Walk speed, line timing, the conversation lines (`{Customer}`, `{Complaint}` are filled in) |
| `ServerScriptService.ShopSystem.CustomerService` | `Arrive()`: spawns, walks routes, talk prompt, conversation, issues the order, sits. Animations follow `Humanoid.Running` / `Seated` events (no polling). `Remove(customer)` cleans up connections |
| `ServerScriptService.ShopSystem.ShopServer` | Starts the first customer once a player has spawned |
| `StarterPlayerScripts.ShopClient.DialogueController` | Typewriter dialogue box |
| `StarterPlayerScripts.ShopClient.WorkOrderController` | Card slide in/out, J or gamepad Y to toggle (bound only while there is an order), tab and × buttons for touch, scales down on small screens |
| `StarterPlayerScripts.ShopClient.ShopClientConfig` | Typing speed, toggle keys, card animation and scale numbers |

**Tested in solo Play:**
- The customer walked the whole route, with walk/idle switching as they moved and stopped.
- The prompt switched on at the counter, and pressing it played all 4 lines.
- The card appeared together with the keys line and filled in correctly: random name, plate `KR 4471 ZN`, Maroon
  Sedan, 148,230 km, complaint.
- The car got its `OrderId`.
- The customer sat in Chair1 with the sit animation.
- J put the card away (tab shown) and brought it back.
- No errors.

**Not tested:** phone (the × button, the tab, card scale), gamepad Y, two players.

## 2026-11-18: M0, night shop with one car ✅ (solo Play-tested, not published)

**Fixed in your building:** 166 of its parts were unanchored with no welds, so the whole building would have fallen
apart in Play. All anchored now. Nothing else of yours was renamed, moved or deleted, except the spawn (below).

**Added (everything is in `Workspace.ShopSetup`, so it is easy to find or remove):**
- `Structure`:
  - `ShopFloor`: concrete floor inside.
  - `Forecourt`: an asphalt apron in front of the bays.
  - `Roof`: a corrugated metal sheet over the trusses at y 33.5. Without it the inside was open to the sky.
  - `BayLines`: yellow lines between the bays, with painted numbers 1–3.
- `Lights`:
  - Fluorescent tube fixtures hanging from the roof: two bright ones over bay 1, one dimmer one over each of
    bays 2 and 3, one over the rear.
  - An orange sodium lamp over each bay door.
  - `YardPole`, a sodium pole light on the forecourt.
  - Only `Bay1TubeFront` and `YardPole` cast shadows, to keep phones fast. Each tube model has a
    `BaseBrightness` attribute, so a later flicker anomaly has a value to return to.
- `Markers.Bay1CarSpot`: an invisible marker where the customer car parks in bay 1, facing in.

**Lighting:**
- ClockTime 23.5, dark blue ambient.
- Atmosphere fog (density 0.4, haze 2.2), SunRays off, Bloom toned down.
- New `NightGrade` ColorCorrection: saturation −0.3, contrast +0.12, slightly green tint.
- The PS1 look still needs low-res textures; Roblox has no vertex-jitter shader.

**Car:**
- `ServerStorage.VehicleTemplates.Sedan`, built from the free Creator Store model 108398927073330 (a boxy 80s sedan
  with separate wheels).
  - **That model hid scripts** (`BloomDefect`, `Shifter.PoseLink`, a typical backdoor), and so did the other
    candidate (71641105057134). All scripts were deleted; only meshes and unions are kept.
- Layout:
  - `Root` is the invisible PrimaryPart; the pivot is at ground level under the car's centre.
  - `Body` contains `Paint`, `Trim`, `Glass`, `Underbody`, `Headlights`, `Taillights` and `Grille`.
  - `Wheels` contains `WheelFL`, `WheelFR`, `WheelRL` and `WheelRR`. Each has a `Tire`, a `Rim`, a `Hub` attachment
    on the tire pointing outward, and a `Flat` attribute.
  - `PlateFront` and `PlateRear` each have a SurfaceGui with an `Arcade`-font number.
  - Attributes on the model: `Plate`, `Mileage`, `ColorName`. The work order will read these.
- `Workspace.Vehicles.Bay1Car` is the placed copy, plate `KR 4471 ZN`.
  - Its **front-left tire is flat**: the tire is squashed, there is a `Sag` bulge at the bottom (a squashed tire
    mesh copy), the rim sits low, and the body leans about 0.3 studs toward that corner.
  - This pose was set by hand for M0. M3's VehicleService should apply the flat from config instead, and the
    placed copy can then go.

**Spawn:** `Workspace.SpawnLocation` moved from the world origin to the forecourt (-58, 0.3, 74), facing the
shop, and made invisible and non-colliding.

**Tested in solo Play:**
- The building stands.
- The car is in bay 1 with all four tires on the floor (y 0.2).
- The plate is readable from the door.
- No console errors.

**Not tested:** phone brightness and performance, and how dark it reads on low graphics settings.
