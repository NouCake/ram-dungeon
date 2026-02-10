## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedCast

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]
## Minimum distance for action (won't execute if target closer than this)
@export var min_distance: float = 0.0
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
	
	# Filter out targets that are too close
	if min_distance > 0.0:
		var entity = get_parent() as Entity
		if entity:
			targets = targets.filter(func(target):
				var distance = entity.global_position.distance_to(target.global_position)
				return distance >= min_distance
			)
	
	if targets.is_empty():
		return null
	
	var snapshot := TargetSnapshot.new()
	snapshot.max_range = action_range
	snapshot.targets = targets
	return snapshot
