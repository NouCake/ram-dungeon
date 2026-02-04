## Targeting strategy: selects closest target.
class_name TargetClosest
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
	
	# Find closest manually
	var parent := detector.get_parent() as Node3D
	var closest := targets[0]
	var closest_dist := (closest.global_position - parent.global_position).length()
	
	for t in targets:
		var dist := (t.global_position - parent.global_position).length()
		if dist < closest_dist:
			closest = t
			closest_dist = dist
	
	return [closest]
