extends Node3D

@export var grow_time := 3.0
@export var poison_interval := 1.0
@export var effect_scene: PackedScene
@export var time_alive := 5.0
@export var spawn_area_radius := 1.0

var poison_timer := 0.0
var alive_timer := 0.0

@onready var sprite: AnimatedSprite3D = get_node("sprite")

func _ready() -> void:
	sprite.play("default")
	sprite.speed_scale = 3 / grow_time

func _process(delta: float) -> void:
	if alive_timer > grow_time:
		do_poison(delta)

	alive_timer += delta
	
	if alive_timer >= time_alive:
		queue_free()
		return


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