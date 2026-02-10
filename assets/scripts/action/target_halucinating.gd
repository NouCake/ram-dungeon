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
	line_of_sight: bool
) -> Array[Node3D]:
	var r := randf()
	if r > random_chance && source_action.targeting_strategy != self:
		return source_action.targeting_strategy.select_targets(
			detector,
			filters,
			line_of_sight
		)

	# Get all candidates regardless of filters (hallucinating!)
	var candidates = _get_candidates(detector, [], line_of_sight)
	if candidates.is_empty():
		return []
	
	return [candidates.pick_random()]

func _select_from_candidates(detector: TargetDetectorComponent, candidates: Array[Node3D]) -> Array[Node3D]:
	# Not used - overriding select_targets directly
	return []
