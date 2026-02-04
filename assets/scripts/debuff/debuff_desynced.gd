## Proof-of-concept debuff: flips enemy→ally targeting (like "Desynced" effect).
## When applied to an entity, all their actions targeting enemies will target allies instead.
class_name DebuffDesynced
extends Node

## Duration of the debuff in seconds
@export var duration: float = 5.0

## Reference to the entity this debuff is applied to
var target_entity: Node3D

## Original strategies to restore after debuff ends
var _original_strategies: Dictionary = {}

func _ready() -> void:
	if not target_entity:
		push_error("DebuffDesynced requires target_entity to be set before _ready()")
		queue_free()
		return
	
	_apply_debuff()
	
	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	_remove_debuff()
	queue_free()

func _apply_debuff() -> void:
	print("Applying Desynced debuff to " + target_entity.name)
	
	# Find all BaseActionTargeting actions on the entity
	for child in target_entity.get_children():
		if child is BaseActionTargeting:
			var action := child as BaseActionTargeting
			
			# Store original strategy
			_original_strategies[action] = action.targeting_strategy
			
			# Create flipped strategy: if targeting enemies, swap to allies
			if action.target_filters.has("enemy"):
				print("  - Flipping action: " + action.name + " from enemy→ally")
				# Keep same strategy type, just swap filter
				action.targeting_override = action.targeting_strategy
				action.target_filters = ["ally"]
			elif action.target_filters.has("ally"):
				print("  - Flipping action: " + action.name + " from ally→enemy")
				action.targeting_override = action.targeting_strategy
				action.target_filters = ["enemy"]

func _remove_debuff() -> void:
	print("Removing Desynced debuff from " + target_entity.name)
	
	# Restore original strategies and filters
	for action in _original_strategies.keys():
		if is_instance_valid(action):
			action.targeting_override = null
			# Restore original filters (hardcoded restoration, could be improved)
			if action is ActionProjectile:
				action.target_filters = ["enemy"]
			elif action is ActionHeal:
				action.target_filters = ["ally"]
			print("  - Restored action: " + action.name)
