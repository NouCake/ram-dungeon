## First-class movement system for entities.
## Handles physics, speed modifiers, movement locks (CC), forces (knockback/pull), and events.
## Integrates with Effect system and zones.
class_name MovementComponent

extends Node

@export var base_move_speed := 5.0
## Knockback resistance (0.0 = no resistance, 1.0 = immune)
@export var knockback_resistance := 0.0

var desired_position: Vector3 = Vector3.ZERO
var is_movement_locked := false

var _active_forces: Array[Vector3] = []
var _distance_traveled_this_frame := 0.0

## Reference to parent entity
@onready var _entity: Entity = get_parent()

static var component_name: String = "movement"

static func Is(node: Node) -> bool:
	if node == null:
		return false
	
	if node.has_node(component_name):
		assert(node.get_node(component_name) is MovementComponent, "Node has a " + component_name + " component but it's type is wrong.")
		return true
	return false
static func Get(node: Node) -> MovementComponent:
	if Is(node):
		return node.get_node(component_name)
	return null

func _ready() -> void:
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")
	assert(_entity != null, "MovementComponent must be child of Entity")

func _physics_process(delta: float) -> void:
	if is_movement_locked:
		return
	
	_apply_forces(delta)

func _calculate_speed_multiplier() -> float:
	var speed_multiplier := 1.0
	
	for effect in _entity.effects:
		## Todo: Make entity have stats and effects modify stats
		if effect.has_method("get_move_speed_mult"):
			speed_multiplier *= effect.get_move_speed_mult()
	return speed_multiplier

## Apply external one-time forces (knockback, pull)
func _apply_forces(delta: float) -> void:
	if _active_forces.is_empty():
		return
	
	var total_force := Vector3.ZERO
	for force in _active_forces:
		total_force += force
	
	total_force *= (1.0 - knockback_resistance)
	
	var before_velocity := _entity.velocity
	if _entity is CharacterBody3D:
		_entity.velocity += total_force * delta
		_entity.move_and_slide()
		print("Applied force: ", total_force, " New velocity: ", _entity.velocity)
		_entity.velocity = before_velocity
	
	# Clear forces after application (one-frame impulse)
	_active_forces.clear()

## Move entity toward desired position
func _move_toward_target(_delta: float) -> void:
	if not _entity is CharacterBody3D:
		return
	
	var direction := (desired_position - _entity.global_position).normalized()
	var actual_speed := base_move_speed * _calculate_speed_multiplier()
	_entity.velocity = direction * actual_speed
	
	var old_position := _entity.global_position
	_entity.move_and_slide()
	_distance_traveled_this_frame = _entity.global_position.distance_to(old_position)

func apply_force(force: Vector3) -> void:
	_active_forces.append(force)

func lock_movement() -> void:
	is_movement_locked = true

func unlock_movement() -> void:
	is_movement_locked = false
