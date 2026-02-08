## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedCast

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]
## How far the action can reach targets
@export var action_range: float
## Targeting strategy to use (configurable per action)
@export var targeting_strategy: TargetingStrategy
@export var line_of_sight := true

## Runtime override for targeting (e.g., debuffs like "Desynced")
var targeting_override: TargetingStrategy = null

@onready var detector := TargetDetectorComponent.Get(get_parent())

func get_target_snapshot() -> TargetSnapshot:
	var active_strategy := targeting_override if targeting_override else targeting_strategy
	assert(active_strategy != null, "No targeting strategy set for " + name + ". Action requires targeting_strategy to be configured.")
	
	var targets := active_strategy.select_targets(detector, target_filters, action_range, line_of_sight)
	
	if targets.is_empty():
		return null
	
	var snapshot := TargetSnapshot.new()
	snapshot.max_range = action_range
	snapshot.targets = targets
	return snapshot
