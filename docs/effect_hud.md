# Effect HUD - Usage Guide

## Overview
Text-based HUD that displays active effects on an entity (e.g., player). Updates live when effects are applied/expired.

## Components

### 1. EffectHUD (Label node)
Script: `assets/scripts/ui/effect_hud.gd`

**Setup:**
1. Add a `Label` node to your UI scene
2. Attach `effect_hud.gd` script
3. Set `target_entity` to the player entity
4. Configure options:
   - `max_lines`: limit displayed effects (0 = unlimited)
   - `sort_debuffs_first`: show damage effects first

**Display format:**
```
Poison x4
Burn x1
Desynced
```

### 2. Entity Signal
Added `effects_changed` signal to Entity class.

Emits when:
- Effect applied
- Effect merged (stackable)
- Effect expired

### 3. Test Helper (optional)
Script: `test/effect_test_helper.gd`

Attach to a Node in test scene for quick effect testing.

**Default keybinds (modify in script or project settings):**
- `ui_text_submit`: Apply poison
- `ui_text_backspace`: Apply burn
- `ui_text_clear`: Apply desynced

## Scene Setup (Human Task)

Kevin needs to:

1. **Add HUD to player/UI scene:**
   - Create `Label` node (or `RichTextLabel` if want formatting)
   - Position on screen (e.g., top-right corner)
   - Attach `effect_hud.gd`
   - Set `target_entity` to player entity reference

2. **Optional: Test scene:**
   - Create test scene with player entity
   - Add `Node` with `effect_test_helper.gd`
   - Set `target_entity` to player
   - Run scene, press keys to apply effects
   - Watch HUD update

## Features

✅ **Live updates**: Auto-refreshes when effects change
✅ **Stack display**: Shows "x4" for stackable effects
✅ **Smart naming**: Strips "Effect" suffix, capitalizes
✅ **Sorting**: Optional debuff-first ordering
✅ **Overflow handling**: Shows "... (N more)" if too many effects
✅ **No icons needed**: Pure text display

## Customization

**Change effect display format:**
Edit `_update_display()` in `effect_hud.gd`:
```gdscript
# Example: show duration
lines.append("%s x%d (%.1fs)" % [effect_name, effect.stack_count, effect.duration])
```

**Different sort order:**
Edit `_sort_debuffs_first()` or add custom comparator.

**Styling:**
Use Label's theme properties in Godot editor (font, color, size, etc).

## Testing Checklist

- [ ] Apply poison → HUD shows "Poison"
- [ ] Apply poison again → HUD shows "Poison x2"
- [ ] Apply burn → HUD shows both effects
- [ ] Wait for effect to expire → HUD updates
- [ ] Apply non-stackable effect twice → HUD shows only once
- [ ] Apply > max_lines effects → Shows "... (N more)"

## Notes

- Effects are sorted alphabetically if `sort_debuffs_first = false`
- TickEffect (Poison, Burn) considered debuffs by default
- Desynced and custom effects may need custom `_is_debuff()` logic
- Signal approach ensures HUD stays in sync with entity state
