# Retail shop, stock and free decoration handoff (2026-11-22)

Gameplay place **82609083848662**. Built live through the Roblox Studio MCP by Aizu + Claude from the "Gameplay
Expansion Specification" (retail shop, stock management, free decoration, tycoon). **Nothing is published.**
Builds on [GAMEPLAY_LOOP_HANDOFF.md](GAMEPLAY_LOOP_HANDOFF.md) (customers, cashier, Director, economy).

## What the player sees

- **Supplies aisle** west of the bays (x ≈ -129, z 62–93): five retail shelves placed for you on first load
  (Fluids, Parts, Tools, Tire Display, Battery Stand). Products sit on the shelves as real models with price tags.
- **Shoppers** walk in from the road while the shop is open (2 at most at once), browse 1–4 shelves, take products
  into a red basket (tires and batteries are carried in front), queue at the same till as service customers and
  wait for you. Press **Serve** on them → *Ring it up ($X)* or *Sorry, I can't sell you that*. Some only look and
  leave, some walk out if nobody serves them, some find an empty shelf and say so.
- **Hybrid customers:** a service customer may (35 %) pick 1–2 things off the shelves while their car is worked on.
  RELEASE at the till charges repair + tip + those items as one bill.
- **Shop terminal** gained two tabs: **SUPPLIER** (order stock into the backroom, ×1 or ×5; tires/batteries can be
  moved to the repair rack) and **DECOR** (32 items with 3D previews, owned/max, appeal/comfort/light).
- **Restock:** press **Restock** at a shelf → per product: on shelf x/cap, backroom count, **+1** and **FILL**.
- **Build mode:** **B** (or the BUILD button by the tools, D-pad Up on a pad). Storage tray at the bottom, ghost
  preview in green/red with the reason. PC: left click place, R turn 90°, Q/E turn 15°, G snap, X cancel,
  Delete store. Touch: tap where it goes, then PLACE; buttons for rotate/snap/cancel/store/exit. Click a placed item
  to move it (it stays put until you confirm; cancel leaves it where it was).

## Where things are

| Part | New | Changed |
|---|---|---|
| Config (shared) | `ReplicatedStorage.Shop.ProductConfig` (11 products, prices, display capacity per rack level, backroom capacity), `DecorationConfig` (32 items, limits, effects), `PlacementRules` (zone/blocked/overlap rules used by client preview and server) | `TycoonConfig` (tabs SUPPLIER / DECOR, rack descriptions), `ShiftShared` (notices, report lines) |
| Server | `DecorationService` (decor data, spawn/despawn, buy, place/move/store, locks, path check, effects), `ProductInventoryService` (backroom / shelves / repair reserve, reservations, baskets, supplier orders, restock, shelf rendering), `RetailCustomerService` + `RetailCustomerConfig` (shopper AI, checkout, hybrid), `RetailAnomalyCatalog` (17 events) | `EconomyService` (Retail/Decor sections, `Adopted`, `Commit`), `CashierService` (shared queue), `CustomerService` (queue + hybrid hooks), `ShiftService` (retail spawning per shift, hybrid bill, comfort tip), `UpgradeService` (`Decor:` purchases, `NearTerminal`), `AnomalyDirector` (merges retail catalog, shopper context, `ResolveShopper`, light cut), `AnomalyConfig` (retail trigger chances), `CashierConfig`, `ShopServer` |
| Client | `RestockController`, `BuildModeController`, `ModelPreview` | `WorkshopShopController` (tabs, previews, second button), `CctvAnomalyController` (`HideStock` kind), `ShiftController` (retail line + findings in the report), `ShopClient` |
| Instances | `ReplicatedStorage.Shop.DecorTemplates` (32 models), `RetailAssets` (11 product models, `Basket`, `PriceTag`, `UnknownProduct`, `Steps`), `StarterGui.RestockUI`, `StarterGui.BuildModeUI`, `MainHUD…Tools.Build`, remotes `DecorAction` / `RetailAction`, `Workspace.ShopSetup.Markers.Retail` (Spawn, Entrance, Exit, Queue 1–4, Wander, StartLayout), `Markers.Build` (Zones.Interior, Blocked: Bays, FrontLane, Cashier, OfficeDoor, Terminal, BackDoor, WaitingPath, MechanicHome; PathStart), `ServerStorage.RetailDebug` (Studio only) | `WorkshopShopUI` item template (Preview, AltButton), `Markers.Staff.MechanicHome` moved to (-117.5, 76) out of the aisle |

