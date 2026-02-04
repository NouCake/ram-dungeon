## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedCast

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]
## How far the action can reach targets
@export var action_range: float
## Targeting strategy to use (configurable per action)
@export var targeting_strategy: TargetingStrategy

## Runtime override for targeting (e.g., debuffs like "Desynced")
var targeting_override: TargetingStrategy = null

@onready var detector := TargetDetectorComponent.Get(get_parent())

func get_target_snapshot() -> TargetSnapshot:
	# Use override if set (e.g., debuff), otherwise use configured strategy
	var active_strategy := targeting_override if targeting_override else targeting_strategy
	
	# No fallback - strategy must be set
	if not active_strategy:
		push_error("No targeting strategy set for " + name + ". Action requires targeting_strategy to be configured.")
		return null
	
	# Use strategy to find targets
	var targets := active_strategy.select_targets(detector, target_filters, action_range, true)
	
	if targets.is_empty():
		return null
	
	# For single-target actions, take first result
	var t := targets[0]
	var snapshot := TargetSnapshot.new()
	snapshot.max_range = action_range
	snapshot.target = t
	snapshot.target_position = t.global_position
	return snapshot
