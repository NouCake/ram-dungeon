extends Control

func _ready():
	var tween = get_tree().create_tween()
	tween.set_loops(0)  # Infinite loops
	tween.tween_property($bottom/start, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_property($bottom/start, "modulate", Color(1, 1, 1, 1), 1.0)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		$bottom/start.hide()
		var tween = get_tree().create_tween()
		tween.tween_method(func(value):
			$blur_layer.material.set_shader_parameter("lod", value)
		, 0.0, 1.5, 0.5)
