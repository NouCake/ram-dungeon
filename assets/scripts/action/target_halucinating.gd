## Targeting strategy: selects random target in range.
class_name TargetHalucinating

extends TargetingStrategy

## Chance to select a random target (0.0 to 1.0)
var random_chance : float
var source_action: BaseActionTargeting

func _init(_source_action: BaseActionTargeting, _random_chance: float) -> void:
	self.source_action = _source_action
	self.random_chance = _random_chance

func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	max_range: float,
	line_of_sight: bool
) -> Array[Node3D]:
	var r := randf()
	if r > random_chance && source_action.targeting_strategy != self:
		return source_action.targeting_strategy.select_targets(
			detector,
			filters,
			max_range,
			line_of_sight
		)

	var targets := detector.find_all([], max_range, line_of_sight)
	if targets.is_empty():
		return []
	return [targets.pick_random()]