Placed decor lives in `Workspace.Decor` (created at runtime; models named `D1`, `D2`…, attributes `DecorId`,
`ItemId`, `Slots` JSON for shelves, `MovingBy` while someone moves it).

## Data (one shared workshop, saved in the host's profile like the rest of `Workshop`)

```
Workshop.Retail = { Backroom = { [ProductId] = n } }
Workshop.Decor  = { NextId, Seeded, Objects = { { Id = "D7", Item = "Sofa", Placed = true,
                    CF = { x, y, z, rx, ry, rz }, State = { Slots = { { Product, Qty } } } } } }
Workshop.Stock  = repair reserve (unchanged: Tire, Battery, Radiator, used by repairs and the mechanic)
```

- Three stock places: **backroom** (supplier orders land here, capacity 40 / 90 by rack level), **display** (shelf
  slots, `Qty`; shoppers only buy from here), **repair reserve** (`Workshop.Stock`). Retail never touches the repair
  reserve; moving backroom tires/batteries to the repair rack is an explicit button.
- Reservation: taking an item off a shelf reserves it (it disappears from the shelf, another shopper can't take it);
  cancel/walk-out/refusal releases it; only `Settle` after a successful payment removes it from `Qty` and pays the bank.
  `Settle` is idempotent (no double payment).
- Stored furniture keeps its state (a stored shelf keeps its stock). Only ids + transforms + state are saved, never
  instances. Unknown items / bad numbers are dropped on load.

## Rules and numbers (all in config)

- **Rack I vs II:** Rack II lets you stock and sell tires, batteries and tools, raises shelf capacity
  (e.g. oil 6 → 10) and backroom capacity (40 → 90), on top of its old effects.
- **Decor effects** (`DecorationConfig.EFFECTS`): appeal → more shoppers (up to +45 % rate) and higher buy chance
  (up to +20 %); comfort (chairs/sofa) → +$2 tip per point (max $12); light → up to −15 % anomaly trigger chance.
- **Placement:** inside `Build.Zones.Interior`; not overlapping any `Build.Blocked` box (bays, front lane/queue, till,
  office door, terminal, back door, waiting-room path, mechanic spot), other decor, or the map's solid parts; floor /
  wall / ceiling / surface (lamp or radio on a desk, bench, table or crate) by the hit surface. The server repeats the
  check and then runs a **path check** for solid items (superseded: see "Layout drives the shop" below; shelves
  are now a warning, the till/queue/waiting/exit paths stay hard). Max 80 placed, 120 owned, per-item max in config.
- **Multiplayer:** one shared layout; `BeginMove` locks an object to one player (90 s, released on leave); other players
  get "X is moving that" for move/store/restock. Purchases and restocks are server-checked (terminal / shelf reach,
  rate limit, money, capacity).

## Retail anomalies (`RetailAnomalyCatalog`, picked by the same Anomaly Director)

Triggers: `RetailArrival`, `RetailBrowsing`, `RetailSelecting`, `RetailShelfTake`, `RetailPriceCheck`, `RetailQueue`,
`RetailCheckoutDialogue`, `RetailPayment`, `RetailLeaving` (chances in `AnomalyConfig.DIRECTOR.TRIGGER_CHANCE`), plus
the existing idle / CCTV triggers. Shopper-bound events only fire on the anomalous shopper (16 % per shopper, +4 % per
shift, max 35 %) so findings stay truthful.

| Event | Kind | Locks the till? |
|---|---|---|
| SilentShopper | no footsteps (shoppers have footstep sound now) | no |
| WrongPurchase | asks for a product that doesn't exist | **yes** |
| RepeatedShopper | a copy stands at another shelf, vanishes when you get close | no |
| EmptyBasket | full basket, till counts nothing, shelf full again | no |
| UnregisteredCustomer | CCTV only: customer in queue spot 2 on Cam02 | no |
| DisappearingStock | shelf shows fewer items than the record | no |
| WrongLabel | price tag shows a wrong name/price (shopper may comment) | no |
| EndlessShelf | more items on the shelf than it can hold | no |
| ReturningProduct | what a shopper just bought is back on the shelf | no |
| UnknownProduct | black "???" box on a shelf | no |
| IncorrectReceipt | receipt notice lists an item never picked | no |
| WrongShopperName | shopper's name changes at the till | **yes** |
| ImpossibleCurrency | payment in notes from no country (interrupts payment) | **yes** |
| UnregisteredTransaction | till rings up a sale by itself (stock −1, bank +price) | no |
| InvisibleShopper | CCTV only: shopper at a shelf on Cam02 | no |
| FuturePurchase | CCTV only: shopper at a shelf; the next real shopper looks the same and goes there | no |
| EmptyShelfRecording | CCTV only: a stocked shelf shows empty on Cam02 | no |

Locked till (shoppers): tray locks, normal sale is cancelled, **basket and reservations are kept**, options become
*Refuse the sale* / *(Say nothing)*; refusing unlocks the tray and resolves the event. CCTV-only events never create
a world NPC (models live in `ReplicatedStorage.Shop.AnomalyCctv.Live` and are drawn only under Cam02).

## Shift report

`shift.Retail` = customers, sales, revenue, items, walk-outs, refused, browsed-only, out-of-stock, incidents. Retail
revenue is in TOTAL EARNED; the notes get a "Shop counter: …" line and up to 8 retail findings. The shift waits up to
50 s at the end for shoppers to finish.

## Test results (solo Studio Play, PC)

| Spec test | Result |
|---|---|
| 01 Service customer repairs and pays | ✅ (repair marked verified by setting the WorkOrder attribute; repair steps themselves unchanged from the earlier tests) |
| 02 Retail one item | ✅ $18, shelf 3→2, shopper left |
| 03 Retail multiple items | ✅ coolant + 2 oil, $51 |
| 04 Out of stock | ✅ empty Parts shelf: nothing bought, out-of-stock counted, left |
| 05 Supplier + restock | ✅ ORDER 5 coolant (−$35, backroom +5) through the UI; FILL on the shelf (3→6) through the UI |
| 06 Sale reduces display, adds money | ✅ |
| 07 Repair reserve untouched by display sales | ✅ tire sold from display, reserve stayed 2 |
| 08 Anomaly interrupts checkout | ✅ WrongPurchase: tray Locked, reservation kept through "say nothing", refuse → tray Closed, reservation released, $0 |
| 09 CCTV-only shopper | ✅ model only under Cam02 (checked on the client), no world NPC |
| 10 Buy and place furniture | ✅ sofa / clock / shelf bought in DECOR and placed (mouse in build mode + remote) |
| 11 Move a shelf, stock kept | ✅ Fluids shelf moved, `Slots` identical, 9 product models re-rendered |
| 12 Invalid placement | ✅ bay, front lane refused; workbench across the Parts shelf refused by the path check |
| 13 Cancel move | ✅ position unchanged, lock cleared |
| 14 Rejoin restores layout | ⚠️ simulated: layout JSON round trip (DataStore format) + full rebuild gave identical data, positions and rotations; a real rejoin with a DataStore is **not tested** (Studio has no API access) |
| 15 Two players on one object | ⚠️ simulated with a fake lock owner: move / store / restock refused with "Pat is moving that"; real 2-player test **not done** |
| 16 Four players | ❌ not testable in Studio |
| 17 Retail + service share the queue | ✅ shopper at till, shopper at spot 1, service customer at spot 2; each moved up in turn |
| 18 Hybrid combined invoice | ✅ pay 178 = repair 120 + tip 32 + retail 26 (spark plugs + oil filter) |

Also seen firing naturally: DisappearingStock (RetailBrowsing), SilentShopper (RetailArrival), IncorrectReceipt
(RetailPayment). Forced: WrongPurchase, InvisibleShopper. Build-mode ghost tint checked by code (red eb463c / green
5adc78); the 3D view went grey in Studio during that check, so it was not seen on screen.

**Bugs found and fixed while testing:** queue passed a CFrame where the marker part was expected (service customer and
shopper threads crashed, would have soft-locked the shift); Highlight on the ghost didn't render (now tints the parts);
PLACE button under a mouse dragged the ghost onto the button (PLACE is now touch-only, the preview freezes over the build
UI); hybrid customers could pick empty shelves; basket held at a wrong angle.

## Layout drives the shop (added later on 2026-11-22)

Furniture placement now changes how shoppers behave, with every effect visible in build mode. There are no hidden modifiers.

- **`ServerScriptService.ShopSystem.LayoutService`** (new; numbers in **`ReplicatedStorage.Shop.LayoutConfig`**)
  re-analyses the shop only when furniture is placed, moved, stored or loaded, when the shop opens or closes, or when a
  shopper reports a shelf they couldn't reach. Waits 0.5 s for changes to settle, runs its path checks in parallel,
  and never polls. For each shelf it works out:
  - **Access:** each browse spot in front of the shelf (one per 2.8 studs of shelf width) must be free of solid
    parts. A shelf with no free spot is *Blocked*, one with no walking path from the door is *NoPath*, and one with
    no path on to the till is *NoTill*.
  - **Walking distances** to the door and to the till (real path lengths).
  - **Visible from the door** (ray from eye height; something tall in between hides it).
  - **Lit** (within the radius of a placed lamp).
  - **Spots:** how many shoppers can browse it at once.

  Results are written as model attributes (`LayoutAccess`, `LayoutVisible`, `LayoutLit`, `LayoutEntrance`,
  `LayoutCashier`, `LayoutSpots`) and to `State.Layout` (JSON). The interaction side is the shelf's `BrowsePoint`,
  so it moves and turns with the shelf.
- **Shoppers** (`RetailCustomerService`):
  - They only plan shelves that are *Open*. A shelf hidden from the door is only found 30 % of the time.
  - Shelf choice is weighted by stock, preference, being seen from the door, being lit, and nearness to the door
    and to the till. They visit shelves nearest the door first.
  - Each shopper takes a free browse spot. On a full shelf they wait 2.5–5 s, then try another shelf.
  - A shelf they can't actually reach (path fails, or a ray from where they stand doesn't hit the shelf) is reported
    as blocked, the layout is re-checked, and they take a spare shelf (up to 2). With nothing bought, they say
    "I can't even get to that shelf." and leave.
  - A lit shelf gets 25 % longer browsing and +5 % buy chance.
  - The shift report gets "Shop floor: N couldn't reach a shelf, N gave up on a crowded one."
