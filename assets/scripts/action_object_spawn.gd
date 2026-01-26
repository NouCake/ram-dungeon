extends Node

@export var to_spawn: PackedScene
@export var target_range: float = 5.0
@export var cooldown: float = 2.0
@export var spawn_radius: float = 1.0

var time_since_last_spawn: float = cooldown
@onready var detector: TargetDetectorComponent = get_node("../detector")

func _process(delta) -> void:
	if time_since_last_spawn >= cooldown:
		if _spawn_object():
			time_since_last_spawn -= cooldown
	else:
		time_since_last_spawn += delta

func _spawn_object() -> bool:
	var target: Entity = detector.find_closest(["enemy"], target_range, false)
	if !target:
		return false
	
	var spawned: Node3D = to_spawn.instantiate()
	get_tree().get_current_scene().add_child(spawned)

	var random_position = Vector3(
		randf_range(-spawn_radius, spawn_radius),
		0,
		randf_range(-spawn_radius, spawn_radius)
	)

	for i in range(10):
		if random_position.length() <= spawn_radius:
			break
		random_position = Vector3(
			randf_range(-spawn_radius, spawn_radius),
			0,
			randf_range(-spawn_radius, spawn_radius)
		)
	spawned.global_position = target.global_position + random_position
	spawned.global_position.y = 0
	return true
	
