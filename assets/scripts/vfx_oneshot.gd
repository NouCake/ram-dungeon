## VFX effect that automatically despawns after a set time or when particles finish
class_name VFXOneshot

extends Node3D

@export var lifetime := 1.0

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()