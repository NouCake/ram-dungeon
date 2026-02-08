# Entity System

## Overview
Entity is the base class for all characters and creatures in the game world. Extends CharacterBody3D and uses a component-based architecture.

## Base Entity Class
```gdscript
class_name Entity extends CharacterBody3D
```

**Path:** `assets/scripts/entity.gd`

**Core features:**
- Health management via HealthComponent
- Targeting system via Targetable component
- Effect system (buffs/debuffs)
- Component-based architecture

## Required Components

Entity **MUST** have these child nodes or it will crash:

### 1. HealthComponent
**Node name:** `health` (exact match required)
**Path:** `assets/scripts/component/health.gd`

**Properties:**
- `@export var current_health := 5`
- `@export var max_health := 5`
- `@export var auto_delete := true` - queue_free when dead
- `@export var invulnerable := false` - ignore damage

**Signals:**
- `was_hit(info: DamageInfo)` - emitted on any damage/heal

**Methods:**
- `do_damage(info: DamageInfo)` - apply damage or heal
- `static Get(node: Node) -> HealthComponent` - retrieve component

**Why required:**
```gdscript
# Entity.gd line 15
@onready var health := HealthComponent.Get(self)
```

### 2. Targetable
**Node name:** `targetable` (exact match required)
**Path:** `assets/scripts/component/targetable.gd`

**Properties:**
- `@export var tags: PackedStringArray = []` - entity tags for filtering

**Methods:**
- `has_tag(tag: String) -> bool`
- `has_any_tag(tag_list: Array[String]) -> bool`
- `static Get(node: Node) -> Targetable` - retrieve component

**Auto-behavior:**
- Always adds "entity" tag in _ready()

**Why required:**
```gdscript
# Entity.gd line 18
@onready var _targetable: Targetable = Targetable.Get(self)
```

## Optional Components

These are common but not required by Entity base class:

### 3. MovementComponent (Recommended)
**Node name:** `movement`
**Path:** `assets/scripts/component/movement.gd`
**Usage:** Movement physics, speed modifiers, CC locks, forces
**See:** `docs/movement_system.md`

### 4. Caster
**Node name:** `caster`
**Path:** `assets/scripts/component/caster.gd`
**Usage:** Casting actions/spells

### 5. Knockback
**Node name:** `knockback`
**Path:** `assets/scripts/component/knockback.gd`
**Usage:** Knockback physics

## Component Naming Convention

**Critical:** Component nodes MUST be named exactly as specified:
- HealthComponent → node name: `"health"`
- Targetable → node name: `"targetable"`
- Caster → node name: `"caster"`
- etc.

Components validate their name in `_ready()`:
```gdscript
func _ready() -> void:
    assert(name == component_name, "Component must be named " + component_name)
```

## Entity Structure

**Typical entity scene tree:**
```
Entity (CharacterBody3D)
├─ health (HealthComponent) ← REQUIRED
├─ targetable (Targetable) ← REQUIRED
├─ caster (Caster) ← optional
├─ knockback (Knockback) ← optional
├─ Sprite3D / AnimatedSprite3D
├─ CollisionShape3D
└─ (other children)
```

**Minimal valid entity:**
```
Entity (CharacterBody3D)
├─ health (HealthComponent)
└─ targetable (Targetable)
```

## Creating a New Entity

### Method 1: Inherit from base_player or base_enemy
```
res://assets/entities/base_player.tscn
res://assets/entities/enemies/base_enemy.tscn
```

Both have required components already set up.

### Method 2: From scratch
1. Create new scene, root node: CharacterBody3D
2. Attach `entity.gd` script
3. Add child: Node, name it "health", attach `health.gd`
4. Add child: Node, name it "targetable", attach `targetable.gd`
5. Configure health/tags in inspector
6. Add visuals, collision, etc.

## Effect System Integration

Entity has built-in effect management:

**Properties:**
- `@export var effects: Array[Effect] = []` - active effects
- `signal effects_changed` - emitted on apply/expire/merge

**Methods:**
- `apply_effect(effect: Effect) -> void` - apply buff/debuff

**Example:**
```gdscript
var poison = PoisonEffect.new()
poison.source = attacker
poison.stack_count = 3
entity.apply_effect(poison)
```

See `docs/effect_system.md` for full effect system documentation.

## Static Helper

```gdscript
Entity.Get(node: Node) -> Entity
```

Returns node cast as Entity, with error if wrong type.

## Tags System

Tags stored in Targetable component, used for:
- Targeting filters (e.g., "enemy", "ally")
- Ability targeting (e.g., "undead", "beast")
- Game logic (e.g., "boss", "minion")

**Helper export (editor only):**
```gdscript
@export var tags: String  # comma-separated for editor
```

Parsed in `_ready()`, overrides targetable.tags (not recommended for prod).

**Proper way:**
Set tags directly on targetable component in scene.

## Component Access Pattern

All components use static Get() pattern:

```gdscript
# Retrieve component
var health = HealthComponent.Get(entity)
if health:
    health.do_damage(damage_info)

# Check if exists
if HealthComponent.Is(entity):
    # has health component
```

**Why:** Type-safe, null-safe, enforces naming convention.

## Common Patterns

### Damage an entity
```gdscript
var damage_info = DamageInfo.new(attacker, target)
damage_info.amount = 10
damage_info.type = DamageInfo.DamageType.PHYSICAL
target.health.do_damage(damage_info)
```

### Heal an entity
```gdscript
var heal_info = DamageInfo.new(healer, target)
heal_info.amount = 5
heal_info.type = DamageInfo.DamageType.HEAL
target.health.do_damage(heal_info)
```

### Check entity tags
```gdscript
var targetable = Targetable.Get(entity)
if targetable.has_tag("enemy"):
    # attack it
```

### Apply effect
```gdscript
var burn = BurnEffect.new()
burn.source = self
entity.apply_effect(burn)
```

## Troubleshooting

### "health is null" error
- Missing HealthComponent child
- Component not named "health" (case-sensitive)
- Component script not attached

### "targetable is null" error
- Missing Targetable child
- Component not named "targetable" (case-sensitive)
- Component script not attached

### Entity crashes on spawn
- Check both required components exist
- Check component names are exact
- Check scripts are attached to component nodes

### Effects not working
- Ensure effect has `target` set (apply_effect does this)
- Check effect timer is created (call super.on_applied())
- See `docs/effect_system.md`

## Future Considerations

- Dynamic max_stack_count modifiers (entity-wide effect buffs)
- Component dependency injection improvements
- Optional component query system
