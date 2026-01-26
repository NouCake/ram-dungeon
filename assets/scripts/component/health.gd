class_name HealthComponent

extends Node

@export var current_health := 5
@export var max_health := 5
@export var auto_delete := true

signal was_hit(hit_source: Node2D)
signal health_changed

static var component_name: String = "health"

func _ready():
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")

func do_damage(amount: int, damage_source: Node2D):
	print(get_parent().name + " was hit")
	current_health -= amount
	
	if auto_delete && current_health <= 0:
		get_parent().queue_free()
	
	was_hit.emit(damage_source)
	health_changed.emit()
