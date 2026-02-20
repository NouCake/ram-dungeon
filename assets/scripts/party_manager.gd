@tool
extends Node3D

@export var grid_x := 3;
@export var grid_y := 3;
@export var grid_gap := 0.5;
@export var grid_size := 1.0;

@export var cells: Array[GridCell] = []

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		return

	for x in range(grid_x):
		for y in range(grid_y):
			var pos := _get_position_for_grid(x, y)
			var color := Color.TURQUOISE

			DebugDraw3D.draw_box(pos, Quaternion.IDENTITY, Vector3(1.0, 0.01, 1.0), color, true)

func _get_position_for_grid(x: int, y: int) -> Vector3:
	var total_width := grid_x * grid_size + (grid_x - 1) * grid_gap
	var total_height := grid_y * grid_size + (grid_y - 1) * grid_gap
	var offset := Vector3(x * (grid_size + grid_gap), 0.0, y * (grid_size + grid_gap))
	offset -= Vector3(total_width, 0.0, total_height) * 0.5 - Vector3(grid_size, 0.0, grid_size) * 0.5
	return global_transform.origin + offset

@export_tool_button("Rebuild Grid") var rebuild_button := _rebuild_grid

func _rebuild_grid() -> void:
	for cell in cells:
		if cell.entity != NodePath():
			var node: Node3D = get_node_or_null(cell.entity)
			node.global_position = _get_position_for_grid(cell.grid_x, cell.grid_y)