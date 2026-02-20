class_name TargetRandom

extends TargetingStrategy

var _current_target: Node3D = null

func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	line_of_sight: bool
) -> Array[Node3D]:
	if _current_target and is_instance_valid(_current_target):
		return [_current_target]

	var candidates := _get_candidates(detector, filters, line_of_sight)
	if candidates.is_empty():
		return []
	
	_current_target = candidates.pick_random()
	return [_current_target]

func _select_from_candidates(_detector: TargetDetectorComponent, _candidates: Array[Node3D]) -> Array[Node3D]:
	# Not used - overriding select_targets directly
	return []

func _on_action_started() -> void:
	_current_target = null