# Entity Viewport UI - Usage Guide

## Overview
Unified SubViewport-based UI system that displays both health and active effects for an entity. Automatically manages render mode for performance.

## How It Works

```
Entity (Node3D in 3D world)
└─ EntityViewportUI (SubViewport with script)
   └─ VBoxContainer (auto-created)
      ├─ TextureProgressBar (health)
      └─ ... effects (Control)
		├─ Label
		└─ ProgressBar
```

## Features

✅ **Auto-detection**: Finds parent Entity and connects to health / effect changes

## Render Mode Logic

**ALWAYS (continuous):**
- When entity has no effects
- Effect bars drain in real-time
- ~60 FPS updates

**ONCE (on-demand):**
- When no effects on entity applied
- Only re-renders when health changes
- Minimal performance cost

**Why this matters:**
- 100 entities with no effects = nearly free (100 × 1 render on damage)
- 10 entities with effects = moderate (10 × 60 FPS)
- Performance scales naturally with gameplay state


**Typical costs:**

| Scenario | Cost |
|----------|------|
| 100 entities, no effects | ~Free (static) |
| 10 entities with 3 effects each | ~10 viewport updates/frame |
| 1 entity with 10 effects | ~1 viewport update/frame |

**Optimization tips:**
- Pool TextureProgressBar nodes if creating/destroying many

## Notes

- Entity signals drive all updates (health_changed, effects_changed)
- No _process needed when no effects (performance!)
