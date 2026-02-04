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
		if existing.is_same_type(effect):
			# If stackable, merge
			if existing.stackable:
				existing.merge(effect)
				print("Merged effect into existing: " + existing.get_script().resource_path.get_file())
				return
			
			# If not stackable, reject new application
			print("Effect already applied (not stackable): " + existing.get_script().resource_path.get_file())
			return
	
	# Add new effect
	effects.append(effect)
	effect.on_applied()
	print("Applied new effect: " + effect.get_script().resource_path.get_file())
	
	# Connect expiry to cleanup
	if effect._duration_timer:
		effect._duration_timer.timeout.connect(_on_effect_expired.bind(effect))

func _on_effect_expired(effect: Effect) -> void:
	if effect in effects:
		effects.erase(effect)
		print("Effect expired: " + effect.get_script().resource_path.get_file())
