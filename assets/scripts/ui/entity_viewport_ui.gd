## Unified SubViewport UI for entity health and effects.
## Automatically detects parent entity, displays health bar + effect bars.
## Manages render mode: ALWAYS when effects active, ONCE when static.
class_name EntityViewportUI

extends SubViewport

## Reference to parent entity (auto-detected)
var _entity: Entity

## UI container
var _container: VBoxContainer

## Health bar (no text, visual only)
var _health_bar: TextureProgressBar

## Effect entries (Label + ProgressBar per effect)
var _effect_entries: Dictionary[Effect, VBoxContainer] = {}

func _ready() -> void:
	# Auto-detect entity parent
	_entity = get_parent() as Entity
	assert(_entity != null, "EntityViewportUI must be child of Entity")
	
	# Setup viewport
	transparent_bg = true
	size = Vector2i(256, 128)
	render_target_update_mode = UPDATE_DISABLED
	
	# Create UI container
	_container = VBoxContainer.new()
	add_child(_container)
	
	# Create health bar (no text)
	_health_bar = TextureProgressBar.new()
	_health_bar.custom_minimum_size = Vector2(256, 32)
	_health_bar.max_value = _entity.health.max_health
	_health_bar.value = _entity.health.current_health
	_container.add_child(_health_bar)
	
	# Connect signals
	_entity.health.was_hit.connect(_on_health_changed)
	_entity.effects_changed.connect(_on_effects_changed)
	
	# Initial render
	render_target_update_mode = UPDATE_ONCE

func _process(_delta: float) -> void:
	# Update effect bar values (time remaining)
	if _effect_entries.size() > 0:
		_update_effect_bars()

func _on_health_changed(_info: DamageInfo) -> void:
	_health_bar.value = _entity.health.current_health
	
	# Render once if no effects (static)
	if _entity.effects.is_empty():
		render_target_update_mode = UPDATE_ONCE

func _on_effects_changed() -> void:
	_rebuild_effect_entries()
	_update_render_mode()

func _rebuild_effect_entries() -> void:
	# Remove old entries
	for entry in _effect_entries.values():
		entry.queue_free()
	_effect_entries.clear()
	
	# Create entry (Label + ProgressBar) for each effect
	for effect in _entity.effects:
		var entry := VBoxContainer.new()
		
		# Label with effect name + stack
		var label := Label.new()
		var effect_name := _get_effect_name(effect)
		if effect.stack_count > 1:
			label.text = "%s x%d" % [effect_name, effect.stack_count]
		else:
			label.text = effect_name
		entry.add_child(label)
		
		# ProgressBar for time remaining
		var bar := TextureProgressBar.new()
		bar.custom_minimum_size = Vector2(256, 20)
		bar.max_value = effect.duration
		bar.value = _get_remaining_time(effect)
		entry.add_child(bar)
		
		_container.add_child(entry)
		_effect_entries[effect] = entry

func _update_effect_bars() -> void:
	# Update time remaining on all effect bars
	for effect in _effect_entries.keys():
		if effect in _entity.effects:
			var entry: VBoxContainer = _effect_entries[effect]
			var bar: TextureProgressBar = entry.get_child(1) as TextureProgressBar
			bar.value = _get_remaining_time(effect)

func _update_render_mode() -> void:
	# ALWAYS update if effects active (bars draining)
	# ONCE update if no effects (static health bar)
	if _entity.effects.size() > 0:
		render_target_update_mode = UPDATE_ALWAYS
	else:
		render_target_update_mode = UPDATE_ONCE

func _get_remaining_time(effect: Effect) -> float:
	if not effect._duration_timer or not is_instance_valid(effect._duration_timer):
		return 0.0
	return effect._duration_timer.time_left

func _get_effect_name(effect: Effect) -> String:
	var script_path := effect.get_script().resource_path
	var file_name := script_path.get_file().get_basename()
	
	# Strip "Effect" suffix
	if file_name.ends_with("Effect"):
		file_name = file_name.trim_suffix("Effect")
	
	return file_name.capitalize()
