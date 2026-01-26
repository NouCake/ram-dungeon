class_name Spawner

extends Node2D

@export var to_spawn: PackedScene
@export var spawn_rate = 10 # Time between spawns
@export var spawn_area_width: int = 100
@export var spawn_area_height: int = 250

var time_since_last_spawn = spawn_rate

func _process(delta: float) -> void:
	time_since_last_spawn += delta
	
	if time_since_last_spawn > spawn_rate:
		spawn()
		time_since_last_spawn = 0
		
func spawn():
	print("Spawning Enemy")
	var instance: Node2D = to_spawn.instantiate()
	instance.global_position = global_position + get_random_position()
	get_tree().get_current_scene().add_child(instance)
	pass
	
func get_random_position() -> Vector2:
	var random_x = spawn_area_width * randf()
	var random_y = spawn_area_height * randf()
	
	return Vector2(random_x - spawn_area_width *0.5, random_y - spawn_area_height * 0.5)
