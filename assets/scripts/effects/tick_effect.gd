## Effect that triggers repeatedly at a fixed interval (e.g., damage/heal over time).
class_name TickEffect

extends Effect

## How often the effect triggers (in seconds)
@export var tick_interval := 1.0

## For stacking logic (poison, burn, etc)
@export var stackable: bool = false
var stack_size := 1

## Internal: timer for repeating ticks (lives on target)
var _tick_timer: Timer = null

func _on_applied() -> void:
	# Set effect type for stacking
	if effect_type.is_empty():
		effect_type = get_script().resource_path.get_file().get_basename()
	
	# Create repeating tick timer on target entity
	_tick_timer = Timer.new()
	_tick_timer.wait_time = tick_interval
	_tick_timer.one_shot = false  # repeating
	_tick_timer.timeout.connect(_on_tick)
	target.add_child(_tick_timer)
	_tick_timer.start()

func _on_expired() -> void:
	# Clean up tick timer
	if _tick_timer and is_instance_valid(_tick_timer):
		_tick_timer.queue_free()
		_tick_timer = null

## Merge another effect of same type (for stacking)
func merge_stack(other: TickEffect) -> void:
	if stackable and other.effect_type == effect_type:
		stack_size += other.stack_size
		# Optionally refresh duration
		if refresh_on_reapply:
			refresh()

## Override in subclasses: called every tick_interval
func _on_tick() -> void:
	pass