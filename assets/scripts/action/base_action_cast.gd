## Base Class for all Actions that do something in an interval
class_name BaseTimedCast

extends Node3D

## Time in seconds between each action attempt
@export var action_interval: float = 1.0
## If true, the action is ready immediately on start
@export var start_ready := true
## If true, the action will only reset its timer on a successful action
@export var pause_until_action_success := false

## Priority for movement control (higher = takes control first when multiple actions ready)
@export var priority := 10

## Movement strategy for this action (how to position relative to target)
@export var movement_strategy: MovementStrategy

@onready var time_since_last_action: float = action_interval if start_ready else 0.0

func _process(delta: float) -> void:
	if time_since_last_action >= action_interval:
		if !pause_until_action_success:
			time_since_last_action -= action_interval
			
		if perform_action() && pause_until_action_success:
			time_since_last_action -= action_interval
	else:
		time_since_last_action += delta


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

## Check if this action's cooldown is ready
func is_cooldown_ready() -> bool:
	return time_since_last_action >= action_interval

## Get remaining cooldown time in seconds
func get_cooldown_remaining() -> float:
	if is_cooldown_ready():
		return 0.0
	return action_interval - time_since_last_action

## Get the current target for this action (from targeting system)
## Override in subclasses or return first target from snapshot
func get_current_target() -> Entity:
	var snapshot = get_target_snapshot()
	if snapshot and not snapshot.targets.is_empty():
		return snapshot.targets[0]
	return null
