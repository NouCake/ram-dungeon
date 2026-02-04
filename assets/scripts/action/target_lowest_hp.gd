## Targeting strategy: selects target with lowest current HP.
class_name TargetLowestHP
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
	
	# Filter targets that have health component
	var valid_targets: Array[Node3D] = []
	for t in targets:
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
