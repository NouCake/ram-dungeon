extends Control

@export var player_preset_scene: PackedScene

@onready var level_list: ItemList = find_child("LevelSelect")
@onready var player_preset_list: Control = find_child("AllPlayers")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir := DirAccess.open("res://scenes/sections")
	dir.list_dir_begin()
	level_list.clear()
	for file: String in dir.get_files():
		var resource := load(dir.get_current_dir() + "/" + file)
		level_list.add_item(file.replace(".remap", ""))
		
	find_child("StartButton").button_down.connect(_on_level_start_clicked)
	find_child("AddPlayer").button_down.connect(_on_player_add_clicked)


func _on_level_start_clicked() -> void:
	var selected_items: int = level_list.get_selected_items()[0]
	var item := level_list.get_item_text(selected_items)
	get_tree().change_scene_to_file("res://scenes/sections/" + item)

func _on_player_add_clicked() -> void:
	var instance = player_preset_scene.instantiate()
	player_preset_list.add_child(instance)
	player_preset_list.move_child(instance, player_preset_list.get_child_count() - 2)
	
