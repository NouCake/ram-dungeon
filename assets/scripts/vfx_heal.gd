extends Node3D

func _ready() -> void:
	
	TimerUtil.delay(self, 1.5, queue_free)
	var ring := get_node("ring") as Node3D;
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector3.ONE * 1.0, .5).from(Vector3.ZERO)
	tween.tween_method(func(progress: float) -> void: ring.rotation.z = progress * 2.0 * PI, .0, .4, 1.3)
	tween.chain().tween_property(ring, "scale", Vector3.ZERO, .2).from(Vector3.ONE * 1.0)
