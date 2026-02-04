# Effect System

## Overview
Effects (buffs/debuffs) are Resources that can be applied to entities. Timers live on the target entity. Effects auto-cleanup after expiration.

## Architecture

### Base Effect Class
All effects extend `Effect` (Resource):
```gdscript
class_name Effect extends Resource

var target: Entity          # Required
var source: Entity = null   # Optional
@export var duration := 5.0
@export var refresh_on_reapply := true
@export var stackable := false
var stack_count := 1
```

**Stacking:**
- Set `stackable = true` to allow multiple applications
- `merge(other)` combines stacks automatically
- Non-stackable effects are rejected on reapplication

### TickEffect
For effects that trigger repeatedly (damage/heal over time):
```gdscript
class_name TickEffect extends Effect

@export var tick_interval := 1.0
```

**Usage:**
- Override `on_tick()` for effect logic
- Stacking inherited from base Effect class
- Use `stack_count` for damage/heal calculations

## Usage Examples

### Apply Simple Effect
```gdscript
var poison = PoisonEffect.new()
poison.source = attacker
poison.stack_count = 3
target_entity.apply_effect(poison)
```

### Create Custom Effect
```gdscript
class_name MyCustomEffect extends Effect

func _init():
    duration = 10.0
    refresh_on_reapply = false
    stackable = false  # Optional: allow stacking

func on_applied():
    super()  # MUST call to create timers
    print("Effect applied to ", target.name)
    # Add custom logic here

func on_expired():
    print("Effect expired from ", target.name)
    # Cleanup custom logic
    super()  # MUST call to clean up timers
```

### Create Custom Tick Effect
```gdscript
class_name MyTickEffect extends TickEffect

func _init():
    tick_interval = 0.5
    stackable = true

func on_tick():
    # This runs every 0.5 seconds
    # Use stack_count for scaling
    target.health.heal(stack_count * 2)
```

## Pause Support

Effects respect `get_tree().paused` because Timers are used.
- Pause game → effect timers pause
- Resume game → effect timers resume
