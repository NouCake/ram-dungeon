## VFX effect that automatically despawns after a set time or when particles finish
class_name VFXOneshot

extends Node3D

@export var lifetime := 1.0

var timer := 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= lifetime:
		queue_free()