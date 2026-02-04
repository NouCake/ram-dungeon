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

## Active effects on this entity, exported for debugging purposes.
@export var effects: Array[Effect] = []

func _ready() -> void:
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
				return
			return
	
	effects.append(effect)
	effect.on_applied()
	
	# cleanup
	if effect._duration_timer:
		effect._duration_timer.timeout.connect(_on_effect_expired.bind(effect))

func _on_effect_expired(effect: Effect) -> void:
	if effect in effects:
		effects.erase(effect)
