# Effect System

## Overview
Effects (buffs/debuffs) are Resources that can be applied to entities. Timers live on the target entity, not on the effect itself. Effects auto-cleanup after expiration.

## Architecture

### Base Effect Class
All effects extend `Effect` (Resource):
```gdscript
class_name Effect extends Resource

var target: Entity          # Required
var source: Entity = null   # Optional (for attribution)
@export var duration := 5.0
@export var refresh_on_reapply := true
@export var stackable := false
var stack_count := 1
```

**Effect Type Detection:**
- Effect type is auto-detected using `get_script()`
- No manual `effect_type` string needed
- `is_same_type(other)` checks if two effects are the same class

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

## Built-in Effects

### PoisonEffect
- Stackable damage over time
- 1 damage per stack per second
- 5 second duration

### BurnEffect
- Stackable fire damage
- 1 damage per stack per second
- 2 second duration
- All stacks lost when duration ends (per requirements)

### DesyncedEffect
- Flips enemy↔ally targeting on all actions
- Only restores original if not overwritten by another effect
- 5 second duration (configurable)

## Usage Examples

### Apply Simple Effect
```gdscript
var poison = PoisonEffect.new()
poison.source = attacker
poison.stack_count = 3
target_entity.apply_effect(poison)

# If poison already exists and is stackable, stacks will merge
# If poison exists but not stackable, application is rejected
```

### Apply from EffectArea
```gdscript
var area = EffectArea.new()
area.effect = PoisonEffect.new()
area.source_entity = player
area.target_filters = ["enemy"]
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

## Effect Lifecycle

1. **Creation**: `var effect = SomeEffect.new()`
2. **Configuration**: Set `source`, `duration`, `stack_size`, etc
3. **Application**: `entity.apply_effect(effect)`
   - Sets `effect.target = entity`
   - Checks for existing effects (merge/refresh/replace)
   - Calls `effect.on_applied()`
   - Effect creates Timer(s) on entity
4. **Running**: Timers tick automatically
5. **Expiration**: Timer fires `timeout`
   - Calls `effect.on_expired()`
   - Cleans up timers
   - Entity removes effect from array

## Pause Support

Effects respect `get_tree().paused` because Timers are used.
- Pause game → effect timers pause
- Resume game → effect timers resume

## Best Practices

1. **No Manual Type**: Effect type auto-detected via `get_script()` - don't set manually
2. **Timers on Target**: Never `add_child()` timers to effect (effects are Resources)
3. **super() Calls**: MUST call `super()` when overriding `on_applied()` or `on_expired()`
4. **Stacking**: Set `stackable = true` in `_init()` to allow multiple applications
5. **stack_count**: Use `stack_count` (not `stack_size`) for damage/heal scaling

## Migration from Old System

**Old (manual tick):**
```gdscript
# Entity._process(delta)
for effect in effects:
    if effect.is_expired():
        effects.erase(effect)
    effect.tick(delta, self)
```

**New (timer-based):**
```gdscript
# Timers handle everything automatically
# Entity.apply_effect() sets up timers
# No manual _process loop needed
```

**Old effect code:**
```gdscript
func do_effect_trigger(entity: Entity):
    entity.health.do_damage(...)
```

**New effect code:**
```gdscript
func on_tick():
    target.health.do_damage(...)
    # No super() needed for on_tick (it's the leaf callback)
```

**Override pattern:**
```gdscript
func on_applied():
    super()  # MUST call to preserve timer setup
    # your logic here

func on_expired():
    # your cleanup here
    super()  # MUST call to clean up timers
```

## Future Extensions

- **BuffEffect**: Similar to TickEffect but modifies stats instead of dealing damage
- **AuraEffect**: Applies other effects to nearby entities
- **ConditionalEffect**: Only triggers when certain conditions are met
- **ChainEffect**: Applies another effect on expiry

All follow the same pattern: extend `Effect`, manage timers on target entity.
