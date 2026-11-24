# Role gacha, lobby item shop, Endless Night: agreed design (2026-11-24, Syu + Claude)

Status: **design agreed with the owner, not built yet.** Build order below. Update this file as parts land.
Decisions the owner made: gacha costs coins **and** Robux; all four exclusive roles; all four item groups;
Endless Night ends on **3 strikes**.

## 1. Role gacha (Lobby)

- Exclusive roles, only from pulls (never sold directly):

  | Role | Rarity | Perk (scales with role level like the shop roles) |
  | --- | --- | --- |
  | Night Owl | Rare | Night vision: the shift looks brighter for this player only (client exposure) |
  | Medium | Epic | Hears anomalies: a faint whisper plays when an anomaly starts near you |
  | Inspector | Epic | Scanner and gauge show one extra hint line per car |
  | The Regular | Legendary | +25% tips, and double coins for every anomalous car quarantined |

- Odds: Rare 70 % / Epic 25 % / Legendary 5 %. Pity: the 40th pull without a Legendary is a Legendary.
  A duplicate gives that role XP instead.
- Cost: 400 coins per pull, 3600 for ten. Robux pulls as developer products.
- **Robux rules (Roblox policy):** odds shown on the gacha screen before any purchase; the Robux buttons are hidden
  for players whose `PolicyService:GetPolicyInfoForPlayerAsync().ArePaidRandomItemsRestricted` is true.
- Server decides every pull; the client only asks. Pity and pull count live in the profile.

## 2. Lobby item shop (coins), used in a shift

- Bought in the lobby, kept in the profile (count per item), up to **3 equipped** (loadout) before the van leaves;
  each use spends one.

  | Group | Item | Effect in the shift |
  | --- | --- | --- |
  | Repair | Tire Patch Kit | fixes a flat without the wheel swap |
  | Repair | Diagnostic Chip | one instant scan |
  | Repair | Jump Pack | finishes a dead-battery job in one step |
  | Survival | Salt Pouch | repels a lurker once, from range |
  | Survival | Energy Drink | +30 % walk speed for 20 s |
  | Survival | Flare | lights an area for 60 s |
  | Info | Pocket Watch | tells how many anomalous customers are left this shift |
  | Info | CCTV Film | replay the last 10 s of a camera once |
  | Booster | Lucky Charm | +50 % coins from the next finished shift |

## 3. Endless Night (game mode)

- Host picks the mode in the lobby van: **Night Shift** (today's 3 customers) or **Endless Night**.
  The mode travels in the teleport data (MatchConfig contract: identical in both places).
- Customers keep coming. Every 3 customers the night gets harder (more anomalies, shorter gaps, faster threats).
- **Strike** for releasing an anomalous car or quarantining a normal one; **3 strikes** end the night; dying to a
  threat also ends it.
- Coins per customer served; best night (customers served) saved in the profile and shown on a leaderboard.

## Data (contract modules, byte-identical in Lobby and Gameplay)

- `PlayerDataConfig.TEMPLATE`: `Gacha = { Pity, Pulls }`, `Items = { [id] = count }`, `Loadout = { ids }`,
  `Endless = { Best }`. Sanitised on load like the rest.
- `ClassConfig`: four new roles with `Gacha = true` and `Rarity`. New `GachaConfig`, `ItemConfig`.
- `PlayerDataService` stays the only data owner and the only `ProcessReceipt` (role products + gacha products).

## Build order

1. Data contract (both places, hash-checked). **Done 2026-11-24.**
2. Gacha: server pull, Robux products (Open Cloud), gacha screen in the lobby. **Done 2026-11-24** (products
   3735713171 x1 39 R$, 3735713219 x10 349 R$). Role perks in gameplay still to do.
3. Item shop screen + loadout; gameplay effects one item at a time. **Done 2026-11-24**, except CCTV Film (hidden
   until a camera recording system exists) and Inspector's extra hint line.
4. Endless Night: van mode pick, teleport data, endless loop and strikes in `ShiftService`, leaderboard.
