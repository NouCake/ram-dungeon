## Targeting strategy: selects closest target.
class_name TargetClosest
extends TargetingStrategy

func _select_from_candidates(detector: TargetDetectorComponent, candidates: Array[Node3D]) -> Array[Node3D]:
	if candidates.is_empty():
		return []
	
	var parent := detector.get_parent() as Node3D
	if not parent:
		return [candidates[0]]
	
	var closest := candidates[0]
	var closest_dist := (closest.global_position - parent.global_position).length()
	
	for t in candidates:
		var dist := (t.global_position - parent.global_position).length()
		if dist < closest_dist:
			closest = t
			closest_dist = dist
	
	return [closest]
