extends Node3D

@export var grow_time := 3.0
@export var poison_interval := 1.0
@export var effect_scene: PackedScene
@export var time_alive := 5.0
@export var spawn_area_radius := 1.0

@onready var sprite: AnimatedSprite3D = get_node("sprite")

func _ready() -> void:
	sprite.play("default")
	sprite.speed_scale = 3 / grow_time
	_schedule_lifecycle()

func _schedule_lifecycle() -> void:
	# Wait for grow phase before starting poison spawning
	await get_tree().create_timer(grow_time).timeout
	_start_poison_spawning()
	
	# Auto-destroy after total lifetime
	await get_tree().create_timer(time_alive - grow_time).timeout
	queue_free()

func _start_poison_spawning() -> void:
	while true:
		spawn_effect()
		await get_tree().create_timer(poison_interval).timeout

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