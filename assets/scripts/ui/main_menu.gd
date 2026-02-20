extends Control

@onready var item_list: ItemList = $MLevelselect/HBoxContainer/VBoxContainer/MarginContainer/ItemList

func _ready() -> void:
	var dir := DirAccess.open("res://scenes/sections")
	dir.list_dir_begin()

	$MM/Center/VBoxContainer2/Start.button_down.connect(_on_start_button_down)
	$MLevelselect/HBoxContainer/VBoxContainer3/MarginContainer/Button.button_down.connect(_on_level_start_clicked)

	item_list.clear()
	for file: String in dir.get_files():
		var resource := load(dir.get_current_dir() + "/" + file)
		item_list.add_item(file)

	pass


func _process(delta: float) -> void:
	pass


func _on_start_button_down() -> void:
	$MM.hide()
	$MLevelselect.show()


func _on_level_start_clicked() -> void:
	var selected_items: int = item_list.get_selected_items()[0]
	var item := item_list.get_item_text(selected_items)
	get_tree().change_scene_to_file("res://scenes/sections/" + item)