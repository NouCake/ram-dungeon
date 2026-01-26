## Applied effect to all entities within a certain range at regular intervals.
class_name EffectArea

extends Area3D

## Which effect to apply
@export var effect: TickEffect

@export var effect_range := 3.0
## the interval (in seconds) at which the effect is applied
@export var effect_interval := 0.5
@export var grows: bool = false
## only applicable if grows is true
@export var max_range := 5.0
@export var time_alive := 5.0

@onready var detector: TargetDetectorComponent = TargetDetectorComponent.Get(self)
@onready var mesh: MeshInstance3D = get_node("mesh")
@onready var particles: GPUParticles3D = get_node("particles")

var time_since_last_update := effect_interval
var alive_timer := 0.0

func _ready():
	mesh.mesh = mesh.mesh.duplicate()

func _process(delta:float) -> void:
	alive_timer += delta
	if alive_timer >= time_alive:
		queue_free()
		print("Effect area expired after " + str(alive_timer) + " seconds.")
		return

	time_since_last_update += delta

	if time_since_last_update >= effect_interval:
		time_since_last_update -= effect_interval
		_apply_burn_to_targets()

	if grows:
		do_grow(delta)

func _apply_burn_to_targets() -> void:
	var targets: Array[Node3D] = detector.find_all(["entity"], effect_range, false)
	for target in targets:
		#print("Applying effect to target: " + str(target))
		var entity: Entity = Entity.Get(target)
		entity.apply_effect(effect.duplicate())

func do_grow(delta: float) -> void:
	var new_range: float = lerp(effect_range, max_range, alive_timer / time_alive)
	update_range(new_range)

func update_range(new_range: float) -> void:
	var _mesh: CylinderMesh = mesh.mesh;
	_mesh.top_radius = new_range
	_mesh.bottom_radius = new_range
	particles.process_material.emission_ring_radius = new_range
