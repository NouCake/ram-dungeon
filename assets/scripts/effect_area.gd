## Applied effect to all entities within a certain range at regular intervals.
## Mesh should be setup with circle with radius 1
@tool
class_name EffectArea

extends Node3D

## Which effect to apply
@export var effect: Effect
## Which targets to apply the effect to
@export var target_filters: Array[String] = ["entity"]
## Range when area is spawned.
@export var start_range := 3.0
## Range at end of lifecycle.
@export var end_range := 3.0
## How often to apply the effect to targets within range.
@export var effect_apply_frequency := 0.5
## Lifetime of the area in seconds.
@export var time_alive := 5.0

@onready var detector: TargetDetectorComponent = TargetDetectorComponent.Get(self)

var mesh: MeshInstance3D
var particles: GPUParticles3D

var source_entity: Entity = null
var _current_range: float = start_range

func _ready() -> void:	
	if has_node("mesh"):
		mesh = get_node("mesh") as MeshInstance3D

	if has_node("particles"):
		particles = get_node("particles") as GPUParticles3D
	
	if Engine.is_editor_hint():
		return

	if mesh:
		mesh.set_instance_shader_parameter("fade", 0.0)

	_schedule_lifecycle()
	effect.source = source_entity

func _schedule_lifecycle() -> void:
	if start_range != end_range:
		_setup_grow_tween()
	
	if mesh:
		_setup_fade_tween()
	
	TimerUtil.repeat(self, effect_apply_frequency, _apply_effect_to_targets)
	TimerUtil.delay(self, time_alive, queue_free)

func _setup_grow_tween() -> void:
	var tween := create_tween()
	tween.tween_method(_update_range, start_range, end_range, time_alive)

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
	_current_range = new_range

	if mesh:
		mesh.scale = Vector3(new_range, 1.0, new_range)
	if particles:
		(particles.process_material as ParticleProcessMaterial).emission_ring_radius = new_range


func _apply_effect_to_targets() -> void:
	var targets: Array[Node3D] = detector.find_all(target_filters, _current_range, false)
	for target in targets:
		var entity: Entity = Entity.Get(target) ## only applicable because filter is "entity"
		entity.apply_effect(effect)

@export_tool_button("Update Size") var update_button := _update_editor
func _update_editor() -> void:
	_update_range(start_range)