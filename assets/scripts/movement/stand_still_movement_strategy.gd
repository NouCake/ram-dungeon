class_name StandStillMovementStrategy extends MovementStrategy

## Movement strategy that keeps entity at current position.
## Use for stationary entities or actions that don't require movement.

func get_target_position(entity: Entity, target: Entity) -> Vector3:
	return entity.global_position

func should_move(entity: Entity, target: Entity) -> bool:
	return false
