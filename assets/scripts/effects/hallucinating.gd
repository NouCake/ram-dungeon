## Desynced effect: flips enemy↔ally targeting for all actions on target entity.
## Only restores original if targeting_override wasn't changed by another effect.
class_name Hallucinating

extends Effect

var _modified_actions: Dictionary[BaseAction, TargetingStrategy] = {}
@export var curve: Curve

func _init() -> void:
	duration = 5.0
	refresh_on_reapply = true
	stackable = true

## Curve that starts at 30% for 1 Stack and diminishes at 90% on 20 stacks. (30% effect on boss)
func chance_from_stacks() -> float:
	# thanks ai
	var min_chance := 0.0
	var max_chance := 0.9
	var k := 0.18 
	
	var normalized := 1.0 - exp(-k * (stack_count + 1))
	var result := min_chance + (max_chance - min_chance) * normalized
	
	return clampf(result, 0.0, max_chance)

func on_applied() -> void:
	super()
	
	for child in target.get_children():
		if child is BaseAction:
			var action := child as BaseAction
			_modified_actions[action] = TargetHalucinating.new(action, chance_from_stacks())
			action.targeting_override = _modified_actions[action]



func on_expired() -> void:
	for action: BaseAction in _modified_actions.keys():
		if not is_instance_valid(action):
			continue
		
		var stored := _modified_actions[action]
		# Only restore if targeting_override is still what we set
		if action.targeting_override == stored:
			action.targeting_override = null
	
	_modified_actions.clear()
	super()
