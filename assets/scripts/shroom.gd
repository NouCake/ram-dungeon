extends Node3D

@export var grow_time := 3.0
@export var poison_interval := 1.0
@export var effect_scene: PackedScene
@export var time_alive := 5.0

@onready var sprite: Sprite3D = get_node("sprite")


var grow_timer := 0.0
var poison_timer := poison_interval
var alive_timer := 0.0

func _process(delta: float) -> void:
	alive_timer += delta
	
	if alive_timer >= time_alive:
		queue_free()
		return

	if grow_timer < grow_time:
		do_grow(delta)
	else:
		do_poison(delta)

func do_grow(delta: float) -> void:
	grow_timer += delta
	var t: float = floor(grow_timer / grow_time * 3)
	sprite.region_rect.position = Vector2(t * 128, 0)

func do_poison(delta: float) -> void:
	poison_timer += delta
	if poison_timer >= poison_interval:
		poison_timer -= poison_interval
		spawn_effect()
	

func spawn_effect() -> void:
	var effect_instance: Node3D = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect_instance)
	effect_instance.global_position = global_position
	effect_instance.global_position.y = 0