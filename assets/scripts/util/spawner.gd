extends Node2D

@export var to_spawn: PackedScene
@export var spawn_rate := 10 # Time between spawns
@export var spawn_area_width: int = 100
@export var spawn_area_height: int = 250

var _spawn_timer: Timer

func _ready() -> void:
	_spawn_timer = TimerUtil.repeat(self, spawn_rate, spawn)
		
func spawn() -> void:
	var instance: Node2D = to_spawn.instantiate()
	instance.global_position = global_position + get_random_position()
	get_tree().get_current_scene().add_child(instance)
	
func get_random_position() -> Vector2:
	var random_x := spawn_area_width * randf()
	var random_y := spawn_area_height * randf()
	
	return Vector2(random_x - spawn_area_width *0.5, random_y - spawn_area_height * 0.5)
