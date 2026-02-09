## Base Class for all Actions that do something in an interval
class_name BaseTimedCast

extends Node3D

## Time in seconds between each action attempt
@export var action_interval: float = 1.0
## If true, the action is ready immediately on start
@export var start_ready := true
## If true, the action will only reset its timer on a successful action
@export var pause_until_action_success := false

## Cooldown timer
var _cooldown_timer: Timer

func _ready() -> void:
	# Create cooldown timer
	_cooldown_timer = Timer.new()
	_cooldown_timer.wait_time = action_interval
	_cooldown_timer.one_shot = true
	add_child(_cooldown_timer)
	
	# Start ready or start cooldown
	if not start_ready:
		_cooldown_timer.start()

func _process(_delta: float) -> void:
	if is_cooldown_ready():
		if not pause_until_action_success:
			_cooldown_timer.start()  # Start cooldown
		
		if perform_action() and pause_until_action_success:
			_cooldown_timer.start()  # Start cooldown only on success

## Check if cooldown is ready (timer stopped)
func is_cooldown_ready() -> bool:
	return _cooldown_timer.is_stopped()


## Time before action is performed
@export var cast_time := 0.0
@export var can_move_while_casting := true
@export var cancel_on_target_out_of_range := true
@export var cancel_on_damage_taken := false

func perform_action() -> bool:
	var caster := CasterComponent.Get(get_parent())
	if caster.is_casting():
		return false

	var snapshot := get_target_snapshot()
	if snapshot == null or snapshot.targets.is_empty():
		return false

	if cast_time <= 0.0001:
		resolve_action(snapshot)
		return true

	return caster.try_start_cast(self, snapshot, cast_time, can_move_while_casting, cancel_on_target_out_of_range, cancel_on_damage_taken)

## Override: return a snapshot of the target at cast start, if relevant.
func get_target_snapshot() -> TargetSnapshot:
	return null

## Override: do the actual action (damage/heal/spawn/etc.).
## Called immediately when casting finished.
func resolve_action(_snapshot: TargetSnapshot) -> bool:
	return false
