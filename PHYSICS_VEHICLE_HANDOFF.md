# Physics NPC car: prototype handoff

Status on 2026-11-27 (Aizu + Claude): **one physics car prototype plus an AI driver, tested on an isolated test
track.** Nothing here is wired into the live customer flow yet. Customer cars still use `VehicleService.DriveAlong`
(the anchored root steered by AlignPosition / AlignOrientation). Gameplay place, not published.

This is the first stage of the "Physics-based autonomous NPC vehicle" master prompt. The user's advice was: get one
sedan right first, then convert the rest. Phases 0–3 are done. Phases 4–8 (live arrival, bays, departure, other
templates, multiplayer) are next, after the user has looked at the prototype.

## Where it lives

| Thing | Path |
|---|---|
| Prototype car | `ServerStorage.PhysicsLab.NPC_PhysicsVehicle_Prototype` |
| Test track + markers | `ServerStorage.PhysicsLab.TestTrack` (parent it to Workspace to test; it sits at x≈380–520, z≈−120–320, away from the shop) |
| Config (all tunables) | `ServerScriptService.PhysicsVehicle.PhysicsVehicleConfig` |
| Car controller | `ServerScriptService.PhysicsVehicle.PhysicsVehicle` |
| AI driver | `ServerScriptService.PhysicsVehicle.PhysicsDriver` |

No production script or template was changed for this work, so there are no new backups.

## Phase 0 audit (what the live cars are)

- **Templates:** four in `ServerStorage.VehicleTemplates`: Sedan, Estate, Roadster, Saloon.
  - Sedan: body is 7 UnionOperations, no opening doors.
  - Estate, Roadster, Saloon: imported MeshPart bodies with hinged doors, hood and tailgate (Motor6D `HingeMotor`).
- **Root:** an anchored 1-stud slab named `Root`, non-colliding. Everything is welded to it with WeldConstraints. It
  carries the attachments the repair game uses: `Hub_`, `Jack_`, `Contact_`, `Prompt_`, `Scan`, `Engine`.
- **Wheels:** `Wheels.Wheel<FL|FR|RL|RR>` models (Tire + Rim MeshParts, no collision).
  - `VehicleService.mount` gives each Tire a Motor6D `WheelMotor`; the client `WheelController` spins it for looks.
  - The Sedan also has `Hubs.<key>` brake rotor / stud parts, used when a wheel is taken off.
- **No physical parts:** no HingeConstraint, SpringConstraint or VehicleSeat anywhere. `DriverSeat` is a plain Seat.
- **Movement:** `VehicleService.DriveAlong` unanchors Root, turns on `DriveAlign` / `DriveTurn` and moves their
  targets along a rounded path every Heartbeat. It also puts every part in collision group `DrivingCar` (collides
  with nothing), then re-anchors the car on arrival.
- **Repair code needs an anchored body:**
  - `VehicleService.SetLevel` / `FrameAt` write `Root.CFrame` directly to lift a corner (jack, flat tyre).
  - `SetFlat`, `RemoveWheel` and `FitWheel` re-weld wheels to Root.
  - **So a physics car must be frozen (anchored, wheels welded or anchored) while it sits in a bay for repair.**
- **Routes:** `Workspace.ShopSetup.Markers.Arrival`:
  - `CustomerVehicleSpawn` (−48, 245).
  - `ArrivalPath` 1–3.
  - `CustomerVehicleStop` (−70, 86), facing −Z.
  - `DeparturePath` 1–3.
  - Bays are `Bay1/2/3CarSpot` at x −116, facing −X.
- **Collision groups:** Default, StudioSelectable, Plugin_Unselectable_Group, and DrivingCar (collides with nothing).
- **StreamingEnabled is on.**

## Prototype build

Made from a clone of the `Sedan` template. The body, glass, lights, plates and paint are untouched.

- **Chassis:** `Root`.
  - Unanchored, CustomPhysicalProperties density 3.85 (mass ≈ 600), CanCollide off. The name is kept so the existing
    attachments and code still find it.
  - Its centre of mass is 2.2 studs up, mid-car.
- **`MainCollision`:** an invisible box, 7.4 × 2.2 × 19.4, bottom 1.35 studs up. It is welded to Root, massless, and
  is the only body part that collides.
- **Visual parts:** all massless, no collision, no touch. Seat `Disabled` = true. The old `DriveAlign` / `DriveTurn` /
  `DriveAttachment` were removed.
