extends Control

@export var player_preset_scene: PackedScene
@export var base_player_scene: PackedScene

@onready var level_list: ItemList = find_child("LevelSelect")
@onready var player_preset_list: Control = find_child("AllPlayers")

@onready var custom_party_container: Control = find_child("CustomPartyContainer")
@onready var custom_party_checkbox: CheckBox = find_child("CheckBoxCustomParty")

var _actions: Array[String] = []
var _layout: Array[Vector2i] = []

const SECTION_FOLDER := "res://scenes/sections"
const ACTION_FOLDER := "res://assets/entities/actions"

func _ready() -> void:
	
	level_list.clear()
	for section_file in _get_files_in_dir(SECTION_FOLDER):
		level_list.add_item(section_file)
	level_list.select(0, true)
		
	_actions = _get_files_in_dir(ACTION_FOLDER)
		
	find_child("StartButton").button_down.connect(_on_level_start_clicked)
	find_child("AddPlayer").button_down.connect(_add_player)
	
	for child in player_preset_list.get_children():
		child.free()
	
	_add_player()
	_init_layout_grid()
	
	custom_party_container.visible = false
	custom_party_checkbox.toggled.connect(_on_custom_party_toggle)
	
func _on_custom_party_toggle(toggle: bool):
	custom_party_container.visible = toggle
	
func _init_layout_grid():
	var grid: GridContainer = find_child("PartyLayoutGrid")
	
	for i: int in range(grid.get_child_count()):
		var button: Button = grid.get_child(i)
		button.button_down.connect(_on_party_layout_button_click.bind(button, i))
		
func _on_party_layout_button_click(button: Button, index: int):
	if _layout.size() == player_preset_list.get_child_count():
		_layout.clear()
		
		var grid: GridContainer = find_child("PartyLayoutGrid")
		for i: int in range(grid.get_child_count()):
			var btn: Button = grid.get_child(i)
			btn.text = ""
		return
	
	if button.text != "":
		return
	
	var x: int = index % 5
	var y: int = floor(index / 5)
	
	_layout.append(Vector2i(x, y))
	button.text = str(_layout.size())

func _get_files_in_dir(path: String) -> Array[String]:
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	var files: Array[String] = []
	for file in dir.get_files():
		files.append(file.replace(".remap", ""))
	return files

func _on_level_start_clicked() -> void:
	var selected_scene_file_name := level_list.get_item_text(level_list.get_selected_items()[0])
	var scene_resource: PackedScene = load(SECTION_FOLDER + "/" + selected_scene_file_name)
	
	var instance = scene_resource.instantiate()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(instance)
	get_tree().current_scene = instance
	
	if custom_party_checkbox.button_pressed:
		for child in instance.get_children():
			if child is Entity:
				var entity: Entity = child
				if Targetable.Get(entity).has_tag("player"):
					entity.free()
		
		var party_manager: PartyManager = instance.get_node("party_manager")
		party_manager.cells.clear()
		
		for preset_index in range(player_preset_list.get_child_count()):
			var preset = player_preset_list.get_child(preset_index)
			var player = base_player_scene.instantiate()
			var action_list: ItemList = preset.find_child("SpellList")
			for selected_action_index in action_list.get_selected_items():
				var action_file_name = action_list.get_item_text(selected_action_index)
				var action_resource: PackedScene = load(ACTION_FOLDER + "/" + action_file_name)
				player.add_child(action_resource.instantiate())
			instance.add_child(player)
			
			var cell := GridCell.new()
			cell.grid_x = _layout.get(preset_index).x
			cell.grid_y = _layout.get(preset_index).y
			cell.entity = player.get_path()
			
			party_manager.cells.append(cell)
	(instance as EncounterSection).init_scene.call_deferred()
	

func _add_player():
	var instance = player_preset_scene.instantiate()
	
	var label: Label = instance.find_child("Title")
	label.text = "Player " + str(player_preset_list.get_child_count() + 1)
	
	var spell_list: ItemList = instance.find_child("SpellList")
	spell_list.clear()
	for action: String in _actions:
		spell_list.add_item(action)
		
	player_preset_list.add_child(instance)
	

	
	
