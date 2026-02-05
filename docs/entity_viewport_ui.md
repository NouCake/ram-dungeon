# Entity Viewport UI - Usage Guide

## Overview
Unified SubViewport-based UI system that displays both health and active effects for an entity. Uses TextureProgressBar for visual feedback, automatically manages render mode for performance.

## How It Works

```
Entity (Node3D in 3D world)
└─ EntityViewportUI (SubViewport with script)
   └─ VBoxContainer (auto-created)
      ├─ TextureProgressBar (health)
      └─ TextureProgressBar (per effect, auto-generated)
```

The SubViewport renders 2D UI that can be displayed:
- On a Sprite3D (billboard)
- On a MeshInstance3D with QuadMesh (surface)
- In any 3D space

## Features

✅ **Auto-detection**: Finds parent Entity via `get_parent()`
✅ **Health bar**: Shows current/max health
✅ **Effect bars**: One per active effect with time remaining
✅ **Smart rendering**:
  - `UPDATE_ALWAYS` when effects active (bars animate)
  - `UPDATE_ONCE` when static (performance optimization)
✅ **Stack display**: Shows "Poison x4" for stackable effects
✅ **No manual wiring**: Connects to signals automatically

## Setup (Kevin)

### 1. Add SubViewport to Entity

In entity scene (e.g., player.tscn, enemy.tscn):

```
Player (Entity)
├─ health (HealthComponent)
├─ EntityViewportUI (SubViewport)
│  └─ attach entity_viewport_ui.gd script
└─ Sprite3D (for display)
```

### 2. Configure Sprite3D

```gdscript
# Sprite3D inspector or code:
var viewport: SubViewport = $EntityViewportUI
sprite_3d.texture = viewport.get_texture()
sprite_3d.pixel_size = 0.01  # scale to world size
sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED  # face camera
```

### 3. Done!

No exports to set, no manual connections. EntityViewportUI finds entity and wires itself up.

## Scene Tree Example

```
Player (extends Entity)
├─ health (HealthComponent)
├─ Sprite3D
│  └─ texture = $EntityViewportUI.get_texture()
└─ EntityViewportUI (SubViewport)
   └─ entity_viewport_ui.gd (attached)
```

**Runtime UI tree (auto-generated):**
```
EntityViewportUI
└─ VBoxContainer
   ├─ TextureProgressBar [████████░░] (health, no text)
   ├─ VBoxContainer (effect entry)
   │  ├─ Label "Poison x4"
   │  └─ TextureProgressBar [███░░░]
   └─ VBoxContainer (effect entry)
      ├─ Label "Burn x1"
      └─ TextureProgressBar [██████]
```

## Render Mode Logic

**ALWAYS (continuous):**
- When `entity.effects.size() > 0`
- Effect bars drain in real-time
- ~60 FPS updates

**ONCE (on-demand):**
- When `entity.effects.is_empty()`
- Only re-renders when health changes
- Minimal performance cost

**Why this matters:**
- 100 entities with no effects = nearly free (100 × 1 render on damage)
- 10 entities with effects = moderate (10 × 60 FPS)
- Performance scales naturally with gameplay state

## Customization

### Change Bar Appearance

Use TextureProgressBar theme in Godot editor:
- Under/Over/Progress textures
- Tint colors
- Fill mode

Or set in code:
```gdscript
_health_bar.texture_progress = preload("res://textures/health_fill.png")
_health_bar.tint_progress = Color.GREEN
```

### Adjust Viewport Size

Edit `entity_viewport_ui.gd`:
```gdscript
size = Vector2i(512, 256)  # larger resolution
```

### Add More UI Elements

In `_ready()`:
```gdscript
var label = Label.new()
label.text = _entity.name
_container.add_child(label)
```

## Testing

### Test Health Bar
1. Create test scene with entity
2. Add EntityViewportUI as child
3. Add Sprite3D, link texture
4. Damage entity → bar updates

### Test Effect Bars
1. Apply effect to entity: `entity.apply_effect(PoisonEffect.new())`
2. Bar appears below health
3. Watch bar drain
4. Effect expires → bar disappears

### Test Render Mode
- Add print in `_update_render_mode()`
- Apply effect → console shows "UPDATE_ALWAYS"
- Wait for expire → console shows "UPDATE_ONCE"

## Performance

**Typical costs:**

| Scenario | Cost |
|----------|------|
| 100 entities, no effects | ~Free (static) |
| 10 entities with 3 effects each | ~30 viewport updates/frame |
| 1 entity with 10 effects | ~1 viewport update/frame |

**Optimization tips:**
- Lower `size` for distant entities (LOD)
- Use `UPDATE_WHEN_VISIBLE` if needed (Godot auto-culls)
- Pool TextureProgressBar nodes if creating/destroying many

## Comparison to Old System

| Old (EffectHUD.gd) | New (EntityViewportUI.gd) |
|--------------------|---------------------------|
| Separate health + effect scripts | Unified script |
| Manual entity reference | Auto-detect parent |
| Label-based UI | TextureProgressBar UI |
| Always 2D overlay | Works in 3D space |
| No render optimization | Smart UPDATE_ONCE/ALWAYS |

## Migration

Old EffectHUD.gd is replaced by EntityViewportUI.gd. No backward compatibility needed (new feature).

## Notes

- SubViewport is child of Entity (3D node)
- UI lives inside SubViewport (2D space)
- Sprite3D displays the viewport texture (3D world)
- Entity signals drive all updates (health_changed, effects_changed)
- No _process needed when no effects (performance!)
