## Melee movement strategy: walk straight into melee range.
class_name MeleeMovementStrategy

extends MovementStrategy

## Melee attack range
@export var attack_range := 2.0

func _init() -> void:
	priority = 10  # Default priority

func get_target_position(entity: Entity, target: Entity) -> Vector3:
	if target == null:
		return entity.global_position
	
	# Walk straight toward target
	var direction := (target.global_position - entity.global_position).normalized()
	
	# Stop at attack range
	var distance := entity.global_position.distance_to(target.global_position)
	if distance <= attack_range:
		return entity.global_position  # Already in range
	
	# Move to just inside attack range
	return target.global_position - direction * attack_range

func should_move(entity: Entity, target: Entity) -> bool:
	if target == null:
		return false
	
	# Only move if outside attack range
	var distance := entity.global_position.distance_to(target.global_position)
	return distance > attack_range
