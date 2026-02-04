## Test/demo script for the new effect system.
## Shows how to apply various effects to entities.
extends Node

## Example: Apply poison to an entity
func apply_poison_to_entity(entity: Entity, source: Entity = null, stacks: int = 1) -> void:
	var poison := PoisonEffect.new()
	poison.source = source
	poison.stack_count = stacks
	entity.apply_effect(poison)
	print("Applied " + str(stacks) + " stack(s) of poison to " + entity.name)

## Example: Apply burn to an entity
func apply_burn_to_entity(entity: Entity, source: Entity = null, stacks: int = 1) -> void:
	var burn := BurnEffect.new()
	burn.source = source
	burn.stack_count = stacks
	entity.apply_effect(burn)
	print("Applied " + str(stacks) + " stack(s) of burn to " + entity.name)

## Example: Apply desynced debuff to an entity
func apply_desynced_to_entity(entity: Entity, duration_sec: float = 5.0) -> void:
	var desynced := DesyncedEffect.new()
	desynced.duration = duration_sec
	entity.apply_effect(desynced)
	print("Applied Desynced for " + str(duration_sec) + " seconds to " + entity.name)

## Test: Apply stacking poison
func _test_stacking_poison() -> void:
	var player := get_tree().get_first_node_in_group("player") as Entity
	if not player:
		push_warning("No player found for poison test")
		return
	
	# Apply 3 stacks rapidly
	apply_poison_to_entity(player, null, 1)
	await get_tree().create_timer(0.5).timeout
	apply_poison_to_entity(player, null, 2)
	await get_tree().create_timer(0.5).timeout
	apply_poison_to_entity(player, null, 3)
	
	print("Player should have 6 total poison stacks")

## Test: Apply desynced effect
func _test_desynced() -> void:
	var player := get_tree().get_first_node_in_group("player") as Entity
	if not player:
		push_warning("No player found for desynced test")
		return
	
	apply_desynced_to_entity(player, 10.0)
	print("Player targeting should be flipped for 10 seconds")

## Hook up to input for manual testing
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space/Enter
		_test_stacking_poison()
	elif event.is_action_pressed("ui_select"):  # Shift+Space
		_test_desynced()