- **Wheels:** `Wheels.Wheel<key>.Collider` is an invisible Cylinder (1.1 × 3 × 3, axle along the car's right).
  - Density 2.5 (≈ 19), friction 1.0, elasticity 0 (ElasticityWeight 100).
  - The original Tire, Rim and the Sedan's `Hubs.<key>` parts are welded to the Collider, so they spin and steer
    with it.
- **Front knuckles:** `Steering.Knuckle_FL/FR`, 0.6-stud parts, mass ≈ 19.
  - The first build used 5-mass knuckles. The steering then wobbled ±10° and the car yawed 6.6° on a straight
    line. At 19 it stays within ±0.5°.
- **Suspension:** `Constraints.Suspension_<key>` is a CylindricalConstraint.
  - Attachment0 `SuspTop_<key>` on the knuckle (front) or Root (rear): X axis up, Y axis = car right,
    InclinationAngle 90. It slides vertically and spins about the axle.
  - Attachment1 is `Axle` on the Collider.
  - Travel −0.9 / +0.7 studs.
  - The angular Motor actuator is the drive and brake.
- **Springs:** `Constraints.Spring_<key>`, a SpringConstraint from `SpringTop_<key>` (2 studs above the hub) to `Axle`.
- **Steering:** `Constraints.Steer_FL/FR`, a HingeConstraint Servo, Root ↔ knuckle, vertical axis, limits ±40°.
- **No-collide:** `NoCollisionConstraint`s between MainCollision and each wheel and knuckle.
- **`Root.BodyLift`:** a VectorForce, world-relative, applied at the centre of mass (see the gravity note below).

### Gravity note (important)

Roblox gravity is 196.2 studs/s². That's about 5.6× real gravity for a car whose wheels are 3 studs across. With full
gravity:

- The suspension is stiff (~3 Hz).
- Braking dive and cornering roll are almost zero, because they scale with acceleration ÷ gravity.
- A 6° ramp needs huge torque. The first version stalled on it.

`BodyGravityScale` (0.35) sets `BodyLift` to cancel 65% of the chassis weight. Wheels and knuckles keep full gravity.
The car then behaves as if gravity were ~69 studs/s²:

- The suspension is ~1.8 Hz.
- Braking dives ~1°, and it squats under acceleration.
- It climbs the test ramp.
- Peak grip is still ~3× the hardest braking.

It is one config value; set it to 1 to switch it off. This is a deliberate trade-off, not ballast.

## Car controller (`PhysicsVehicle`)

- `PhysicsVehicle.new(car)` reads the profile from the car's `PhysicsProfile` attribute (`Sedan`).
  - It sets each spring so the car sits level at the built ride height: stiffness = corner load ÷ `SpringSag`,
    damping = `DampingRatio` × critical, and each front corner carries its own knuckle.
  - Free length = 2 + sag.
- **Inputs:** `SetInput(throttle, brake, steer)`, `SetReverse(on)`, `SetParked(on)`.
  - **Throttle:** the driven wheels' motors aim at top speed with torque = throttle × `DriveTorque` split between
    them. Every driven wheel gets the same torque, so it acts like an open differential.
  - **Brake:** all wheels aim at 0 with `BrakeTorque`, 60 % on the front.
  - **Coasting:** engine braking on the driven wheels, light rolling drag on the rest.
  - **Parked:** `ParkTorque` on all four.
- **Drivetrain:** `Drivetrain` is RWD, FWD or AWD (prototype = AWD).
- **Steering:** narrows from 34° to 12° by 36 studs/s, with Ackermann 0.15 (the inside wheel turns more).
- **Readings:** `Speed()`, `WheelSpeed(key)`, `Compression(key)`, `SteerAngle(key)`, `SteerLimit()`.
  - It publishes `PhysicsSpeed`, `PhysicsThrottle`, `PhysicsBrake` and `PhysicsState` attributes every 0.1 s, for
    audio later.
- **Loop:** one shared Heartbeat runs only while some car is driving. A parked car drops off it.
- **Ownership:** `ClaimServer()` calls `Root:SetNetworkOwner(nil)`, which covers the whole constraint-linked
  mechanism.

## AI driver (`PhysicsDriver`)

- **Calls:** `PhysicsDriver.new(vehicle)`, then `:Follow(waypoints, options)` or `:FollowAsync(...)`, and `:Stop()`.
  - Waypoints can be Vector3, CFrame, Parts (optional `Speed` attribute), or `{Position, Speed}`.
  - Options: `speed` (cruise), `reverse`, `stop` (default true), `onDone(result)`.
- **Path:** the corners are rounded (radius 8), then the path is resampled every stud with curvature per sample.
- **Steering (pure pursuit):** from the rear axle toward a point 4–14 studs ahead (grows with speed).
  - Steer angle = atan(wheelbase × 2x / d²), smoothed.
  - Reversing flips the sign.
- **Speed is the lowest of:**
  - The waypoint's speed.
  - √(lateral-accel ÷ curvature) over the stopping distance ahead.
  - The speed at which the needed steering angle still fits under the narrowing lock.
  - A stopping profile to the last point.
  - An obstacle limit.
- **Throttle and brake:** a PI controller to that speed.
- **Obstacles:** a box-cast every 0.2 s, from just inside the nose, forward.
  - The box covers 0.9–2.9 studs above the road and spans the car width.
  - Ramp faces (normal.Y > 0.6) and parts too low to see (curbs, bumps) are ignored.
  - Status goes `Driving` → `Yielding` → `Blocked` after 4 s.
- **Stuck recovery:** full throttle but no movement and nothing seen for 2.5 s → back off 4 studs and retry, at most
  twice, then `Blocked`.
- **Arrival:** within 0.35 studs and slower than 0.25 studs/s → parked, `Arrived`.
- **Status:** the car's `DriverStatus` attribute.

## Test results (solo Studio Play, server measurements)

- **TEST 01, static:** settles level (pitch 0.12°, roll 0.16°), every spring within 0.01 studs of rest, holds still.
- **TEST 02 / 07, uneven ground at ~14 studs/s:**
  - Bump: ±2.3° pitch.
  - One-sided 0.5 curb: 3.3° roll, right-side springs +0.33.
  - 2-stud ramp: ±6.6° pitch.
  - Wheels in the air: 0.13 s total across all four wheels.
  - Straight within 0.23°, upright throughout.
  - Parked half on the curb: 2.8° lean, each spring compressed on its own (screenshot taken).
- **TEST 03, steering:**
  - Right input turns right, inside wheel 38° vs outside 28°.
  - Turn radius 23 studs (wheelbase 12.1).
  - Both wheels return to centre (≤ 0.2°).
- **TEST 04 / 05, wheels and acceleration:**
  - Wheels roll at road speed.
  - 0 → 23 studs/s in 2.5 s at 60 % throttle.
  - The nose lifts ~0.9° under acceleration.
- **TEST 06, braking:** 70 % brake from 23 studs/s stops in 14 studs, nose dips ~1°, no snapping.
- **Full test route** (bump, curb, ramp, S-bend, 26-stud U-turn, parallel park beside a curb), 16 studs/s cruise:
  - Arrived in 53 s.
  - 0.35 studs off the line on average, 0.92 at most.
  - It slowed itself to 5.9 studs/s for the U-turn.
  - It stopped **0.05 studs** from the parking target, 0.01 sideways, heading 0.08° off.
  - The first attempt used a 10-stud U-turn, tighter than the car can turn, and it ran off the slab. That was a track
    mistake; the track was fixed.
- **Obstacles:**
  - A wall in the lane at 18 studs/s: stopped 1.9 studs short, `Blocked` after 4 s, drove on once the wall was removed.
  - A 1.2-stud bar: seen, stopped 1.8 short.
  - A 0.8-stud bar: driven over like a curb.
- **Knocked sideways** (8 studs/s shove + spin): 0.36 studs off line, back within 0.6 s, roll ≤ 2.2°.
- **Stuck recovery:**
  - Seen once: an earlier run, before the sensor box was lowered, against a 1.2-stud bar it couldn't see.
  - The two-try cap was added after that and **not tested** (a hidden wall I made was still seen by the sensor).
- **Four cars at once:** all arrived; the driver code cost ≈ 0.013 ms per car per frame; physics held 60 Hz in Studio.
- **Owner:** the server (`GetNetworkOwner()` = nil).
- **Not tested:** multiplayer (2 and 4 clients), real phones, how it looks from a player's screen at speed, audio
  hooked to the physics readings, any live customer flow.

## Next steps (phases 4–8, not started)

1. **Arrival:**
   - Give the live spawn → `ArrivalPath` → `CustomerVehicleStop` route to `PhysicsDriver`, with Road / PullOver speeds.
   - On `Arrived`, park, then run the existing `CustomerExiting` flow.
   - Customer cars must stop using collision group `DrivingCar`, or they'll fall through the road.
2. **Bays:**
   - Drive to the bay spot (the bays face −X; a turn-in path like `ShiftService.moveToBay`'s lineup / approach points,
     plus the existing reverse-out).
   - On arrival, **freeze**: anchor Root and the wheel colliders, so the jack / flat / remove / fit code keeps working
     on an anchored body.
   - Unfreeze to leave.
3. **Departure:** `DeparturePath` with the Departure speed, then remove only past the last point.
   Quarantine keeps its fade.
4. **Audio:** feed `PhysicsSpeed` / `PhysicsThrottle` to `VehicleAudioController`; it currently estimates speed from
   position changes.
5. **Other templates:** convert Estate, Roadster and Saloon only after the user approves the Sedan. Their doors are
   Motor6D on the body, which is fine on an unanchored body.
6. **Multiplayer:** test 2 and 4 clients for jitter from server ownership. Check ownership is set again after any
   anchor/unanchor (unanchoring resets it).
