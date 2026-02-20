# Animation System - Minimal Implementation

## Overview

Minimal event-driven animation system with walk and attack animations.
Includes post-cast delay to prevent jerky movement after actions.

## Architecture

```
Entity
  ├─ AnimationPlayer (holds animations)
  ├─ AnimationController (script, listens to events)
  ├─ CasterComponent (manages cast + post-cast phases)
  ├─ MovementComponent (provides velocity)
  └─ Actions (emit action_started/action_finished)
```

## Cast & Post-Cast System

Actions now have two phases:

### Cast Phase
- Entity performs windup animation
- Movement can be locked (`can_move_while_casting`)
- Action resolves at end of cast

### Post-Cast Phase (NEW)
- Entity "sticks around" after action
- Allows animations to complete naturally
- Movement can be locked (`can_move_during_post_cast`)

**Timeline Example:**
```
Ant Ranged Attack:
  cast_time = 0.3s
  post_cast_delay = 0.2s
  can_move_during_post_cast = false

0.0s: Start cast → lock movement → play "attack"
0.3s: RESOLVE (spawn projectile) → enter post-cast
0.5s: Post-cast complete → unlock → return to walk/idle
```

## Setup Instructions

### 1. Add AnimationPlayer to Entity

In your entity scene (e.g., `ant.tscn`):
1. Add `AnimationPlayer` node as child of entity
2. Name it `AnimationPlayer`

### 2. Create Animations

Create these animations in AnimationPlayer:

#### `idle` animation (looping)
- Small bob effect on position.y
- Duration: ~1-2 seconds
- Loop: ON

#### `walk` animation (looping)
- Faster bob effect on position.y
- Optional: slight rotation wobble
- Duration: ~0.5-1 seconds
- Loop: ON

#### `attack` animation (one-shot)
- Quick lunge forward (position)
- Scale spike or rotation
- Duration: ~0.3-0.5 seconds
- Loop: OFF

#### `hit` animation (one-shot) **NEW**
- Flash red (modulate)
- Small recoil (position/scale)
- Duration: ~0.1-0.3 seconds
- Loop: OFF

### 3. Add AnimationController

1. Add script `AnimationController` as child of entity
2. Set `animation_player` export to point to AnimationPlayer node

### 4. Test

Run the game:
- Entity should play `idle` when standing still
- Entity should play `walk` when moving
- Entity should play `attack` when action executes

## How It Works

### Movement Animations
`AnimationController._process()` checks `entity.velocity`:
- If velocity > 0.1: play "walk"
- Otherwise: play "idle"

### Attack Animations
Actions emit signals:
- `action_started` → play "attack" and lock animation
- Animation stays locked during cast + post-cast phases

CasterComponent's `is_casting()` returns true during both cast and post-cast,
so AnimationController keeps playing attack animation throughout.

### Hit Animations **NEW**
HealthComponent emits `was_hit` signal:
- AnimationController checks if entity has "super-armor"
- **Super-armor:** Entity is casting with `cancel_on_damage_taken = false`
- If super-armor: ignore hit, keep playing attack
- Otherwise: interrupt current animation, play hit

**Logic:**
```gdscript
if casting AND cancel_on_damage_taken = false:
    // Ignore hit, keep attacking (super-armor!)
else:
    // Play hit animation, interrupt attack
```

**Result:** Tough enemies can attack through damage, weak enemies flinch!

### Post-Cast Delay
After action resolves, entity enters post-cast phase:
- `CasterComponent._is_in_post_cast = true`
- `is_casting()` still returns true
- Movement locked if `can_move_during_post_cast = false`
- Animation continues playing naturally

**Result:** Smooth animations without jerky interruptions!

## Action Configuration

### BaseAction Properties

```gdscript
## Time before action is performed
@export var cast_time: float = 0.0

## Time after action completes before entity can act again
@export var post_cast_delay: float = 0.0

## Can entity move during cast windup?
@export var can_move_while_casting: bool = true

## Can entity move during post-cast recovery?
@export var can_move_during_post_cast: bool = false
```

