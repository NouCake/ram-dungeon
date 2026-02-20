@tool
class_name EncounterSection
extends Node3D

@onready var mesh_walls: GridMap = $grid_walls
@onready var mesh_floors: GridMap = $grid_floor

@export var length := 10
@export var width := 3

@export var encounter_trigger_line := 5
@export var pre_encounter_move_speed := 5.0
@export var show_encounter_party_grid := true

@onready var party_manager : PartyManager = get_node("party_manager")

var _entities: Array[Entity] = []
var _player: Array[Entity] = []
var _enemies: Array[Entity] = []

var _encounter_in_progress := false

const _TILE_SIZE := 4

func _ready() -> void:
	_rebuild_grid()
	
	for child in get_children():
		if child is Entity:
			var entity: Entity = child
			
			entity.health.died.connect(_on_entity_died)

			_entities.append(entity)
			entity.combat_disabled = true
			if entity._targetable.has_tag("player"):
				_player.append(entity)
			if entity._targetable.has_tag("enemy"):
				_enemies.append(entity)
	
	party_manager._rebuild_grid()
	
	var tween := get_tree().create_tween()
	var speed := encounter_trigger_line * _TILE_SIZE / pre_encounter_move_speed
	tween.tween_method(_update_tween_party_position_and_grid, 0.0, 1.0, speed)
	tween.tween_method(_update_tween, 0.0, 1.0, 1.0)
	tween.connect("finished", _on_pre_encounter_finished)

func _update_tween(_progress: float) -> void:
	pass

func _on_entity_died(entity: Entity) -> void:
	if entity in _enemies:
		_enemies.erase(entity)
	if entity in _player:
		_player.erase(entity)
	if entity in _entities:
		_entities.erase(entity)
	

func _update_tween_party_position_and_grid(progress: float) -> void:
	party_manager.global_position = global_position + Vector3.RIGHT * encounter_trigger_line * _TILE_SIZE * progress
	party_manager._rebuild_grid()

func _on_encounter_finished() -> void:
	_encounter_in_progress = false
	for entity in _entities:
		if is_instance_valid(entity):
			entity.combat_disabled = true

func _on_pre_encounter_finished() -> void:
	for entity in _entities:
		entity.reset_for_combat()

	_encounter_in_progress = true

func _process(_delta: float) -> void:
	_draw_debug()

	if !_encounter_in_progress:
		return
	
	if _enemies.size() == 0:
		print("Encounter cleared!")
		_on_encounter_finished()
	
	for player in _player:
		if !is_instance_valid(player):
			print("Player defeated: ", player.name)
			_player.remove_at(_player.find(player))

	if _player.size() == 0:
		print("Game Over!")
		_on_encounter_finished()

func _draw_debug() -> void:
	if !Engine.is_editor_hint():
		return
	
	DebugDraw3D.draw_text(global_position + Vector3.UP, "SECTION START", 100, Color.YELLOW)
	DebugDraw3D.draw_text(global_position + Vector3.RIGHT * length * _TILE_SIZE + Vector3.UP, "SECTION END", 100, Color.YELLOW)
	DebugDraw3D.draw_text(global_position + Vector3.RIGHT * encounter_trigger_line * _TILE_SIZE + Vector3.UP, "ENCOUNTER BEGIN", 100, Color.RED)

	DebugDraw3D.draw_line(
		global_position + Vector3.RIGHT * encounter_trigger_line * _TILE_SIZE + Vector3.FORWARD * width * _TILE_SIZE, 
		global_position + Vector3.RIGHT * encounter_trigger_line * _TILE_SIZE - Vector3.FORWARD * width * _TILE_SIZE,
		Color.RED)

	if show_encounter_party_grid:
		PartyManager.draw_grid_debug(global_position + Vector3.RIGHT * encounter_trigger_line * _TILE_SIZE, 5, 5)

@export_tool_button("Build Level") var rebuild_button := _rebuild_grid
func _rebuild_grid() -> void:
	mesh_floors.clear()
	for x in length + 4:
		for z in width * 2:
			mesh_floors.set_cell_item(Vector3i(x - 2, 0, z - width), 0)
	
	mesh_walls.clear()
	for x in length +4:
		mesh_walls.set_cell_item(Vector3i(x - 2, 0, -width), 2 if x % 3 == 0 else 1, 10)
		mesh_walls.set_cell_item(Vector3i(x - 2, 1, -width), 3, 8)
