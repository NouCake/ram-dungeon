## Targeting strategy: selects target with lowest current HP.
class_name TargetLowestHP
extends TargetingStrategy

func _select_from_candidates(detector: TargetDetectorComponent, candidates: Array[Node3D]) -> Array[Node3D]:
	if candidates.is_empty():
		return []
	
	# Filter targets that have health component
	var valid_targets: Array[Node3D] = []
	for t in candidates:
		if t.has_node("health"):
			valid_targets.append(t)
	
	if valid_targets.is_empty():
		return []
	
	# Find lowest HP
	var lowest := valid_targets[0]
	var lowest_hp := (lowest.get_node("health") as HealthComponent).current_health
	
	for t in valid_targets:
		var hp := (t.get_node("health") as HealthComponent).current_health
		if hp < lowest_hp:
			lowest = t
			lowest_hp = hp
	
	return [lowest]
