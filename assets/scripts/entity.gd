# An Entity is any character or creature in the game world.
# Has health, is targetable
# Has basic movement capabilities
# Has animations
class_name Entity

extends CharacterBody3D

static func Get(node: Node) -> Entity:
	if !(node is Entity):
		push_error("Node " + node.name + " is not an Entity.")
		
	return node;

@onready var health := HealthComponent.Get(self)
@onready var _movement_component := MovementComponent.Get(self)

## Emitted whenever effects array changes (apply, expire, merge)
signal effects_changed

## Cached actions with movement strategies (set once in _ready, never changes)
var _actions_with_movement: Array[BaseTimedCast] = []

## Active effects on this entity, exported for debugging purposes.
@export var effects: Array[Effect] = []

## helper value to quickly override tags in editor, but not intended for prod use
@export var tags: String;

## Helper for editor to show tags as comma-separated string, but store as array
@onready var _targetable: Targetable = Targetable.Get(self)

func _ready() -> void:
	# Assert required components
	assert(_movement_component != null, "Entity %s must have a MovementComponent child named 'Movement'" % name)
	
	# Cache actions with movement strategies (actions don't change at runtime)
	for child in get_children():
		if child is BaseTimedCast and child.movement_strategy != null:
			_actions_with_movement.append(child)
	
	if tags != null and tags.length() > 0 and ",".join(_targetable.tags) != tags:
		push_warning("Overriding tags from Entity. Should be not used for prod build")
		_targetable.tags = PackedStringArray(tags.split(","))
		_targetable.tags.append("entity")

	# correctly applying initial effects if any were added in the editor
	var start_effects := effects;
	effects = [];
	for effect in start_effects:
		apply_effect(effect);


func apply_effect(effect: Effect) -> void:
	assert(effect != null, "Cannot apply null effect to entity: " + name)
	effect.target = self
	
	for existing in effects:
		if existing.is_same_type(effect):
			if existing.stackable:
				existing.merge(effect)
				effects_changed.emit()
				return
			return
	
	effects.append(effect)
	effect.on_applied()
	
	# cleanup
	if effect._duration_timer:
		effect._duration_timer.timeout.connect(_on_effect_expired.bind(effect))
	
	effects_changed.emit()

func _on_effect_expired(effect: Effect) -> void:
	if effect in effects:
		effects.erase(effect)
		effects_changed.emit()

func _process(_delta: float) -> void:
	_update_movement_control()

## Determines which action controls movement based on priority and cooldown rules
func _update_movement_control() -> void:
	if _actions_with_movement.is_empty():
		return
	
	var controlling_action = _select_movement_controlling_action(_actions_with_movement)
	if not controlling_action:
		return
	
	# Get target from the controlling action
	var target = controlling_action.get_current_target()
	if not target:
		return
	
	# Check if action has movement strategy
	if not controlling_action.movement_strategy:
		push_warning("Action %s is controlling movement but has no movement_strategy. Use StandStillMovementStrategy if this is intentional." % controlling_action.name)
		return
	
	# Apply movement strategy to movement component
	if controlling_action.movement_strategy.should_move(self, target):
		var target_pos = controlling_action.movement_strategy.get_target_position(self, target)
		_movement_component.desired_position = target_pos

## Selects which action should control movement based on kevin's rules:
## - When actions ready: highest priority wins
## - When all on cooldown: lowest remaining cooldown wins
## - Tiebreaker: priority
func _select_movement_controlling_action(actions: Array[BaseTimedCast]) -> BaseTimedCast:
	var ready_actions: Array[BaseTimedCast] = []
	var cooldown_actions: Array[BaseTimedCast] = []
	
	# Separate ready vs on cooldown
	for action in actions:
		if action.is_cooldown_ready():
			ready_actions.append(action)
		else:
			cooldown_actions.append(action)
	
	# Rule 1: If some ready, pick highest priority
	if not ready_actions.is_empty():
		ready_actions.sort_custom(func(a, b): return a.priority > b.priority)
		return ready_actions[0]
	
	# Rule 2: All on cooldown, pick lowest remaining time (priority as tiebreaker)
	cooldown_actions.sort_custom(func(a, b):
		var time_a = a.get_cooldown_remaining()
		var time_b = b.get_cooldown_remaining()
		if abs(time_a - time_b) < 0.01:  # Essentially same time
			return a.priority > b.priority  # Tiebreaker: priority
		return time_a < time_b  # Lower cooldown wins
	)
	return cooldown_actions[0]
