## First-class movement system for entities.
## Handles physics, speed modifiers, movement locks (CC), forces (knockback/pull), and events.
## Integrates with Effect system and zones.
class_name MovementComponent

extends Node

## Base movement speed (units per second)
@export var base_move_speed := 5.0

## Knockback resistance (0.0 = no resistance, 1.0 = immune)
@export var knockback_resistance := 0.0

## Current desired target position (set by AI/Actions via MovementStrategy)
var desired_position: Vector3 = Vector3.ZERO

## Whether movement is locked (Root/Stun/Petrify/Stasis)
var is_movement_locked := false

## Current speed multiplier (calculated from effects/zones)
var speed_multiplier := 1.0

## Active external forces (knockback/pull)
var _active_forces: Array[Vector3] = []

## Distance traveled this frame (for event tracking)
var _distance_traveled_this_frame := 0.0

## Reference to parent entity
@onready var _entity: Entity = get_parent()

## Emitted when entity starts moving
signal movement_started

## Emitted when entity stops moving
signal movement_stopped

## Emitted each frame with distance traveled (for bleeding trigger, etc)
signal moved(distance: float)

## Emitted when dash occurs (future: implement dash)
signal dashed

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
	# Calculate speed multiplier from effects/zones
	_calculate_speed_multiplier()
	
	# Check if movement is locked by CC
	if is_movement_locked:
		return
	
	# Apply external forces (knockback/pull)
	_apply_forces(delta)
	
	# Move toward desired position
	_move_toward_target(delta)

## Calculate speed multiplier by querying all effects and zones
func _calculate_speed_multiplier() -> void:
	speed_multiplier = 1.0
	
	# Query effects for speed modifiers
	for effect in _entity.effects:
		if effect.has_method("get_move_speed_mult"):
			speed_multiplier *= effect.get_move_speed_mult()
	
	# TODO: Query zones for speed modifiers
	# TODO: Apply stacking rules (additive vs multiplicative, caps)

## Apply external forces (knockback, pull) with resistance
func _apply_forces(delta: float) -> void:
	if _active_forces.is_empty():
		return
	
	var total_force := Vector3.ZERO
	for force in _active_forces:
		total_force += force
	
	# Apply resistance
	total_force *= (1.0 - knockback_resistance)
	
	# Apply force to entity velocity
	if _entity is CharacterBody3D:
		_entity.velocity += total_force * delta
		_entity.move_and_slide()
	
	# Clear forces after application (one-frame impulse)
	_active_forces.clear()

## Move entity toward desired position
func _move_toward_target(delta: float) -> void:
	if not _entity is CharacterBody3D:
		return
	
	# Calculate direction to target
	var direction := (desired_position - _entity.global_position).normalized()
	
	# Calculate actual speed with modifiers
	var actual_speed := base_move_speed * speed_multiplier
	
	# Set velocity
	_entity.velocity = direction * actual_speed
	
	# Move
	var old_position := _entity.global_position
	_entity.move_and_slide()
	
	# Track distance traveled
	_distance_traveled_this_frame = _entity.global_position.distance_to(old_position)
	
	# Emit movement events
	if _distance_traveled_this_frame > 0.0:
		moved.emit(_distance_traveled_this_frame)

## Add external force (knockback/pull)
func apply_force(force: Vector3) -> void:
	_active_forces.append(force)

## Lock movement (called by CC effects: Root, Stun, etc)
func lock_movement() -> void:
	is_movement_locked = true

## Unlock movement (called when CC expires)
func unlock_movement() -> void:
	is_movement_locked = false
