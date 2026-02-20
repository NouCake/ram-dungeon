## Targeting strategy: selects random target in range.
class_name TargetHalucinating

extends TargetingStrategy

## Chance to select a random target (0.0 to 1.0)
var random_chance : float
var source_action: BaseAction

var _current_target: Node3D = null

func _init(_source_action: BaseAction, _random_chance: float) -> void:
	self.source_action = _source_action
	self.random_chance = _random_chance
	_source_action.action_started.connect(_on_action_started)

func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	line_of_sight: bool
) -> Array[Node3D]:
	if _current_target and is_instance_valid(_current_target):
		return [_current_target]

	var r := randf()
	if r > random_chance && source_action.targeting_strategy != self:
		return source_action.targeting_strategy.select_targets(
			detector,
			filters,
			line_of_sight
		)

	# Get all candidates regardless of filters (hallucinating!)
	var candidates := _get_candidates(detector, [], line_of_sight)
	if candidates.is_empty():
		return []
	
	_current_target = candidates.pick_random()
	return [_current_target]

func _select_from_candidates(_detector: TargetDetectorComponent, _candidates: Array[Node3D]) -> Array[Node3D]:
	# Not used - overriding select_targets directly
	return []

func _on_action_started() -> void:
	print("Action started, resetting hallucinatig target")
	_current_target = null