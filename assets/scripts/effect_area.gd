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
var current_range := effect_range

func _ready():
	mesh.set_instance_shader_parameter("fade", 0.0)
	
	# Use tween for grow animation
	if grows:
		_setup_grow_tween()
	
	# Use tween for fade in/out
	_setup_fade_tween()
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(time_alive).timeout
	queue_free()

func _setup_grow_tween() -> void:
	var tween := create_tween()
	tween.tween_method(_update_range, effect_range, max_range, time_alive)

func _setup_fade_tween() -> void:
	var fade_in_duration := time_alive * 0.1
	var fade_out_start := time_alive * 0.75
	var fade_out_duration := time_alive * 0.25
	
	var tween := create_tween()
	# Fade in (0 to 1)
	tween.tween_method(_set_fade, 0.0, 1.0, fade_in_duration)
	# Hold at 1
	tween.tween_interval(fade_out_start - fade_in_duration)
	# Fade out (1 to 0)
	tween.tween_method(_set_fade, 1.0, 0.0, fade_out_duration)

func _set_fade(value: float) -> void:
	mesh.set_instance_shader_parameter("fade", value)

func _update_range(new_range: float) -> void:
	current_range = new_range
	(particles.process_material as ParticleProcessMaterial).emission_ring_radius = new_range
	mesh.scale = Vector3.ONE * new_range / effect_range

func _process(delta:float) -> void:
	time_since_last_update += delta

	if time_since_last_update >= effect_interval:
		time_since_last_update -= effect_interval
		_apply_effect_to_targets()

func _apply_effect_to_targets() -> void:
	var targets: Array[Node3D] = detector.find_all(["entity"], current_range, false)
	for target in targets:
		var entity: Entity = Entity.Get(target)
		entity.apply_effect(effect.duplicate() as TickEffect)
