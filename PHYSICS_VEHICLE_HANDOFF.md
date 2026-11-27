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
| Test helpers | `ServerStorage.PhysicsLab.PhysicsLabTests`: `Spawn`, `Reset`, `Route`, `RunRoute(speed)` (returns a one-line report), `Obstacle(size, z, speed)`. Require it from a Server `execute_luau` in Play; it puts the track in Workspace by itself. |

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
- **Wheels:** `Wheels.Wheel<key>.Collider` is an invisible **Ball** (radius 1.5), centred **0.5 studs inboard** of the
  visible tyre. Its `Axle` attachment stays at the real hub, so the wheel turns about the same axle.
  - Density 1.38 (≈ 19.5), friction 1.0, elasticity 0 (ElasticityWeight 100).
  - Why a ball (changed 2026-11-27): the first build used flat Cylinders. They tilt with the body, so any lean puts
    the car's weight on each wheel's edge and holds it upright like a box. Roll was 0.3° at a firm sideways load, and
    halving the springs made no difference. A ball keeps one contact point under the hub, so lean comes only from the
    springs.
  - The 0.5 inset keeps the ball's outer edge at curb height level with the tyre's sidewall. Centred on the hub, the
    ball rubbed the parking curb.
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
  - **Lift-off zone:** below `EngineBrakeThrottle` (0.08) the pedal fades engine braking in, from none at 0.08 to
    full at 0. Above it, drive torque ramps up from zero. Without this zone the pedal jumped between drive and full
    engine braking.
  - `DriveAccel()`, `BrakeAccel()` and `CoastAccel()` turn torques into studs/s² using the car's full mass, for the
    driver.
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
- **Speed plan:** worked out once per route.
  - Each sample's limit is the lowest of: its waypoint's speed; √(lateral-accel ÷ curvature); the speed at which the
    needed steering angle still fits under the narrowing lock; and 0 at the end when stopping.
  - A backward pass then ramps every limit down ahead of time at `COMFORT_DECEL` (3.5 studs/s²), so the car eases
    into bends, speed changes and the final stop.
  - Obstacles add their own limit while driving.
- **Speed control:**
  - Wanted acceleration = feed-forward from the plan's slope + `SPEED_GAIN` × speed error + an integral for slopes.
  - That becomes a single pedal value (throttle, lift-off zone, or brake) using the car's real torques.
  - The pedal changes at most `PEDAL_RISE` / `PEDAL_FALL` per second.
  - A stop or obstacle that needs more than `STOP_TRIGGER_DECEL` brakes at the needed rate.
- **Target behind the car:** turns at full lock (a U-turn) instead of driving away.
- **Off route:** more than `OFF_ROUTE_DISTANCE` (50) from the path → it brakes, stops and returns `OffRoute`.
- **Obstacles:** a box-cast every 0.2 s, from just inside the nose, forward.
  - The box covers 0.9–2.9 studs above the road and spans the car width.
  - Ramp faces (normal.Y > 0.6) and parts too low to see (curbs, bumps) are ignored.
  - Status goes `Driving` → `Yielding` → `Blocked` after 4 s.
- **Stuck recovery:**
  - Wants to move, isn't moving, and nothing seen: the pedal is pressed up to full over `STUCK_TIME` (2.5 s), then
    held for `STUCK_HOLD` (1.5 s).
  - Then it backs off 4 studs and retries, at most twice, then stays `Blocked` with the brake on.
  - The retry count resets only once the car gets `RECOVER_CLEAR` (6) studs past where it stuck.
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
- **Stuck recovery:** tested in the tuning pass below (steep ramp).
- **Four cars at once:** all arrived; the driver code cost ≈ 0.013 ms per car per frame; physics held 60 Hz in Studio.
- **Owner:** the server (`GetNetworkOwner()` = nil).
- **Not tested:** multiplayer (2 and 4 clients), real phones, how it looks from a player's screen at speed, audio
  hooked to the physics readings, any live customer flow.

## Tuning pass (2026-11-27, later)

The same full route (`PhysicsLabTests.RunRoute(16)`), before → after:

| Measure | Before | After |
|---|---|---|
| Throttle on/off switches per lap | 256 | 10–12 |
| Peak acceleration (0.2 s window) | 26.6 | 8.1 |
| Peak braking from the controller | 55.7 (spiky) | ~5 (final stop 5.1; was 8.0 even after the first rewrite) |
| Straight-line yaw rate | 4.9°/s | 1.1°/s |
| Lean at a steady 20 studs/s² sideways push | 0.3° | 2.25° (0.62° at 5, 1.19° at 10; even and spring-driven) |
| Stop error / heading | 0.17 / 0.08° | 0.16 / 0.00° |
| Line error mean / max | 0.34 / 0.84 | 0.33 / 0.79 |

- The remaining 9–10 studs/s² deceleration spikes are the wheels physically hitting the bump and curb at ~14 studs/s
  with the throttle on, not braking.
- **Steep 3.5-stud ramp it can't climb:** pressed to full throttle, backed off twice, then `Blocked` with the brake on
  (24 s). Before this pass it sat at half throttle saying "Driving".
- **Target behind the car:** U-turn about 46 studs wide, came back to the line and stopped 0.15 short with heading
  0.00°.
- **Obstacles:**
  - Wall at 17.6 studs/s: stopped 2.27 short, `Blocked`, went on once it was cleared.
  - 1.2-stud bar: stopped 2.5 short.
- **Four cars:** 0.015 ms per car per frame, physics 60 Hz in Studio, all arrived upright.
- No console errors from these modules.

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
