## Targeting strategy: selects closest target.
class_name TargetClosest
extends TargetingStrategy

func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	max_range: float,
	line_of_sight: bool
) -> Array[Node3D]:
	var target := detector.find_closest(filters, max_range, line_of_sight)
	if target:
		return [target]
	return []
