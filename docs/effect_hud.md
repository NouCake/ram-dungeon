# Effect HUD - Usage Guide

## Overview
Progress bar-based HUD that displays active effects on an entity (e.g., player). Each effect shown as a progress bar with name/stack count as text, bar fill indicates time remaining.

## Components

### 1. EffectHUD (VBoxContainer)
Script: `assets/scripts/ui/effect_hud.gd`

**Setup:**
1. Add a `VBoxContainer` node to your UI scene
2. Attach `effect_hud.gd` script
3. Set `target_entity` to the player entity

**Display format:**
```
[Poison x4     ████████░░]
[Burn x1       ██████████]
[Desynced      ████░░░░░░]
```

Each ProgressBar:
- Text: effect name + stack count (if > 1)
- Fill: time remaining on effect
- Auto-created/destroyed when effects change

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
   - Create `VBoxContainer` node
   - Position on screen (e.g., top-right corner)
   - Attach `effect_hud.gd`
   - Set `target_entity` to player entity reference

2. **Optional: Test scene:**
   - Create test scene with player entity
   - Add `Node` with `effect_test_helper.gd`
   - Set `target_entity` to player
   - Run scene, press keys to apply effects
   - Watch progress bars appear/update/disappear

## Features

✅ **Live updates**: Progress bars update each frame
✅ **Auto-rebuild**: Bars created/destroyed when effects change
✅ **Stack display**: Shows "x4" for stackable effects
✅ **Time visualization**: Bar fill = remaining duration
✅ **No manual styling needed**: ProgressBar text built-in
✅ **Simple**: No sorting, no colors, no extra labels

## Customization

**Change bar appearance:**
Use VBoxContainer/ProgressBar theme in Godot editor (colors, fonts, sizes).

**Add spacing:**
Set `VBoxContainer.add_theme_constant_override("separation", 5)` in editor or code.

## Testing Checklist

- [ ] Apply poison → bar appears with "Poison"
- [ ] Apply poison again → bar shows "Poison x2"
- [ ] Watch bar drain over time
- [ ] Effect expires → bar disappears
- [ ] Apply multiple effects → multiple bars
- [ ] Non-stackable reapply → bar refreshes (resets to full)

## Technical Notes

- `_process()` updates bar values each frame via `time_left`
- `effects_changed` signal triggers full rebuild (destroy + recreate bars)
- Each effect's `_duration_timer` provides `time_left` for progress
- ProgressBar's `text` property shows effect name (no separate Label needed)

## Performance

- Rebuilds bars only when effects change (not every frame)
- Updates bar values in `_process` (cheap operation)
- Scales well to ~10 effects; more may need pooling
