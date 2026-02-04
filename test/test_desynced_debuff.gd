## Test/demo script showing how to apply DebuffDesynced to an entity.
## Usage: Attach to a test scene, call apply_desynced_to_entity(entity)
extends Node

const DebuffDesyncedRes = preload("res://assets/scripts/debuff/debuff_desynced.gd")

## Example: Apply desynced debuff to an entity for 5 seconds
func apply_desynced_to_entity(entity: Node3D, duration: float = 5.0) -> void:
	var debuff := DebuffDesyncedRes.new()
	debuff.target_entity = entity
	debuff.duration = duration
	
	# Add debuff as child of entity so it travels with entity
	entity.add_child(debuff)
	
	print("Applied Desynced debuff to " + entity.name + " for " + str(duration) + " seconds")

## Example test: could be called from _ready() or triggered by input
func _test_desynced() -> void:
	# Find a player entity in the scene
	var player := get_tree().get_first_node_in_group("player")
	if player:
		apply_desynced_to_entity(player, 10.0)
	else:
		push_warning("No player found in scene for desynced test")
