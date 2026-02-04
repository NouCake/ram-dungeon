# Changelog v0.0.5

## Major Features

### Targeting Strategy System
- **Pluggable targeting behavior** for all actions
- Actions can now use different targeting strategies (closest, random, lowest HP, etc)
- Strategy types:
  - `TargetClosest`: finds nearest enemy
  - `TargetRandom`: picks random target
  - `TargetLowestHP`: targets enemy with least health
  - `TargetLowestHPPercent`: targets enemy with lowest HP percentage
  - `TargetHighestHP`: targets enemy with most health
- Actions can have their targeting overridden at runtime (e.g., by debuffs)
- **Desynced debuff**: flips enemy↔ally targeting temporarily

### Timer System Refactor
- **Replaced all manual delta-based timers** with Godot Timer nodes
- Created `TimerUtil` helper class:
  - `delay(node, seconds, callback)`: one-shot timer
  - `repeat(node, seconds, callback)`: repeating timer
  - `await_delay(node, seconds)`: async timer
- **Benefits:**
  - All timers respect `get_tree().paused` (pause-ready)
  - No more manual delta accumulation
  - Timers visible in scene tree for debugging
  - Auto-cleanup when parent freed

### Pause System
- Added `PauseManager` singleton
- Press ESC to toggle pause
- Timer nodes automatically pause/resume
- Foundation for pause menu UI (stub ready)

## Improvements

### EffectArea
- Added `source_entity` field for damage/heal attribution
- Added `target_filters` for selective effect application
- Improved lifecycle management (separated from `_ready()`)

### Shroom Enemy
- Improved poison spawn behavior
- Poison spreads in area
- Better grow/lifetime timing

### Code Quality
- Moved `await` logic out of `_ready()` into lifecycle functions
- Cleaner separation of initialization vs timed behavior
- Better error handling (asserts for dev-time config errors)

## Technical Changes

### Effect System
- Effects now use Timer nodes via `TimerUtil`
- Generalized tick interval logic in `TickEffect` base class
- Poison and Burn use base class tick system
- Effects remain Resources (not Nodes)

### Spawner
- Uses Timer nodes for spawn intervals
- Auto-pauses when game paused

### VFX
- VFXOneshot uses Timer for lifetime
- EffectArea uses Tween for grow/fade animations

## Content

- Added cockroach sprite
- Added holy AoE effect
- Updated sunwell area scene

## Bug Fixes

- Fixed invalid `super._ready()` calls (gdscript doesn't have super in that form)
- Fixed timer cleanup on entity death
- Fixed effect expiry edge cases

---

**Full Diff:** v0.0.4...main
