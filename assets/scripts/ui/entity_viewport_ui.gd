## Unified SubViewport UI for entity health and effects.
## Automatically detects parent entity, displays health bar + effect bars.
## Manages render mode: ALWAYS when effects active, ONCE when static.
class_name EntityHud
extends Sprite3D

var _effect_entries: Dictionary[Effect, Control] = {}
@export var effect_bar_scene: PackedScene

@onready var _entity: Entity = get_parent()
@onready var _entity_health: HealthComponent = HealthComponent.Get(_entity)
@onready var _container: VBoxContainer = get_node("viewport/container")
@onready var _health_bar: TextureProgressBar = get_node("viewport/container/health_bar")
@onready var _viewport: SubViewport = get_node("viewport")

func _ready() -> void:
	assert(_entity != null, "EntityHud must be child of Entity")

	_entity_health.was_hit.connect(_on_health_changed)
	_entity.effects_changed.connect(_on_effects_changed)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	_health_bar.max_value = _entity_health.max_health
	_health_bar.value = _entity_health.current_health

func _process(_delta: float) -> void:
	if _effect_entries.size() > 0:
		_update_effect_bars()

func _on_health_changed(_info: DamageInfo) -> void:
	_health_bar.max_value = _entity_health.max_health
	_health_bar.value = _entity_health.current_health
	_update_render_mode()

func _on_effects_changed() -> void:
	_rebuild_effect_entries()
	_update_render_mode()

func _rebuild_effect_entries() -> void:
	for entry: Control in _effect_entries.values():
		entry.queue_free()
	_effect_entries.clear()
	
	for effect in _entity.effects:
		var entry := _build_effect_ui(effect)
		_container.add_child(entry)
		_container.move_child(entry, 0)
		_effect_entries[effect] = entry

func _build_effect_ui(effect: Effect) -> Control:
	var entry := effect_bar_scene.instantiate() as Control

	var name_label := entry.get_node("name") as Label
	var bar := entry.get_node("progress") as ProgressBar

	bar.max_value = effect.duration
	bar.value = _get_remaining_time(effect)
	name_label.text = _get_effect_name(effect)

	return entry
		
func _update_effect_bars() -> void:
	for effect: Effect in _effect_entries.keys():
		if effect in _entity.effects:
			var entry: Control = _effect_entries[effect]
			if entry == null:
				print("Warning: No UI entry found for effect %s" % _get_effect_name(effect))
				continue
			
			var bar: ProgressBar = entry.get_node("progress") as ProgressBar
			bar.value = _get_remaining_time(effect)

func _update_render_mode() -> void:
	if _entity.effects.size() > 0:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _get_remaining_time(effect: Effect) -> float:
	if not effect._duration_timer or not is_instance_valid(effect._duration_timer):
		return 0.0
	return effect._duration_timer.time_left

func _get_effect_name(effect: Effect) -> String:
	var script: Script = effect.get_script()
	var _name: String = script.get_global_name()
	if _name.contains("Effect"):
		_name = _name.replace("Effect", "")
	_name += "x" + str(effect.stack_count)
	return _name
