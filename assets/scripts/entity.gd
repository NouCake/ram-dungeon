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

var effects : Array[TickEffect] = []

func apply_effect(effect: TickEffect) -> void:
	assert(effect != null, "Cannot apply null effect to entity, you suck!" + name)
	for e in effects:
		if e.type == effect.type:
			if e.stackable:
				e.stack_size += effect.stack_size
				return
			else:
				e.elapsed_time = 0.0
				return

	effects.append(effect)

func _process(delta: float) -> void:
	for effect in effects:
		if effect.is_expired():
			effects.erase(effect)
			continue
		effect.tick(delta, self)
