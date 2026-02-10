# Changelog - v0.0.6

## 🚀 Major Features

### Movement System Refactoring
Complete overhaul of the action and movement system for better separation of concerns and more flexible entity behavior.

#### **1. Unified BaseAction Class**
- Merged `BaseTimedCast` and `BaseActionTargeting` into single `BaseAction` class
- Simpler inheritance hierarchy (one base class instead of two)
- Old classes marked DEPRECATED but kept for backward compatibility
- All action classes now extend `BaseAction` directly

#### **2. Range Configuration in TargetingStrategy**
- Moved ALL range logic from actions to `TargetingStrategy`
- Added `@export min_range: float` and `@export max_range: float` to strategies
- Base class handles range filtering, subclasses implement selection logic
- **Updated targeting strategies:**
  - `TargetClosest`
  - `TargetLowestHP`
  - `TargetHighestHP`
  - `TargetLowestHPPercent`
  - `TargetHalucinating`

**Migration:**
```gdscript
# Old:
action.action_range = 12.0
action.min_distance = 5.0

# New:
targeting_strategy.max_range = 12.0
targeting_strategy.min_range = 5.0
```

#### **3. Execution Range System**
Separate targeting range from execution range for better movement control.

**New exports in BaseAction:**
- `min_execution_range: float = 0.0` - Don't execute if target too close
- `max_execution_range: float = 0.0` - Don't execute if target too far

**Key insight:** Actions need targets for movement even when out of execution range!

**Example use case (Ant acid spit):**
```gdscript
targeting_strategy.min_range = 0.0       # Find target at any distance
targeting_strategy.max_range = 12.0      # Max targeting range
min_execution_range = 5.0                # Don't shoot closer than 5m
max_execution_range = 10.0               # Don't shoot farther than 10m
movement_strategy = RangedMovementStrategy  # Back away behavior
```

**Result:**
- Enemy at 3m: Target found → back away → don't shoot (too close)
- Enemy at 7m: Target found → hold position → shoot (in sweet spot!)
- Enemy at 12m: Target found → move closer → don't shoot (too far)
- Enemy at 20m: No target (outside targeting range)

#### **4. Movement During Casting**
- `MovementComponent` now respects `can_move_while_casting` flag
- Checks `CasterComponent.movement_locked()` before moving
- Entities properly stop moving during casts when configured
- Updated `CasterComponent` to use `BaseAction` type

## 🐛 Bug Fixes

### Action Execution Logic
- **Fixed:** `perform_action()` now always called when cooldown ready
- **Fixed:** Simplified timer reset logic for clarity
- Behavior now explicit:
  - `pause_until_action_success = false`: Reset timer always (keep trying)
  - `pause_until_action_success = true`: Reset timer only on success (wait for success)

## 🔧 Refactoring

### Movement Control
- Moved movement logic from actions to Entity
- Actions provide target + strategy, Entity applies movement
- Removed `update_movement()` from actions
- Removed `_get_current_target()` stub from Entity
- Actions now implement `get_current_target()` from targeting system

### Movement Action Selection
- Filter actions without `movement_strategy` at selection time
- Warning only printed once (not per action)
- Cleaner flow, guaranteed strategy exists when action selected

## 📚 Documentation & Assets

### Entity System
- Added comprehensive entity system documentation
- Added ant animations & sprites
- Added multi-target support infrastructure
- Improved effect display with progress bars

### Effects System
- Added `max_stack_count` to stackable effects
- Fixed effect merging logic (take higher max_stack_count)
- Refactored HUD to unified `EntityViewportUI` system
- Effect bars now use Label + ProgressBar
- Added text-based effect HUD

### Code Quality
- Multiple cleanup passes
- Better assertions for required configuration
- Typed dictionaries for effect bars
- Future consideration notes for dynamic stack counts

## 🎯 Breaking Changes

### Range Configuration
Range properties moved from actions to targeting strategies:
- **Removed from BaseAction:** `action_range`, `min_distance`
- **Added to TargetingStrategy:** `min_range`, `max_range`

### Class Hierarchy
- `BaseTimedCast` → DEPRECATED (use `BaseAction`)
- `BaseActionTargeting` → DEPRECATED (use `BaseAction`)
- Old classes still work but marked for removal

### Targeting Strategy API
Targeting strategies now override `_select_from_candidates()` instead of `select_targets()`:
```gdscript
# Old:
func select_targets(detector, filters, max_range, line_of_sight):
    ...

# New:
func _select_from_candidates(detector, candidates):
    # Base class handles filtering
    # Just implement selection logic
    ...
```

## 🎮 Gameplay Impact

### Better Enemy AI
- Ranged enemies can now back away from targets
- Execution ranges allow "sweet spot" positioning
- Movement continues even when action can't execute
- More natural enemy behavior

### More Flexible Actions
- Actions can have different targeting vs execution ranges
- Cast-time actions properly lock movement
- Priority-based movement control
- Actions can require specific positioning

## ⚙️ Technical Details

### Performance
- Actions cached in `_ready()` instead of searching every frame
- Movement logic optimized

### Architecture
Clean separation of concerns:
- **TargetingStrategy:** Finds targets, filters by range
- **BaseAction:** Executes action, checks execution range
- **MovementStrategy:** Decides desired position
- **MovementComponent:** Applies movement physics, respects locks
- **CasterComponent:** Manages cast timing, enforces movement lock

---

**Full commit range:** v0.0.5..HEAD (28 commits)

**Contributors:** Kevin (@NouCake), grug-developer 🪨
