class_name MeleeMovementStrategy extends MovementStrategy

## Movement strategy for melee actions - moves entity close to target.

## How close to get to the target (in units)
@export var attack_range := 2.0

func get_target_position(entity: Entity, target: Entity) -> Vector3:
	if not target:
		return entity.global_position
	
	# Calculate distance to target
	var distance = entity.global_position.distance_to(target.global_position)
	
	# If already in range, stay at current position
	if distance <= attack_range:
		return entity.global_position
	
	# Move toward target, stopping at attack_range distance
	var direction = entity.global_position.direction_to(target.global_position)
	return target.global_position - direction * attack_range

func should_move(entity: Entity, target: Entity) -> bool:
	if not target:
		return false
	
	# Only move if out of attack range
	var distance = entity.global_position.distance_to(target.global_position)
	return distance > attack_range
