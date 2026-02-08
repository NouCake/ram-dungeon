# Movement System

## Overview
First-class movement system for entities that integrates with Effects, CC, zones, and actions. Split into two parts: MovementComponent (physics/modifiers) and MovementStrategy (pathfinding/positioning).

## Architecture

### MovementComponent (Required on Entity)
**Path:** `assets/scripts/component/movement.gd`
**Node name:** `movement` (exact match required)

**Responsibilities:**
- Base locomotion (move speed)
- Speed modifiers from effects/zones
- Movement locks (Root/Stun/Petrify/Stasis)
- External forces (knockback/pull)
- Event emission (moved, dashed, etc)
- Physics integration (CharacterBody3D)

**Properties:**
```gdscript
@export var base_move_speed := 5.0
@export var knockback_resistance := 0.0  # 0.0-1.0
var desired_position: Vector3  # Set by AI/Actions
var is_movement_locked := false  # CC locks
var speed_multiplier := 1.0  # Calculated from effects
```

**Signals:**
- `movement_started` - entity begins moving
- `movement_stopped` - entity stops moving
- `moved(distance: float)` - emitted each frame with distance traveled
- `dashed` - dash occurred (future)

**Methods:**
- `apply_force(force: Vector3)` - add knockback/pull
- `lock_movement()` - disable movement (CC)
- `unlock_movement()` - enable movement
- `static Get(node: Node) -> MovementComponent`

### MovementStrategy (Per Action/AI)
**Path:** `assets/scripts/movement/movement_strategy.gd`

**Responsibilities:**
- Decide WHERE to move (pathfinding)
- Range management
- Positioning logic
- Priority system

**Base class:**
```gdscript
class_name MovementStrategy extends Resource

@export var priority := 0

func get_target_position(entity: Entity, target: Entity) -> Vector3:
    # Override in subclasses
    return Vector3.ZERO

func should_move(entity: Entity, target: Entity) -> bool:
    return true
```

**Built-in strategies:**
1. **MeleeMovementStrategy** - walk straight into attack range
2. **RangedMovementStrategy** - maintain optimal range (back off if too close)

## Setup

### 1. Add MovementComponent to Entity

In entity scene:
```
Entity (CharacterBody3D)
├─ health (HealthComponent)
├─ targetable (Targetable)
└─ movement (MovementComponent) ← ADD THIS
```

**Required:** Component MUST be named "movement"

### 2. Use MovementStrategy in Actions/AI

```gdscript
# In Action or AI script
var movement_strategy := MeleeMovementStrategy.new()
movement_strategy.attack_range = 2.0

func _process(delta):
    var movement := MovementComponent.Get(entity)
    if movement and movement_strategy.should_move(entity, target):
        # Strategy decides WHERE
        movement.desired_position = movement_strategy.get_target_position(entity, target)
        # MovementComponent handles HOW (in _physics_process)
```

## Effect Integration

### Speed Modifiers

Effects implement `get_move_speed_mult()`:
```gdscript
class_name HinderedEffect extends Effect:
    @export var speed_multiplier := 0.75  # -25% speed
    
    func get_move_speed_mult() -> float:
        return speed_multiplier
```

MovementComponent automatically queries all effects and multiplies:
```gdscript
# In MovementComponent._calculate_speed_multiplier()
for effect in entity.effects:
    if effect.has_method("get_move_speed_mult"):
        speed_multiplier *= effect.get_move_speed_mult()
```

### Movement Locks (CC)

Effects call `lock_movement()` / `unlock_movement()`:
```gdscript
class_name RootedEffect extends Effect:
    func on_applied():
        super()
        MovementComponent.Get(target).lock_movement()
    
    func on_expired():
        MovementComponent.Get(target).unlock_movement()
        super()
```

When locked, MovementComponent skips all movement logic.

## Built-in Movement Strategies

### MeleeMovementStrategy
**Path:** `assets/scripts/movement/melee_movement_strategy.gd`

**Behavior:** Walk straight toward target until in attack range, then stop.

**Exports:**
- `attack_range := 2.0` - melee range

**Usage:**
```gdscript
var strategy = MeleeMovementStrategy.new()
strategy.attack_range = 2.5
```

### RangedMovementStrategy
**Path:** `assets/scripts/movement/ranged_movement_strategy.gd`

**Behavior:**
- If too close (< min_range): back away to preferred_range
- If too far (> max_range): move closer to preferred_range
- If in good range: stay put

**Exports:**
- `min_range := 3.0` - minimum safe distance
- `max_range := 10.0` - maximum effective range
- `preferred_range := 6.0` - ideal distance

**Usage:**
```gdscript
var strategy = RangedMovementStrategy.new()
strategy.min_range = 4.0
strategy.max_range = 12.0
strategy.preferred_range = 8.0
```

## Built-in CC Effects

### HinderedEffect
**Path:** `assets/scripts/effects/hindered.gd`

Reduces movement speed.

**Exports:**
- `speed_multiplier := 0.75` (0.75 = -25% speed)

**Usage:**
```gdscript
var hindered = HinderedEffect.new()
hindered.speed_multiplier = 0.5  # -50% speed
hindered.duration = 3.0
entity.apply_effect(hindered)
```

### RootedEffect
**Path:** `assets/scripts/effects/rooted.gd`

Cannot move (but can still act).

