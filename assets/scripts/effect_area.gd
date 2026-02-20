## Applied effect to all entities within a certain range at regular intervals.
class_name EffectArea

extends Area3D

## Which effect to apply
@export var effect: Effect

## Optional source entity (for damage/heal attribution, e.g., effect.origin)
var source_entity: Entity = null

@export var target_filters: Array[String] = ["entity"]

@export var effect_range := 3.0
## the interval (in seconds) at which the effect is applied
@export var effect_interval := 0.5
@export var grows: bool = false
## only applicable if grows is true
@export var max_range := 5.0
@export var time_alive := 5.0

@onready var detector: TargetDetectorComponent = TargetDetectorComponent.Get(self)
@onready var mesh: MeshInstance3D = get_node("mesh")
var particles: GPUParticles3D

var current_range := effect_range

func _ready() -> void:
	mesh.set_instance_shader_parameter("fade", 0.0)
	_schedule_lifecycle()
	effect.source = source_entity
	if has_node("particles"):
		particles = get_node("particles") as GPUParticles3D
	_update_range(effect_range)

func _schedule_lifecycle() -> void:
	if grows:
		_setup_grow_tween()
	
	_setup_fade_tween()
	
	TimerUtil.repeat(self, effect_interval, _apply_effect_to_targets)
	TimerUtil.delay(self, time_alive, queue_free)

func _setup_grow_tween() -> void:
	var tween := create_tween()
	tween.tween_method(_update_range, effect_range, max_range, time_alive)

func _setup_fade_tween() -> void:
	var fade_in_duration: float = min(0.5, time_alive * 0.25)
	var fade_out_start := time_alive * 0.75
	var fade_out_duration: float = min(0.5, time_alive * 0.25)
	
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
	## @futureme Not all effect areas use particles, so this should be more generic
	if particles:
		(particles.process_material as ParticleProcessMaterial).emission_ring_radius = new_range
	mesh.scale = Vector3.ONE * new_range * 2

func _apply_effect_to_targets() -> void:
	var targets: Array[Node3D] = detector.find_all(target_filters, current_range, false)
	for target in targets:
		var entity: Entity = Entity.Get(target) ## only applicable because filter is "entity"
		entity.apply_effect(effect)
