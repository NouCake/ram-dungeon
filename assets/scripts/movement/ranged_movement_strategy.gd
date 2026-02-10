class_name RangedMovementStrategy extends MovementStrategy

## Movement strategy for ranged actions - maintains safe distance from target.

## Minimum safe distance from target
@export var min_range := 5.0

## Maximum effective range
@export var max_range := 12.0

## Preferred distance from target (used when repositioning)
@export var preferred_range := 8.0

func get_target_position(entity: Entity, target: Entity) -> Vector3:
	if not target:
		return entity.global_position
	
	var distance = entity.global_position.distance_to(target.global_position)
	
	# If in good range, stay put
	if distance >= min_range and distance <= max_range:
		return entity.global_position
	
	# Too close: back away to preferred range
	if distance < min_range:
		var direction = target.global_position.direction_to(entity.global_position)
		return target.global_position + direction * preferred_range
	
	# Too far: move closer to preferred range
	if distance > max_range:
		var direction = entity.global_position.direction_to(target.global_position)
		return target.global_position + direction * preferred_range
	
	return entity.global_position

func should_move(entity: Entity, target: Entity) -> bool:
	if not target:
		return false
	
	var distance = entity.global_position.distance_to(target.global_position)
	# Move if outside safe range
	return distance < min_range or distance > max_range
