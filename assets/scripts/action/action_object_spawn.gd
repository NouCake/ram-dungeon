class_name ActionObjectSpawn
extends BaseActionTargeting

@export var to_spawn: PackedScene
@export var spawn_radius: float = 1.0

func perform_action() -> bool:
	return _spawn_object()

func _spawn_object() -> bool:
	var target: Entity = detector.find_closest(target_filters, action_range, false)
	if !target:
		return false
	
	var spawned: Node3D = to_spawn.instantiate()
	get_tree().get_current_scene().add_child(spawned)

	var random_position := random_point_in_circle(spawn_radius)
	spawned.global_position = target.global_position + random_position
	spawned.global_position.y = 0
	return true
	
func random_point_in_circle(radius: float) -> Vector3:
	var angle := randf() * TAU
	var r := radius * sqrt(randf())
	return Vector3(r * cos(angle), 0, r * sin(angle))