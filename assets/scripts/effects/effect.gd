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

## If true, multiple applications of this effect can stack
@export var stackable := false

## Maximum number of stacks allowed (0 = unlimited)
@export var max_stack_count := 0

## For stackable effects: how many stacks are currently active
@export var stack_count := 1

var _duration_timer: Timer = null

func is_same_type(other: Effect) -> bool:
	return get_script() == other.get_script()

## Merge another effect of the same type (for stackable effects).
func merge(other: Effect) -> void:
	assert(is_same_type(other), "Cannot merge effects of different types.")
	if stackable:
		var new_stacks := stack_count + other.stack_count
		
		# Cap at max_stack_count if set
		if max_stack_count > 0:
			stack_count = mini(new_stacks, max_stack_count)
		else:
			stack_count = new_stacks
		
		if refresh_on_reapply:
			refresh()

## Called when effect is first applied to target.
## Override in subclasses, call super() to preserve timer setup.
func on_applied() -> void:
	assert(target != null, "Effect must have a target when applied")
	_duration_timer = TimerUtil.delay(target, duration, on_expired)

## Called when effect expires naturally or is removed.
## Override in subclasses, MUST call super() to ensure cleanup.
func on_expired() -> void:
	_cleanup()

## Refresh the effect duration (if refresh_on_reapply is true)
func refresh() -> void:
	if _duration_timer and is_instance_valid(_duration_timer):
		_duration_timer.start(duration)

func _cleanup() -> void:
	if _duration_timer and is_instance_valid(_duration_timer):
		_duration_timer.queue_free()
		_duration_timer = null
