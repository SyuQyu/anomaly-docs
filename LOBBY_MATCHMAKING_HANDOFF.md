# Car Repair Shop [ANOMALY]: lobby, matchmaking, data, UI (handoff 2)

Written 2026-11-20. Read `SESSION_HANDOFF.md` first (the base game), then this file. This file covers what was
added on top of it: a lobby place, cars as rooms, rejoin, saved player data, the monochrome UI pass and a test van.
Built live in Studio over the Roblox MCP, no Rojo, no local source. Nothing published.

## 1. Places

| Place | Id | Role |
| --- | --- | --- |
| `Car Repair Shop [ANOMALY]` | 111351856377896 | **Lobby** (start place). Shop game removed from it. |
| `Car Repair Shop [ANOMALY] Gameplay` | 82609083848662 | **Match**: the shop game, one reserved server per car. |

Universe 10777476810. Studio ids change every session: call `list_roblox_studios` first.

## 2. Rules (in addition to SESSION_HANDOFF §2)

- All player-facing text in **English** (the game targets players outside Indonesia).
- UI is **monochrome** (tinted greys only). The **world stays in colour**.
- Studio playtest teleports work and load the destination's **latest saved** version, not the open edit state:
  save both places before an end-to-end test.
- Player data uses **ProfileStore** (loleris), not hand-written DataStore code.
- No comments in Luau: the matchmaking/data/lobby code was stripped of comments on 2026-11-20 (only `--!strict`
  directives remain). The design notes that used to live in those comments are this file.
- The van's interior mesh is `Interior_Seats`. Never name a part `Seats`: `CarService` looks up the seat folder by
  that name, and a same-named mesh can win the lookup (that silently dropped CAR 01 once).

## 3. How a match is found

1. Lobby: three vans parked in the garage bays are the rooms (`Workspace.LobbyCars/CAR 01..03`).
2. A player gets in with the van's **Get in** prompt, **QUICK PLAY** (fullest public van) or **FIND A CAR**
   (open vans on other lobby servers → teleport to that lobby server, seated on arrival).
3. First player in = host. Seats 1–4 free; 5–6 open only if the host owns `MatchConfig.BIG_CAR_PASS_ID`
   (still `0` = no pass yet). Host can START early or set the van to friends only.
4. Countdown 20 s (5 s when full / on START) → one group teleport to a reserved Gameplay server.
5. Gameplay admits only players on that match's roster; everyone else is kicked with an `ANOM-RJxx` code.
6. A player who drops gets a **REJOIN** offer in the lobby for 10 min while the match server is alive.
   **Leave Shift** in the pause menu returns to the lobby and gives up the rejoin.

## 4. Where things live

### Both places (code-identical; lobby copy authoritative; compare by code hash after any edit)
- `ReplicatedStorage.Matchmaking.MatchConfig`: VERSION, place ids, seats, countdowns, TTLs, map names.
- `ServerScriptService.Matchmaking.MatchStore`: the only MemoryStore code (tickets, matches, sessions).
- `ReplicatedStorage.PlayerData.PlayerDataConfig` + `ServerScriptService.PlayerData.PlayerDataService`
  + `ServerScriptService.PlayerData.ProfileStore` (asset 109379033046155, code identical to GitHub
  MadStudioRoblox/ProfileStore @45c9847). Data: Cash, Shift {Completed, BestCash, TotalCash, Xp, Level},
  Settings. Studio uses store `DEV_AnomalyPlayer_v1`; live `AnomalyPlayer_v1`.

### Lobby only
- `ServerScriptService.Matchmaking`: `LobbyServer` (start order), `DepartureService` (one teleport owner),
  `CarService` (vans = rooms, server memory), `DirectoryService` (cross-server list, 8 sharded sorted maps),
  `RejoinService`.
- `ReplicatedStorage.Matchmaking.LobbyCopy` (all lobby text), `Remotes` (CarAction, Notice, RejoinOffer,
  RejoinResponse, ListCars, JoinListedCar).
- `StarterGui.LobbyHud` (template) + `StarterPlayerScripts.LobbyClient`.
- `ServerStorage.VanTemplate` (untagged), `Workspace.LobbyCars` (tagged `LobbyCar`), `Workspace.Map`
  (copy of the gameplay map, lighting and grass terrain).

### Gameplay only
- `ServerScriptService.Matchmaking.MatchSessionService` + `MatchServer`: admission, owned session record,
  rejoin tickets, ReturnToLobby, pays every admitted player when a shift ends.
- `Players.CharacterAutoLoads = false`: a character is loaded only after admission.
- `ServerStorage.MatchSession.ShiftEnded` (BindableEvent) fired by `ShiftService` with the shift cash.

## 5. MemoryStore design (why it will not repeat ANMU's bugs)

- No heartbeats except the match's session keep-alive (20 s, TTL 60 s). Records live by TTL.
- Tickets are revoked with a conditional `UpdateAsync` tombstone, never get-then-remove.
- The session record has an owner (jobId + generation); a second server cannot take or renew it.
- Every rejection consumes the ticket that routed the player; a dead route is dropped on lobby join.
- Refused transforms return nil (no write, no TTL reset).

## 6. UI pass

- Textures (procedural, NumPy/Pillow seed 1977, no AI, no text), uploaded 2026-11-19:
  panel frame `104888855026335` (9-slice 40,40,472,472), button frame `82209239162563` (14,14,114,50),
  grain `99310308346139` (tile 256), diamond `116188228581540`.
- Lobby: Merriweather titles, SourceSans Bold buttons, RobotoMono numbers, Montserrat Light timer.
- Gameplay: `UITheme` colours remapped to greys (names kept), `ShopClientConfig` greyed **except instrument
  colours** (LED_*, MARK_*, RING_*), templates greyed, Oswald → Merriweather/SourceSans, frame + grain on panels
  and boxed buttons. `PauseMenu.Side` left unskinned (its UIListLayout would lay the images out).

## 7. Test van (do not ship)

`ServerStorage.VanTemplate` and the three lobby vans come from an **unlicensed** model (DesireFX redistribution).
Test only; replace before publishing. Files: `assets/anomaly_van_test` (.blend, .fbx, README).
Door hinge data is stored as attributes on each door model; the client door / light animation is **not built yet**.

## 8. Open items

1. ~~Gameplay shift is broken (Office missing).~~ Fixed 2026-11-20: see `GAMEPLAY_SHOP_HANDOFF.md` §3.
3. Van doors / lights animation (client), seat positions check, replace the test van.
4. Create the VIP car gamepass and set `BIG_CAR_PASS_ID`.
5. Untested: real disconnect + rejoin with 2 players on live servers; cross-server FIND A CAR on live.
6. Save the Gameplay place (UI pass not saved yet as of this file).
