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

var effects: Array[Effect] = []

func apply_effect(effect: Effect) -> void:
	assert(effect != null, "Cannot apply null effect to entity: " + name)
	
	# Set target
	effect.target = self
	
	# Check for existing effect of same type
	for existing in effects:
		if existing.effect_type == effect.effect_type:
			# If stackable, merge
			if existing is TickEffect and effect is TickEffect:
				var existing_tick := existing as TickEffect
				var new_tick := effect as TickEffect
				if existing_tick.stackable:
					existing_tick.merge_stack(new_tick)
					return
			
			# If refresh on reapply, refresh duration
			if existing.refresh_on_reapply:
				existing.refresh()
				return
			else:
				# Replace old effect
				existing.on_expired()
				effects.erase(existing)
				break
	
	# Add new effect
	effects.append(effect)
	effect.on_applied()
	
	# Connect expiry to cleanup
	if effect._duration_timer:
		effect._duration_timer.timeout.connect(_on_effect_expired.bind(effect))

func _on_effect_expired(effect: Effect) -> void:
	if effect in effects:
		effects.erase(effect)
		print("Effect " + effect.effect_type + " expired on entity " + name)
