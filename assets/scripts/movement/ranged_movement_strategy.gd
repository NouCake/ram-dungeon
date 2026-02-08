## Ranged movement strategy: maintain optimal range (not too close, not too far).
class_name RangedMovementStrategy

extends MovementStrategy

## Minimum safe distance from target
@export var min_range := 3.0

## Maximum effective range
@export var max_range := 10.0

## Preferred range (middle of min/max)
@export var preferred_range := 6.0

func _init() -> void:
	priority = 10  # Default priority

func get_target_position(entity: Entity, target: Entity) -> Vector3:
	if target == null:
		return entity.global_position
	
	var distance := entity.global_position.distance_to(target.global_position)
	var direction := (entity.global_position - target.global_position).normalized()
	
	if distance < min_range:
		# Too close, back away to preferred range
		return target.global_position + direction * preferred_range
	elif distance > max_range:
		# Too far, move closer to preferred range
		return target.global_position + direction * preferred_range
	else:
		# In good range, stay put
		return entity.global_position

func should_move(entity: Entity, target: Entity) -> bool:
	if target == null:
		return false
	
	# Move if outside optimal range
	var distance := entity.global_position.distance_to(target.global_position)
	return distance < min_range or distance > max_range
