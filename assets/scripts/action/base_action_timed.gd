## Base Class for all Actions that do something in an interval
class_name BaseTimedAction

extends Node3D

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


## Override this method to perform the desired action.
func perform_action() -> bool:
	return false