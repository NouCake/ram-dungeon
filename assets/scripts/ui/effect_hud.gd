## Displays active effects on an entity as a text list.
## Shows effect name and stack count (if > 1).
## Auto-updates when entity's effects change.
class_name EffectHUD

extends Label

## Entity to watch for effects (e.g., player)
@export var target_entity: Entity

## Maximum number of effects to display (0 = unlimited)
@export var max_lines := 10

## If true, sort debuffs before buffs (damage effects first)
@export var sort_debuffs_first := false

func _ready() -> void:
	if not target_entity:
		push_warning("EffectHUD: no target_entity set, will not display effects")
		return
	
	# Connect to entity's effects_changed signal
	target_entity.effects_changed.connect(_update_display)
	
	# Initial display
	_update_display()

func _update_display() -> void:
	if not target_entity:
		text = ""
		return
	
	var effect_list := target_entity.effects.duplicate()
	
	# Optional: sort effects
	if sort_debuffs_first:
		effect_list.sort_custom(_sort_debuffs_first)
	
	# Build text lines
	var lines: Array[String] = []
	var count := 0
	
	for effect in effect_list:
		if max_lines > 0 and count >= max_lines:
			lines.append("... (%d more)" % (effect_list.size() - count))
			break
		
		var effect_name := _get_effect_name(effect)
		
		if effect.stack_count > 1:
			lines.append("%s x%d" % [effect_name, effect.stack_count])
		else:
			lines.append(effect_name)
		
		count += 1
	
	text = "\n".join(lines)

## Extract human-readable name from effect script path
func _get_effect_name(effect: Effect) -> String:
	var script_path := effect.get_script().resource_path
	var file_name := script_path.get_file().get_basename()
	
	# Strip "Effect" suffix if present (e.g., "PoisonEffect" -> "Poison")
	if file_name.ends_with("Effect"):
		file_name = file_name.trim_suffix("Effect")
	
	# Capitalize and add spaces (e.g., "Poison" or "Desynced")
	return file_name.capitalize()

## Sort comparator: debuffs (damage effects) before buffs
func _sort_debuffs_first(a: Effect, b: Effect) -> bool:
	var a_is_debuff := _is_debuff(a)
	var b_is_debuff := _is_debuff(b)
	
	if a_is_debuff and not b_is_debuff:
		return true
	if not a_is_debuff and b_is_debuff:
		return false
	
	# If both same type, sort alphabetically
	return _get_effect_name(a) < _get_effect_name(b)

## Heuristic: TickEffect = debuff (damage over time)
func _is_debuff(effect: Effect) -> bool:
	return effect is TickEffect
