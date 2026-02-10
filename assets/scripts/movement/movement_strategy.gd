## Base class for movement strategies.
## Decides WHERE an entity should move (pathfinding, positioning logic).
## Used by Actions/AI to control entity movement via MovementComponent.
class_name MovementStrategy

extends Resource

## Priority for this movement strategy (higher = more important)
## Used when multiple strategies want to control movement simultaneously
@export var priority := 0

## Calculate target position for entity to move toward.
## Override in subclasses for specific movement logic.
## Returns Vector3.ZERO if no movement needed.
func get_target_position() -> Vector3:
	push_warning("MovementStrategy.get_target_position not implemented in " + get_script().resource_path)
	return Vector3.ZERO

## Check if this strategy wants to control movement right now.
## Override for conditional strategies (e.g., only move if target out of range).
func should_move() -> bool:
	return true
