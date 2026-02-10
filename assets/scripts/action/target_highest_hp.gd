## Targeting strategy: selects target with highest current HP.
class_name TargetHighestHP
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
	
	# Find highest HP
	var highest := valid_targets[0]
	var highest_hp := (highest.get_node("health") as HealthComponent).current_health
	
	for t in valid_targets:
		var hp := (t.get_node("health") as HealthComponent).current_health
		if hp > highest_hp:
			highest = t
			highest_hp = hp
	
	return [highest]
