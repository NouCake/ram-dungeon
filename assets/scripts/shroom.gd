extends Node3D

@export var grow_time := 3.0
@export var poison_interval := 1.0
@export var effect_scene: PackedScene
@export var time_alive := 5.0
@export var spawn_area_radius := 1.0

@onready var sprite: Sprite3D = get_node("sprite")

const GROW_FRAMES := 3
const FRAME_WIDTH := 128

var grow_timer := 0.0
var poison_timer := poison_interval
var alive_timer := 0.0

func _process(delta: float) -> void:
	alive_timer += delta
	
	if alive_timer >= time_alive:
		queue_free()
		return

	# update growth frame while growing; once growth is finished, keep the last frame
	if grow_timer <= grow_time:
		do_grow(delta)
	else:
		# ensure sprite stays on last growth frame after growth finishes
		sprite.region_rect.position = Vector2((GROW_FRAMES - 1) * FRAME_WIDTH, 0)
		do_poison(delta)

func do_grow(delta: float) -> void:
	grow_timer += delta
	# pick frame index in [0, GROW_FRAMES-1], clamp to avoid overshoot
	var t := int(clamp(floor(grow_timer / grow_time * GROW_FRAMES), 0, GROW_FRAMES - 1))
	sprite.region_rect.position = Vector2(t * FRAME_WIDTH, 0)

func do_poison(delta: float) -> void:
	poison_timer += delta
	if poison_timer >= poison_interval:
		poison_timer -= poison_interval
		spawn_effect()
	

func spawn_effect() -> void:
	var effect_instance: Node3D = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	var random_offset := random_point_in_circle(spawn_area_radius)
	effect_instance.global_position = global_position + random_offset
	effect_instance.global_position.y = 0

func random_point_in_circle(radius: float) -> Vector3:
	var angle := randf() * TAU
	var r := radius * sqrt(randf())
	return Vector3(r * cos(angle), 0, r * sin(angle))