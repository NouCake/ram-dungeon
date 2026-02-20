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

@onready var caster: CasterComponent = CasterComponent.Get(get_parent() as Entity)

var desired_position: Vector3

var _entity: Entity
var _active_forces: Array[Vector3] = []

func _ready() -> void:
	_entity = get_parent() as Entity
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")
	assert(_entity != null, "MovementComponent must be child of Entity")
	
	desired_position = _entity.global_position


func _physics_process(_delta: float) -> void:
	if not _entity:
		return

	_apply_forces(_delta)
	
	# Check if movement is locked by casting
	if caster.movement_locked():
		_entity.velocity = Vector3.ZERO
		_move()
		return
	
	# Check if we're close enough to desired position
	var distance_to_desired := _entity.global_position.distance_to(desired_position)
	if distance_to_desired <= close_enough_threshold:
		# Already at desired position, don't move
		_entity.velocity = Vector3.ZERO
		_move()
		return
	
	var direction := (_entity.global_position.direction_to(desired_position))
	_entity.velocity = direction * base_move_speed
	_move()

func _move() -> void:
	_entity.move_and_slide()
	for i in _entity.get_slide_collision_count():
		var collision := _entity.get_slide_collision(i)
		var other := collision.get_collider() as Entity
		_push_entity(other, collision)
	
func _push_entity(other: Entity, collision: KinematicCollision3D) -> void:
	var push_direction := collision.get_normal()
	var push_strength := 50.0
	
	var other_movement := MovementComponent.Get(other)
	other_movement._active_forces.append(-push_direction * push_strength)
	_active_forces.append(push_direction * push_strength)

func _apply_forces(delta: float) -> void:
	if _active_forces.is_empty():
		return
	
	var total_force := Vector3.ZERO
	for force in _active_forces:
		total_force += force
	total_force.y = 0  # Only apply horizontal forces for now
	
	var before_velocity := _entity.velocity
	if _entity is CharacterBody3D:
		_entity.velocity += total_force * delta
		_entity.move_and_slide()
		_entity.velocity = before_velocity
	
	# Clear forces after application (one-frame impulse)
	_active_forces.clear()
