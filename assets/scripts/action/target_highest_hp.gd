## Targeting strategy: selects target with highest current HP.
class_name TargetHighestHP
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
	
	# Find highest HP
	var highest := valid_targets[0]
	var highest_hp := (highest.get_node("health") as HealthComponent).current_health
	
	for t in valid_targets:
		var hp := (t.get_node("health") as HealthComponent).current_health
		if hp > highest_hp:
			highest = t
			highest_hp = hp
	
	return [highest]
