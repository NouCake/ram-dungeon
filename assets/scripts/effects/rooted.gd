## Rooted effect: cannot move (but can still act).
class_name RootedEffect

extends Effect

func _init() -> void:
	duration = 2.0
	stackable = false
	refresh_on_reapply = true

func on_applied() -> void:
	super()
	
	# Lock movement
	var movement := MovementComponent.Get(target)
	if movement:
		movement.lock_movement()

func on_expired() -> void:
	# Unlock movement
	var movement := MovementComponent.Get(target)
	if movement:
		movement.unlock_movement()
	
	super()