**Usage:**
```gdscript
var rooted = RootedEffect.new()
rooted.duration = 2.0
entity.apply_effect(rooted)
```

### StunnedEffect
**Path:** `assets/scripts/effects/stunned.gd`

Cannot move OR act (action integration TODO).

**Usage:**
```gdscript
var stunned = StunnedEffect.new()
stunned.duration = 1.0
entity.apply_effect(stunned)
```

## External Forces (Knockback/Pull)

Apply forces via `apply_force()`:
```gdscript
# Knockback away from source
var knockback_dir = (target.global_position - source.global_position).normalized()
var knockback_force = knockback_dir * 500.0
MovementComponent.Get(target).apply_force(knockback_force)

# Pull toward source
var pull_force = -knockback_dir * 300.0
MovementComponent.Get(target).apply_force(pull_force)
```

**Knockback resistance:**
```gdscript
# In entity scene or code
movement.knockback_resistance = 0.5  # 50% resistance
```

Forces are applied as one-frame impulses and cleared after physics step.

## Movement Events

Listen to signals for gameplay triggers:
```gdscript
# Example: Bleeding + Movement Tear (take damage when moving)
func _ready():
    var movement = MovementComponent.Get(entity)
    movement.moved.connect(_on_entity_moved)

func _on_entity_moved(distance: float):
    if has_bleeding_effect:
        # Trigger extra damage (Movement Tear mechanic)
        # with ICD, etc
        pass
```

## Creating Custom MovementStrategy

```gdscript
class_name CustomMovementStrategy extends MovementStrategy

@export var some_param := 1.0

func _init():
    priority = 15  # Higher than default

func get_target_position(entity: Entity, target: Entity) -> Vector3:
    # Custom logic here
    # e.g., circle strafe, flee, patrol, etc
    return calculated_position

func should_move(entity: Entity, target: Entity) -> bool:
    # Custom condition
    return some_condition
```

## Integration with Casting/Actions

When action has cast time and blocks movement:
```gdscript
# In action script
var can_move_while_casting := false

func start_cast():
    if not can_move_while_casting:
        # Temporarily lock movement
        MovementComponent.Get(caster).lock_movement()

func finish_cast():
    # Unlock
    MovementComponent.Get(caster).unlock_movement()
```

## Zone Integration (TODO)

Zones will emit `area_entered` / `area_exited`:
```gdscript
# In zone script (future)
func _on_body_entered(body):
    if body is Entity:
        var movement = MovementComponent.Get(body)
        # Apply zone modifier (store in movement component)

func _on_body_exited(body):
    # Remove zone modifier
```

MovementComponent will track active zones and their modifiers.

## Future Enhancements

- [ ] Dash mechanic (emit `dashed` signal)
- [ ] Zone speed modifiers (Overgrowth roots, etc)
- [ ] Stacking rules for speed modifiers (additive vs multiplicative, caps)
- [ ] Paranoid effect (random movement, AI override)
- [ ] Petrified effect (locked until damage threshold)
- [ ] Stasis effect (locked + damage queue)
- [ ] Pathfinding obstacles
- [ ] Multiple simultaneous strategies (priority system)
- [ ] Movement prediction (for network/AI)

## Troubleshooting

### Entity won't move
- Check MovementComponent exists and named "movement"
- Check `desired_position` is being set
- Check `is_movement_locked` is false
- Check entity is CharacterBody3D

### Speed modifiers not working
- Check effect implements `get_move_speed_mult()`
- Check effect is in `entity.effects` array
- Print `speed_multiplier` in MovementComponent._physics_process

### CC not locking movement
- Check effect calls `lock_movement()` in `on_applied()`
- Check effect calls `unlock_movement()` in `on_expired()`
- Ensure `super()` called in effect methods

### Knockback not working
- Check `knockback_resistance` isn't 1.0 (immune)
- Check entity is CharacterBody3D
- Check force magnitude is reasonable (try 500+)

## API Reference

### MovementComponent

**Properties:**
- `base_move_speed: float` - base speed in units/sec
- `knockback_resistance: float` - 0.0 (none) to 1.0 (immune)
- `desired_position: Vector3` - target position (set by AI/Actions)
- `is_movement_locked: bool` - readonly, true if CC locked
- `speed_multiplier: float` - readonly, calculated from effects

**Methods:**
- `apply_force(force: Vector3)` - add one-frame impulse
- `lock_movement()` - disable movement (CC)
- `unlock_movement()` - enable movement
- `Get(node: Node) -> MovementComponent` - static getter

**Signals:**
- `movement_started()`
- `movement_stopped()`
- `moved(distance: float)`
- `dashed()`

### MovementStrategy

**Properties:**
- `priority: int` - strategy priority (higher = more important)

**Methods:**
- `get_target_position(entity, target) -> Vector3` - WHERE to move
- `should_move(entity, target) -> bool` - whether to move now

## Design Philosophy

**Separation of concerns:**
- MovementComponent = HOW (physics, modifiers, locks)
- MovementStrategy = WHERE (pathfinding, positioning)

**Effect integration:**
- Effects modify movement via small interface (`get_move_speed_mult()`, `lock_movement()`)
- No hardcoded CC checks in MovementComponent

**Event-driven:**
- Signals allow other systems to react to movement (bleeding, etc)
- No tight coupling to specific mechanics

**Flexible:**
- Multiple strategies possible (priority system)
- Custom strategies easy to create
- Works with any CharacterBody3D entity
