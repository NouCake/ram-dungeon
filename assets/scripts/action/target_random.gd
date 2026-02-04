## Targeting strategy: selects random target in range.
class_name TargetRandom
extends TargetingStrategy

func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	max_range: float,
	line_of_sight: bool
) -> Array[Node3D]:
	var targets := detector.find_all(filters, max_range, line_of_sight)
	if targets.is_empty():
		return []
	return [targets.pick_random()]
