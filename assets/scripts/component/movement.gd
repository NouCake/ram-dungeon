## Component that handles entity movement physics and positioning.
## Actions set desired_position to control where the entity should move.
class_name MovementComponent

extends Node

const component_name := "movement"

static func Get(entity: Entity) -> MovementComponent:
	return entity.get_node_or_null(component_name) as MovementComponent

## Distance threshold to consider entity "arrived" at desired position
@export var close_enough_threshold := 0.1
@export var base_move_speed := 5.0

var desired_position: Vector3

var _entity: Entity

func _ready() -> void:
	_entity = get_parent() as Entity
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")
	assert(_entity != null, "MovementComponent must be child of Entity")
	
	desired_position = _entity.global_position


func _physics_process(_delta: float) -> void:
	if not _entity:
		return
	
	# Check if movement is locked by casting
	var caster = CasterComponent.Get(_entity)
	if caster and caster.movement_locked():
		_entity.velocity = Vector3.ZERO
		_entity.move_and_slide()
		return
	
	# Check if we're close enough to desired position
	var distance_to_desired := _entity.global_position.distance_to(desired_position)
	if distance_to_desired <= close_enough_threshold:
		# Already at desired position, don't move
		_entity.velocity = Vector3.ZERO
		_entity.move_and_slide()
		return
	
	var direction := (_entity.global_position.direction_to(desired_position))
	_entity.velocity = direction * base_move_speed
	_entity.move_and_slide()
