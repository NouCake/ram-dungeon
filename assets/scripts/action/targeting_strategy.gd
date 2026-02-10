## Base class for all targeting strategies.
## Subclasses implement select_targets() to define how targets are chosen.
class_name TargetingStrategy
extends Resource

## Minimum range for targeting (targets closer than this won't be considered at all, even for movement)
## Use BaseAction.min_execution_range instead if you want targets for movement but not execution
@export var min_range: float = 0.0

## Maximum range for targeting (targets farther than this are filtered out)
@export var max_range: float = 100.0

## Returns array of targets based on strategy implementation.
## For single-target actions, caller takes first element.
## For multi-target actions (future), caller uses full array.
## Range filtering is applied by base class before strategy logic.
func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	line_of_sight: bool
) -> Array[Node3D]:
	var candidates := _get_candidates(detector, filters, line_of_sight)
	
	candidates = _filter_by_range(detector.get_parent() as Entity, candidates)
	if candidates.is_empty():
		return []
	
	# Let subclass apply its selection logic
	return _select_from_candidates(detector, candidates)

func _get_candidates(
	detector: TargetDetectorComponent,
	filters: Array[String],
	line_of_sight: bool
) -> Array[Node3D]:
	var all := detector.find_all(filters, 0, line_of_sight)
	var parent := detector.get_parent() as Node3D
	return all.filter(func(target: Node3D) -> bool:
		var distance := parent.global_position.distance_to(target.global_position)
		if min_range > 0.0 and distance < min_range:
			return false
		if max_range > 0.0 and distance > max_range:
			return false
		return true
	)

## Filter candidates by min/max range
func _filter_by_range(entity: Entity, candidates: Array[Node3D]) -> Array[Node3D]:
	if min_range <= 0.0 and max_range <= 0.0:
		return candidates
	
	return candidates.filter(func(target: Node3D) -> bool:
		var distance := entity.global_position.distance_to(target.global_position)
		if min_range > 0.0 and distance < min_range:
			return false
		if max_range > 0.0 and distance > max_range:
			return false
		return true
	)

## Override in subclasses to implement selection logic (e.g., closest, lowest HP, etc.)
func _select_from_candidates(_detector: TargetDetectorComponent, _candidates: Array[Node3D]) -> Array[Node3D]:
	return []
