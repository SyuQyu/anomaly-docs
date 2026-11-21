# M5 playtest: Car Repair Shop [ANOMALY]

Prepared 2026-11-18. Place 111351856377896.

## The one question

**Is it fun to do a normal repair, notice that something is wrong, and decide what to do about it?**
Everything below is there to answer that. Don't explain the anomalies to testers: the night notice on screen is all
they should know.

## Before the session (you)

1. In Studio: **File → Publish to Roblox** (Claude never publishes). Check that the game is private or friends-only, and
   that the server size allows your group (the slice is built for 1–4).
2. Join once yourself and play one customer, to make sure the published build starts (night notice → customer arrives).
3. Analytics: after the session, open **Creator Dashboard → your experience → Analytics → Custom Events**. Two events
   are logged (they only show for published servers, not Studio, and can take a while to appear):
   - `Decision`: value 1 = right call, 0 = wrong. Field 1 = Normal / Anomalous, field 2 = Release / Quarantine,
     field 3 = which anomalies (e.g. `WrongPlate+ShopReacts`) or None.
   - `ShiftEnded`: value = right calls. Field 1 = "2/3", field 2 = reputation, field 3 = players in the server.
   A right call = quarantine an anomalous car, release a normal one.
4. Have this page and the observer sheet below open somewhere the testers can't see.

## Running it (about 40 minutes)

| Part | Time | What |
|---|---|---|
| Shift 1, solo | 10–12 min each | Each friend plays a shift **alone** in their own server. Don't help. Watch one of them (screen share). |
| Quick check | 2 min | Ask only: "Did anything feel off before the report?" Write the answer down word for word. |
| Shift 2, together | 12–15 min | Everyone in one server. Same rule: no hints. |
| Questions | 10 min | The questions at the bottom, everyone answers on their own first, then talk. |

Each shift is 3 customers. One of them is anomalous with 1–2 of these (testers must not see this list):

| | What's wrong | Where you can catch it |
|---|---|---|
| A1 | The plate on the car is one character off from the order | Walk round the car, compare with the order (J) |
| A2 | The odometer is 18,000–42,000 km lower than the order | Scanner → F2 details |
| A3 | A different-looking person comes back with the same name | Remember who dropped it off; the swap happens while they wait unseen |
| A4 | Glides with no animation, head turns to follow you | Watch them walk and sit |
| A5 | Waiting-room clock runs backwards, radio turns to static | Waiting room or CCTV CAM 03 while they sit |

## Observer sheet (one per tester per shift)

| Customer | Inspected tires? | Scanned (F2 details)? | Looked at plate? | Used CCTV? | Visited waiting room? | Decision | Right? | Time from call-back to decision | What they said |
|---|---|---|---|---|---|---|---|---|---|
| 1 | | | | | | | | | |
| 2 | | | | | | | | | |
| 3 | | | | | | | | | |

Also note: where they got lost, anything they tried that didn't work, every "huh?" or "wait…".

## Questions after (answer alone first)

1. From 1 to 5, how fun was **spotting that something was wrong**? Why?
2. Before the report, did you notice anything odd? What, and when?
3. When the report showed the truth, did it feel **fair** ("I could have seen that") or **unfair** ("no way to know")?
4. From 1 to 5, was the **tire repair** fun, OK, or a chore?
5. What made you quarantine (or release) each car?
6. Did you use the cameras? The scanner details? The case file?
7. Was anything confusing about what to do next?
8. Would you play another shift right now?

**It worked if:** at least half the testers noticed something before the report, most call the reveal fair, the
repair isn't mostly called a chore, and most would play another shift.

## Known limits (tell testers only if they hit them)

- Releasing needs the repair to be finished and checked. Quarantine is always allowed.
- Time on the shift clock moves with real time and jumps forward when the next customer arrives.
- Reputation and the truth only show in the report (on purpose).
- The work order slides in for **everyone** whenever its status changes (each tire check, repair, verify). With 4
  players this may feel busy: ask about it.
- A3 swaps only when nobody is within 20 studs of the waiting customer; with a crowd it swaps when they're called back,
  in front of you.
- A4's head follows the **nearest** player.
- Only the player who calls the customer back gets the release/quarantine choice.
- Anyone can press START NEXT SHIFT on the report.
- First load in Studio can print an "Infinite yield possible … DialogueGui" warning; it resolves itself (slow GUI load).
- Untested before this session: phones, gamepads, 2+ players together, an anomalous car being released
  (should show UNRESOLVED in the report and case file).
