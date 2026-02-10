## Base class for all targeting strategies.
## Subclasses implement select_targets() to define how targets are chosen.
class_name TargetingStrategy
extends Resource

## Minimum range for targeting (targets closer than this are filtered out)
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
	var candidates = _get_candidates(detector, filters, line_of_sight)
	
	# Filter by range
	candidates = _filter_by_range(detector.get_parent(), candidates)
	
	if candidates.is_empty():
		return []
	
	# Let subclass apply its selection logic
	return _select_from_candidates(detector, candidates)

## Get all potential targets matching filters and line of sight
func _get_candidates(
	detector: TargetDetectorComponent,
	filters: Array[String],
	line_of_sight: bool
) -> Array[Node3D]:
	return detector.get_entities_in_range(filters, max_range, line_of_sight)

## Filter candidates by min/max range
func _filter_by_range(entity: Entity, candidates: Array[Node3D]) -> Array[Node3D]:
	if min_range <= 0.0 and max_range <= 0.0:
		return candidates
	
	return candidates.filter(func(target):
		var distance = entity.global_position.distance_to(target.global_position)
		if min_range > 0.0 and distance < min_range:
			return false
		if max_range > 0.0 and distance > max_range:
			return false
		return true
	)

## Override in subclasses to implement selection logic (e.g., closest, lowest HP, etc.)
func _select_from_candidates(_detector: TargetDetectorComponent, _candidates: Array[Node3D]) -> Array[Node3D]:
	push_error("TargetingStrategy._select_from_candidates() must be overridden in subclass")
	return []
