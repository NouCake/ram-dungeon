## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedAction

const TargetSnapshotRes = preload("res://assets/scripts/action/target_snapshot.gd")

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]

## How far the action can reach targets
@export var action_range: float

@onready var detector := TargetDetectorComponent.Get(get_parent())

func get_target_snapshot():
	var snap := TargetSnapshotRes.new()
	snap.max_range = action_range
	var t := detector.find_closest(target_filters, action_range, true)
	snap.target = t
	if t:
		snap.target_position = t.global_position
	return snap