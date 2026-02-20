@tool
class_name PartyManager
extends Node3D

@export var grid_length := 3;
@export var grid_width := 3;
@export var grid_gap := 0.5;
@export var grid_size := 1.0;

@export var cells: Array[GridCell] = []

@export var show_encounter_poisitions := true

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		return

	for x in range(grid_length):
		for y in range(grid_width):
			var pos := global_position + get_offset_for_grid(x, y, grid_width, grid_length, grid_gap, grid_size)
			var color := Color.TURQUOISE

			DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, Vector3(1.0, 0.01, 1.0), color, true)

static func get_offset_for_grid(x: int, y: int, _grid_width: int, _grid_length: int, _grid_gap: float, _grid_size: float) -> Vector3:
	var total_width := _grid_width * _grid_size + (_grid_length - 1) * _grid_gap
	var total_height := _grid_width * _grid_size + (_grid_width - 1) * _grid_gap
	var offset := Vector3(x * (_grid_size + _grid_gap), 0.0, y * (_grid_size + _grid_gap))
	offset -= Vector3(total_width, 0.0, total_height * 0.5) - Vector3(_grid_size, 0.0, _grid_size * 0.5)
	return offset

@export_tool_button("Rebuild Grid") var rebuild_button := _rebuild_grid

func _rebuild_grid() -> void:
	for cell in cells:
		if cell.entity != NodePath():
			var node: Node3D = get_node_or_null(cell.entity)
			node.global_position = global_position + get_offset_for_grid(cell.grid_x, cell.grid_y, grid_width, grid_length, grid_gap, grid_size)


static func draw_grid_debug(_position: Vector3, length: int, width: int) -> void:
	for x in range(width):
		for y in range(length):
			var pos := _position + get_offset_for_grid(x, y, width, length, 0.25, 1.0)
			var color := Color.TURQUOISE

			DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, Vector3(1.0, 0.01, 1.0), color, true)