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
- `action_finished` → unlock (will return to walk/idle)

CasterComponent's `is_casting()` returns true during both cast and post-cast,
so AnimationController keeps playing attack animation throughout.

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
```

## Extension Points

To add more animation states later:
1. Add new state to `AnimationState` enum
2. Add case in `_play_state()` match
3. Add condition in `_update_animation_state()`
4. Connect to relevant signals

Example future additions:
- Hit reaction (connect to HealthComponent.was_hit)
- Death (check health.current_health <= 0)
- Casting (check CasterComponent.is_casting())