### Example Configs

**Ranged Attack (ant acid spit):**
```gdscript
cast_time = 0.3
post_cast_delay = 0.2
can_move_while_casting = false
can_move_during_post_cast = false
```
Entity stands still for 0.5s total, animation plays naturally.

**Instant Melee:**
```gdscript
cast_time = 0.0
post_cast_delay = 0.3
can_move_during_post_cast = false
```
Instant hit, but stick around for sword swing recovery.

**Mobile Spell:**
```gdscript
cast_time = 1.0
post_cast_delay = 0.0
can_move_while_casting = true
can_move_during_post_cast = true
```
Can move throughout, no post-cast delay.

**Super-Armor Boss (can't be interrupted):**
```gdscript
cast_time = 2.0
post_cast_delay = 0.5
cancel_on_damage_taken = false  # Super-armor!
```
Boss keeps attacking even when hit, no hit animation plays.

## Signals Added

### BaseAction
```gdscript
signal action_started  # Emitted when action executes
signal action_finished # Emitted when action completes
```

Emitted in two places:
1. `perform_action()` for instant actions (cast_time = 0)
2. `CasterComponent._process()` for cast-time actions

## Example: Simple Walk Animation

Without sprite sheets, animate transforms:

```
idle animation:
  Track: position.y
    0.0s: 0.0
    0.5s: 0.05  (slight bob up)
    1.0s: 0.0   (back down)

walk animation:
  Track: position.y
    0.0s: 0.0
    0.25s: 0.1  (faster bob)
    0.5s: 0.0

attack animation:
  Track: position.x
    0.0s: 0.0
    0.1s: 0.3   (lunge forward)
    0.3s: 0.0   (return)
  Track: scale
    0.0s: Vector3(1, 1, 1)
    0.1s: Vector3(1.2, 1.2, 1.2)
    0.3s: Vector3(1, 1, 1)

hit animation:
  Track: modulate
    0.0s: Color(1, 1, 1, 1)  (white)
    0.05s: Color(1, 0, 0, 1)  (red flash)
    0.2s: Color(1, 1, 1, 1)  (back to white)
  Track: scale
    0.0s: Vector3(1, 1, 1)
    0.05s: Vector3(0.9, 0.9, 0.9)  (shrink)
    0.2s: Vector3(1, 1, 1)  (back to normal)
```

## Hit Animation System

### Super-Armor Mechanic

Entities can have "super-armor" during certain actions:
- Set `cancel_on_damage_taken = false` on action
- Entity takes damage but continues attacking
- Hit animation does NOT play

**Use cases:**
- Boss attacks (can't be interrupted)
- Heavy weapon swings (committed to attack)
- Berserker rage abilities

### Hit Reaction Behavior

| Scenario | Hit Animation? | Action Interrupted? |
|----------|----------------|---------------------|
| Idle, walking | ✅ Yes | N/A |
| Attacking, cancel_on_damage_taken = true | ✅ Yes | ✅ Yes (cast cancelled) |
| Attacking, cancel_on_damage_taken = false | ❌ No | ❌ No (super-armor!) |

### Implementation Details

AnimationController listens to `HealthComponent.was_hit`:
1. Check if damage is heal (ignore)
2. Check if entity is casting
3. If casting, check `action.cancel_on_damage_taken`
4. If false: ignore hit (super-armor)
5. Otherwise: interrupt animation, play hit

CasterComponent handles cast cancellation separately based on `cancel_on_damage_taken`.

## Extension Points

Animation states currently implemented:
- ✅ IDLE - standing still
- ✅ WALK - moving
- ✅ ATTACK - action executing
- ✅ HIT - taking damage

To add more animation states:
1. Add new state to `AnimationState` enum
2. Add case in `_play_state()` match
3. Add condition in `_update_animation_state()`
4. Connect to relevant signals

Example future additions:
- Death (check health.current_health <= 0)
- Stun (connect to status effect system)
- Victory pose (on enemy defeated)
