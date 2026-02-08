## Stun effect: cannot move OR act.
## TODO: Integrate with action system when implemented
class_name StunnedEffect

extends Effect

func _init() -> void:
	duration = 1.0
	stackable = false
	refresh_on_reapply = true

func on_applied() -> void:
	super()
	
	# Lock movement
	var movement := MovementComponent.Get(target)
	if movement:
		movement.lock_movement()
	
	# TODO: Lock actions when action system ready

func on_expired() -> void:
	# Unlock movement
	var movement := MovementComponent.Get(target)
	if movement:
		movement.unlock_movement()
	
	# TODO: Unlock actions
	
	super()
