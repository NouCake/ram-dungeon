## Targeting strategy: selects target with lowest HP percentage.
class_name TargetLowestHPPercent
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
