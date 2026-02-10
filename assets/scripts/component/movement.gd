class_name MovementComponent extends Node

## Component that handles entity movement physics and positioning.
## Actions set desired_position to control where the entity should move.

const component_name := "Movement"

## Base movement speed in units per second
@export var base_move_speed := 5.0

## Distance threshold to consider entity "arrived" at desired position
@export var close_enough_threshold := 0.1

## The position this entity wants to move toward
var desired_position: Vector3

var _entity: Entity

func _ready() -> void:
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")
	_entity = get_parent() as Entity
	assert(_entity != null, "MovementComponent must be child of Entity")
	
	# Initialize desired_position to current position (stay still by default)
	desired_position = _entity.global_position

## Static getter for accessing MovementComponent from an entity
static func Get(entity: Entity) -> MovementComponent:
	return entity.get_node_or_null(component_name) as MovementComponent

func _physics_process(delta: float) -> void:
	if not _entity:
		return
	
	# Check if we're close enough to desired position
	var distance_to_desired = _entity.global_position.distance_to(desired_position)
	if distance_to_desired <= close_enough_threshold:
		# Already at desired position, don't move
		_entity.velocity = Vector3.ZERO
		_entity.move_and_slide()
		return
	
	# Calculate direction toward desired position
	var direction = (_entity.global_position.direction_to(desired_position))
	
	# Set velocity
	_entity.velocity = direction * base_move_speed
	
	# Apply movement
	_entity.move_and_slide()
