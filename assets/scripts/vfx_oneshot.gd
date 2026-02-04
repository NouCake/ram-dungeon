## VFX effect that automatically despawns after a set time or when particles finish
class_name VFXOneshot

extends Node3D

@export var lifetime := 1.0

func _ready() -> void:
	TimerUtil.delay(self, lifetime, queue_free)