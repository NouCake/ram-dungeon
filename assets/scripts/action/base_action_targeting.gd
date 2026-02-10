## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedCast

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]
## Minimum distance to execute action (won't execute if target closer, but will still target for movement)
@export var min_execution_range: float = 0.0
## Targeting strategy to use (configurable per action)
@export var targeting_strategy: TargetingStrategy
@export var line_of_sight := true

## Runtime override for targeting (e.g., debuffs like "Desynced")
var targeting_override: TargetingStrategy = null

@onready var detector := TargetDetectorComponent.Get(get_parent())

func get_target_snapshot() -> TargetSnapshot:
	var active_strategy := targeting_override if targeting_override else targeting_strategy
	assert(active_strategy != null, "No targeting strategy set for " + name + ". Action requires targeting_strategy to be configured.")
	
	var targets := active_strategy.select_targets(detector, target_filters, line_of_sight)
	
	if targets.is_empty():
		return null
	
	var snapshot := TargetSnapshot.new()
	snapshot.max_range = active_strategy.max_range
	snapshot.targets = targets
	return snapshot

func perform_action() -> bool:
	var caster := CasterComponent.Get(get_parent())
	if caster.is_casting():
		return false

	var snapshot := get_target_snapshot()
	if snapshot == null or snapshot.targets.is_empty():
		return false
	
	# Check min execution range (target exists but too close to execute)
	if min_execution_range > 0.0:
		var entity = get_parent() as Entity
		if entity:
			var distance = entity.global_position.distance_to(snapshot.targets[0].global_position)
			if distance < min_execution_range:
				return false  # Too close to execute, but target still valid for movement

	if cast_time <= 0.0001:
		resolve_action(snapshot)
		return true

	return caster.try_start_cast(self, snapshot, cast_time, can_move_while_casting, cancel_on_target_out_of_range, cancel_on_damage_taken)
