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
	mesh.set_instance_shader_parameter("fade", 0.0)

func _process(delta:float) -> void:
	alive_timer += delta
	if alive_timer >= time_alive:
		queue_free()
		return

	time_since_last_update += delta

	if time_since_last_update >= effect_interval:
		time_since_last_update -= effect_interval
		_apply_burn_to_targets()

	if grows:
		do_grow()

func _apply_burn_to_targets() -> void:
	var range: float
	if grows:
		range = lerp(effect_range, max_range, alive_timer / time_alive)
	else:
		range = effect_range
	var targets: Array[Node3D] = detector.find_all(["entity"], range, false)
	for target in targets:
		#print("Applying effect to target: " + str(target))
		var entity: Entity = Entity.Get(target)
		entity.apply_effect(effect.duplicate() as TickEffect)

func do_grow() -> void:
	var new_range: float = lerp(effect_range, max_range, alive_timer / time_alive)
	update_range(new_range)

func update_range(new_range: float) -> void:
	(particles.process_material as ParticleProcessMaterial).emission_ring_radius = new_range
	mesh.scale = Vector3.ONE * new_range / effect_range
	var t: float
	if alive_timer < time_alive * 0.1:
		# First 10%: fade in from 0 to 1
		t = alive_timer / (time_alive * 0.1)
	elif alive_timer > time_alive * 0.75:
		# Last 25%: fade out from 1 to 0
		t = 1.0 - (alive_timer - time_alive * 0.75) / (time_alive * 0.25)
	else:
		# Middle 65%: stay at 1
		t = 1.0
	mesh.set_instance_shader_parameter("fade", t)
