class_name MovementStrategy extends Resource

## Base class for movement strategies that calculate where an entity should move.
## Used by actions to control entity positioning behavior.

## Calculate the target position this entity should move toward.
## Override in subclasses to implement specific movement behaviors.
## @param entity: The entity that is moving
## @param target: The entity being targeted (can be null)
## @return: World position the entity should move toward
func get_target_position(entity: Entity, target: Entity) -> Vector3:
	# Default: stay at current position
	return entity.global_position

## Check if the entity should move given current state.
## Override in subclasses to add conditions (e.g., only move if out of range).
## @param entity: The entity that would move
## @param target: The entity being targeted (can be null)
## @return: true if entity should move, false to stay still
func should_move(entity: Entity, target: Entity) -> bool:
	return target != null
