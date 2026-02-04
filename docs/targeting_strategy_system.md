# Targeting Strategy System

## Overview
Configurable targeting system for actions/spells. Each action can use different targeting strategies, and targeting can be modified at runtime (e.g., by debuffs like "Desynced").

## Architecture

### Base Class: `TargetingStrategy`
All targeting strategies extend this base class and implement:
```gdscript
func select_targets(
    detector: TargetDetectorComponent,
    filters: Array[String],
    max_range: float,
    line_of_sight: bool
) -> Array[Node3D]
```

Returns array of targets (for future multi-target support).

### Built-in Strategies

1. **TargetClosest** - Selects closest valid target
2. **TargetRandom** - Randomly picks from valid targets
3. **TargetLowestHP** - Target with lowest current HP
4. **TargetHighestHP** - Target with highest current HP
5. **TargetLowestHPPercent** - Target with lowest HP%

## Usage in Actions

### ActionProjectile (default: TargetClosest)
```gdscript
func _enter_tree() -> void:
    if not targeting_strategy:
        targeting_strategy = TargetClosest.new()
```

### ActionHeal (default: TargetLowestHPPercent)
```gdscript
func _enter_tree() -> void:
    if not targeting_strategy:
        targeting_strategy = TargetLowestHPPercent.new()
```

Strategies can be overridden in Godot editor by assigning a different strategy resource.

## Runtime Modification (Debuffs)

`BaseActionTargeting` has `targeting_override: TargetingStrategy` which takes precedence over the configured strategy.

### Example: Desynced Debuff
```gdscript
# Flip targeting for all actions on an entity
var debuff := DebuffDesynced.new()
debuff.target_entity = entity
debuff.duration = 5.0
entity.add_child(debuff)
```

The debuff:
- Stores original strategies
- Swaps target filters (enemy↔ally)
- Auto-removes after duration
- Restores original targeting

See `assets/scripts/debuff/debuff_desynced.gd` for implementation.

## Future Extensions

### Multi-target support
Strategies already return `Array[Node3D]`. Future actions can consume entire array:
```gdscript
var targets := active_strategy.select_targets(...)
for t in targets:
    # Apply effect to each target
```

### New strategies
Easy to add:
1. Extend `TargetingStrategy`
2. Implement `select_targets()`
3. Use in action via `targeting_strategy` export

### Area/Ground targeting
Current system works for entity targeting. Ground targeting would need:
- New `TargetSnapshot` variant with position but no entity
- Strategy variants that return positions instead of nodes

## Testing

See `test/test_desynced_debuff.gd` for example usage of debuff system.

Humans configure strategies in Godot editor via @export on actions.
