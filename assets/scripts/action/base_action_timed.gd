## Base Class for all Actions that do something in an interval
class_name BaseTimedAction

extends Node3D

const CasterComponentRes = preload("res://assets/scripts/component/caster.gd")
const TargetSnapshotRes = preload("res://assets/scripts/action/target_snapshot.gd")

## Time in seconds between each action attempt
@export var action_interval: float
## If true, the action is ready immediately on start
@export var start_ready := true
## If true, the action will only reset its timer on a successful action
@export var pause_until_action_success := false

@onready var time_since_last_action: float = action_interval if start_ready else 0.0

func _process(delta: float) -> void:
	if time_since_last_action >= action_interval:
		if !pause_until_action_success:
			time_since_last_action -= action_interval
			
		if perform_action() && pause_until_action_success:
			time_since_last_action -= action_interval
	else:
		time_since_last_action += delta


## Casting / windup settings
@export var cast_time_s := 0.0
@export var can_move_while_casting := true
@export var cancel_on_target_out_of_range := true


## Main entrypoint invoked by the timer cadence.
## Default behavior: if cast_time_s > 0, begin casting via CasterComponent and resolve on completion.
func perform_action() -> bool:
	# If parent is already casting something else, don't start.
	var caster := CasterComponentRes.Get(get_parent())
	if caster and caster.is_casting():
		return false

	if cast_time_s <= 0.0001:
		return resolve_action(get_target_snapshot())

	if !caster:
		push_warning("No CasterComponent found on %s; cannot cast action %s" % [get_parent().name, name])
		return false

	var snap = get_target_snapshot()
	if snap == null:
		push_warning("Action %s requested casting but returned null target snapshot" % name)
		return false
	return caster.try_start_cast(self, snap, cast_time_s, can_move_while_casting, cancel_on_target_out_of_range)


## Override: return a snapshot of the target at cast start, if relevant.
func get_target_snapshot():
	return null

## Override: do the actual action (damage/heal/spawn/etc.).
## Called immediately for cast_time_s==0, or at cast completion when cast_time_s>0.
func resolve_action(_snapshot) -> bool:
	return false