## Targeting strategy: selects target with lowest HP percentage.
class_name TargetLowestHPPercent
extends TargetingStrategy

func _select_from_candidates(_detector: TargetDetectorComponent, candidates: Array[Node3D]) -> Array[Node3D]:
	if candidates.is_empty():
		return []
	
	# Filter targets that have health component
	var valid_targets: Array[Node3D] = []
	for t in candidates:
		if t.has_node("health"):
			valid_targets.append(t)
	
	if valid_targets.is_empty():
		return []
	
	# Find lowest HP %
	var lowest := valid_targets[0]
	var health := (lowest.get_node("health") as HealthComponent)
	var lowest_percent := health.current_health / float(health.max_health)
	
	for t in valid_targets:
		var h := (t.get_node("health") as HealthComponent)
		var percent := h.current_health / float(h.max_health)
		if percent < lowest_percent:
			lowest = t
			lowest_percent = percent
	
	return [lowest]
