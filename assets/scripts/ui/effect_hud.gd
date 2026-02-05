## Displays active effects on an entity as progress bars.
## Each effect shows name + stack count, with bar indicating time remaining.
## Auto-updates when entity's effects change.
class_name EffectHUD

extends VBoxContainer

## Entity to watch for effects (e.g., player)
@export var target_entity: Entity

## Track progress bars for each effect
var _effect_bars: Dictionary[Effect, ProgressBar] = {}

func _ready() -> void:
	assert(target_entity != null, "EffectHUD: target_entity must be set in editor")
	
	# Connect to entity's effects_changed signal
	target_entity.effects_changed.connect(_rebuild_display)
	
	# Initial display
	_rebuild_display()

func _process(_delta: float) -> void:
	# Update progress bars each frame
	_update_bars()

func _rebuild_display() -> void:
	# Clear existing bars
	for bar in _effect_bars.values():
		bar.queue_free()
	_effect_bars.clear()
	
	if not target_entity:
		return
	
	# Create progress bar for each effect
	for effect in target_entity.effects:
		var bar := ProgressBar.new()
		bar.show_percentage = false  # We'll set custom text
		bar.max_value = effect.duration
		bar.value = _get_remaining_time(effect)
		
		# Set text (name + stack count)
		var effect_name := _get_effect_name(effect)
		if effect.stack_count > 1:
			bar.text = "%s x%d" % [effect_name, effect.stack_count]
		else:
			bar.text = effect_name
		
		add_child(bar)
		_effect_bars[effect] = bar

func _update_bars() -> void:
	# Update progress bar values based on remaining time
	for effect in _effect_bars.keys():
		if effect in target_entity.effects:
			var bar: ProgressBar = _effect_bars[effect]
			bar.value = _get_remaining_time(effect)

func _get_remaining_time(effect: Effect) -> float:
	if not effect._duration_timer or not is_instance_valid(effect._duration_timer):
		return 0.0
	return effect._duration_timer.time_left

## Extract human-readable name from effect script path
func _get_effect_name(effect: Effect) -> String:
	var script_path := effect.get_script().resource_path
	var file_name := script_path.get_file().get_basename()
	
	# Strip "Effect" suffix if present (e.g., "PoisonEffect" -> "Poison")
	if file_name.ends_with("Effect"):
		file_name = file_name.trim_suffix("Effect")
	
	# Capitalize and add spaces (e.g., "Poison" or "Desynced")
	return file_name.capitalize()
