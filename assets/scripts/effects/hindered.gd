## Hindered effect: reduces movement speed.
class_name HinderedEffect

extends Effect

## Speed multiplier (0.75 = 25% slow)
@export var speed_multiplier := 0.75

func _init() -> void:
	duration = 3.0
	stackable = false

## Called by MovementComponent to get speed modifier
func get_move_speed_mult() -> float:
	return speed_multiplier
