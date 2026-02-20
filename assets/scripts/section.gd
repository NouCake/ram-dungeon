@tool
extends Node3D

@onready var mesh_walls: GridMap = $grid_walls
@onready var mesh_floors: GridMap = $grid_floor

@export var length := 10
@export var width := 3

func _ready():
	_rebuild_grid()

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