- **Placement rules** (`DecorationService`):
  - **Hard paths:** customers must still be able to walk from the door to the till, the 4 queue spots, the
    waiting-room path, a waiting seat and the exit. Any of these that was reachable before a placement must still
    be reachable after it, or the placement is undone. Bays, the front lane, the till and the other `Build.Blocked`
    boxes stay forbidden; vehicle routes inside the building all lie in `Bays` / `FrontLane`.
  - **Shelves are soft:** blocking one is allowed, but you get "Placed, but shoppers can't reach: Fluids Shelf."
    (or "Moved, but…").
  - **Refused:** any placement that would leave *no* reachable shelf ("That would leave no shelf shoppers can reach.").
  - The before/after path checks are cached and run in parallel: a placement takes 0.2–0.4 s (was 2.9 s).
- **Functional furniture** (`DecorationConfig.ITEMS[…].Function`). The DECOR tab shows `FUNCTION: …` or
  `COSMETIC` on every item.

  | Item | Function |
  |---|---|
  | Shelves | Sell stock to shoppers |
  | Cabinet / Storage Shelf | +10 / +15 backroom capacity. Can't be stored while the backroom would overflow (stock is never lost); moving is allowed |
  | Workbench | Repair steps on a car within 18 studs take 20 % less time (prompt shows `· WORKBENCH`); also speeds the mechanic |
  | Tool Storage | Mechanic jobs 15 % faster per chest, down to 70 % at most |
  | Waiting chair / sofa | Real `Seat`s (tag `DecorSeat`, 1 or 2 per item). A service customer picks at random among free office seats and placed seats that can be walked to. Can't be moved or stored while someone sits there |
  | Ceiling / wall / desk / industrial lamps | Light shelves within 16 / 12 / 8 / 22 studs (plus the old anomaly-chance cut) |
  | **CCTV Monitor** (new item, $150, on a desk, bench or table) | Opens the normal camera view (prompt `CctvPrompt`) |

  The rest is cosmetic (appeal only).
