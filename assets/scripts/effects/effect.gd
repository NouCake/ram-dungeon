## Base class for all effects (buffs/debuffs) that can be applied to entities.
## Effects are Resources with logic, timers live on the target entity.
class_name Effect

extends Resource

## Entity this effect is applied to (required)
var target: Entity

## Entity that caused this effect (optional, for attribution)
var source: Entity = null

## How long the effect lasts in seconds
@export var duration := 5.0

## If true, reapplying the effect refreshes the duration
@export var refresh_on_reapply := true

## Effect type identifier (for stacking/merging logic)
@export var effect_type: String = ""

## Internal: timer node managing effect lifetime (lives on target)
var _duration_timer: Timer = null

## Called when effect is first applied to target
func on_applied() -> void:
	assert(target != null, "Effect must have a target when applied")
	
	# Create duration timer on target entity
	_duration_timer = Timer.new()
	_duration_timer.wait_time = duration
	_duration_timer.one_shot = true
	_duration_timer.timeout.connect(_on_expired)
	target.add_child(_duration_timer)
	_duration_timer.start()
	
	# Subclass hook
	_on_applied()

## Called when effect expires naturally or is removed
func on_expired() -> void:
	_on_expired()
	_cleanup()

## Refresh the effect duration (if refresh_on_reapply is true)
func refresh() -> void:
	if _duration_timer and is_instance_valid(_duration_timer):
		_duration_timer.start(duration)

## Stop the effect and clean up timers
func _cleanup() -> void:
	if _duration_timer and is_instance_valid(_duration_timer):
		_duration_timer.queue_free()
		_duration_timer = null

## Override in subclasses: called when effect is applied
func _on_applied() -> void:
	pass

## Override in subclasses: called when effect expires
func _on_expired() -> void:
	pass
