extends Label3D

func _enter_tree() -> void:
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 1, 0.75)
	tween.tween_property(self, "modulate:a", 0.0, 0.25).set_delay(0.5)
	tween.connect("finished", Callable(self, "queue_free"))