## Test helper for manually applying effects to an entity.
## Attach to a Node in test scene, set target_entity to player.
## Use keyboard shortcuts to apply different effects.
extends Node

@export var target_entity: Entity

func _ready() -> void:
	assert(target_entity != null, "EffectTestHelper: target_entity must be set")

func _input(event: InputEvent) -> void:
	# Press 1: Apply poison (stackable)
	if event.is_action_pressed("ui_text_submit"):  # numpad enter or 1
		_apply_poison()
	
	# Press 2: Apply burn (stackable)
	if event.is_action_pressed("ui_text_backspace"):  # or bind to 2
		_apply_burn()
	
	# Press 3: Apply desynced (non-stackable)
	if event.is_action_pressed("ui_text_clear"):  # or bind to 3
		_apply_desynced()

func _apply_poison() -> void:
	var poison := PoisonEffect.new()
	poison.stack_count = 1
	target_entity.apply_effect(poison)
	print("Applied Poison to ", target_entity.name)

func _apply_burn() -> void:
	var burn := BurnEffect.new()
	burn.stack_count = 1
	target_entity.apply_effect(burn)
	print("Applied Burn to ", target_entity.name)

func _apply_desynced() -> void:
	var desynced := DesyncedEffect.new()
	target_entity.apply_effect(desynced)
	print("Applied Desynced to ", target_entity.name)