- **Build mode labels:** while in build mode every functional object shows a small label:
  - Shelves: "OPEN TO SHOPPERS · 39 to door · 30 to till · 2 at a time · seen from the door · lit", or
    BLOCKED / NO WAY IN / NO WAY TO TILL with the reason.
  - Seats: WAITING SEAT / SEAT UNREACHABLE.
  - Other furniture: its function.

  The tray shows "SHELVES REACHABLE n/m". Template: `ReplicatedStorage.Shop.LayoutAssets.ShelfStatus` (BillboardGui).
- **Saved state:** entries gain `Owner` (UserId of the buyer). Stock, product assignment and storage bonus stay with
  the entry through move, store and re-place. Upgrade level is shop-wide (rack level), not per object.

### Layout tests (solo Studio Play, all through the real player remotes)

- Storage shelf placed in front of the Fluids Shelf: placed with the warning; shelf → Blocked; backroom 40 → 55.
- A shopper who prefers fluids skipped the blocked shelf and browsed the Parts Shelf.
- A part put in front of the Tool Display behind the analysis' back:
  - The shopper went there, couldn't reach it, it was re-checked to Blocked, and the shopper took the Fluids Shelf
    instead, bought and queued.
  - Before the fix, the shopper stood beside the obstacle and counted as there. Found and fixed with the ray check.
