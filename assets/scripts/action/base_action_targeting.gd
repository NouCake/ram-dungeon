## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedCast

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]
## How far the action can reach targets
@export var action_range: float

@onready var detector := TargetDetectorComponent.Get(get_parent())

func get_target_snapshot() -> TargetSnapshot:
	var target := detector.find_closest(target_filters, action_range, true)

	if target == null:
		return null

	var snapshot := TargetSnapshot.new()
	snapshot.max_range = action_range
	snapshot.target = target
	snapshot.target_position = snapshot.target.global_position
	return snapshot
