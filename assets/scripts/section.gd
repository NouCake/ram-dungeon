@tool
class_name EncounterSection
extends Node3D

@onready var mesh_walls: GridMap = $grid_walls
@onready var mesh_floors: GridMap = $grid_floor

@export var length := 10
@export var width := 3

@export var encounter_trigger_line := 5
@export var show_encounter_party_grid := true

var _pre_encounter := true
var _entities : Array[Entity] = []

const _TILE_SIZE := 4

func _ready() -> void:
	_rebuild_grid()
	
	for child in get_children():
		if child is Entity:
			_entities.append(child)

func _process(_delta: float) -> void:
	_draw_debug()



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
