extends Control


func _ready() -> void:
	$MM.find_child("Start").button_down.connect(_on_start_button_down)

func _on_start_button_down() -> void:
	$MM.hide()
	$MLevelselect.show()