- Cabinet between door and Battery Stand: "hidden from the door". Moving the cabinet away made it visible again.
- Four shelves stored, then a move that blocked the last one: refused. Shelves placed back with their stock intact
  (Parts Shelf 3/2/2/2). Workbench moved in front of a shelf: "Moved, but shoppers can't reach: Fluids Shelf."
- Three shoppers sent to the 2-spot Fluids Shelf:
  - Never more than 2 browsed it at once.
  - The third gave up on it (Crowded 1), bought at the Parts Shelf instead and queued.
- Storage:
  - With 3 cabinets, capacity was 70 and the backroom held 68.
  - Storing a cabinet was refused; moving it was allowed.
- Service customer (office seats reserved for the test) sat on the placed waiting chair.
- Workbench 15.6 studs from bay 1:
  - The battery step's hold went 1.2 → 0.96 s with the WORKBENCH tag. To test this I set that car's fault to a
    diagnosed dead battery by hand.
  - Moving the bench away put it back to 1.2 s by itself.
- Mechanic hired + one tool chest: job time 38 s (45 × 0.85).
- Ceiling lamp at z 72: the 4 shelves within 16 studs lit, the one 21 studs away not.
- Placed CCTV monitor opened the camera view.
- Layout JSON round trip: data identical, capacity and layout restored. No console errors; no ZZ leftovers.
- **Not tested:**
  - The build-mode labels on screen (the 3D view stopped rendering; text checked from the client).
  - Phones and gamepad.
  - Real multiplayer.
  - Hard-path refusal: no spot in the room can cut those paths now, because they run through the forbidden boxes.
  - A natural battery/radiator job at the workbench.
- **Open:**
  - A temporary obstacle that isn't furniture (not something the game creates today) keeps a shelf Blocked until
    the next layout event.

## Not tested / open

- Real multiplayer (2–4 players: shared stock, locks, build at the same time, host leaving), real DataStore save/rejoin.
- Phones (touch tap-to-place, PLACE button, restock and terminal on small screens), gamepad build mode.
- Not every retail anomaly was seen in play (RepeatedShopper, EmptyBasket, EndlessShelf, UnknownProduct, WrongShopperName,
  ImpossibleCurrency, UnregisteredTransaction, FuturePurchase, EmptyShelfRecording, UnregisteredCustomer,
  ReturningProduct, WrongLabel were not run).
- Shopper animation: only the existing Walk/Idle (no reach/pick-up animation); products jump into the basket.
- Decor templates are simple part builds (no meshes). Lamps add real lights (shadows off).
- Supplier delivery is instant into the backroom (no truck/crates yet).
- Known: pressing 1–4 for a dialogue option right after the work-order clipboard pops open can select a tool instead.
- Studio-only test hook `ServerStorage.RetailDebug` (BindableFunction, not reachable by players): Spawn, ForceNext,
  Force (anomaly with a shopper context), SetSlot, HybridChance, Decor (Roundtrip / FakeLock / Unlock / Snapshot).
