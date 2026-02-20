class_name TargetRandom

extends TargetingStrategy


func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	line_of_sight: bool
) -> Array[Node3D]:

	var candidates := _get_candidates(detector, filters, line_of_sight)
	if candidates.is_empty():
		return []
	
	return [candidates.pick_random()]

func _select_from_candidates(_detector: TargetDetectorComponent, _candidates: Array[Node3D]) -> Array[Node3D]:
	# Not used - overriding select_targets directly
	return []
