class_name LineRenderer
extends Node3D

## A 3D line renderer that creates a ribbon/trail mesh from a series of points.
## The line can be aligned to the camera view, transform axes, or custom vectors.

## How the line ribbon is oriented in 3D space
enum Alignment { 
	View,        # Billboard - always faces the camera
	TransformX,  # Aligned to the X axis of this node's transform
	TransformY,  # Aligned to the Y axis of this node's transform
	TransformZ,  # Aligned to the Z axis of this node's transform
	Static       # Uses custom alignment vector per point
}

## How UV coordinates are mapped along the line
enum TextureMode { 
	Stretch,    # Stretch texture across entire line (0 to 1)
	Tile,       # Tile based on world distance between points
	PerSegment  # Use point index as UV coordinate
}

# === LINE SHAPE ===
## Controls the width of the line along its length (0.0 to 1.0)
@export var curve: Curve

## How the line ribbon is oriented in space
@export var alignment: Alignment = Alignment.TransformZ

## Base width of the line
@export var line_width: float = 0.5

# === APPEARANCE ===
@export_group("Appearance")

## Material applied to the line mesh
@export var material: Material:
	get:
		return material
	set(value):
		material = value
		if _mesh_instance != null:
			_mesh_instance.material_override = material

## Color gradient applied along the line (from start to end)
@export var color_gradient: Gradient

## How textures are mapped along the line
@export var texture_mode: TextureMode

# === RUNTIME DATA ===
## Array of Point objects that define the line's path
var points: Array = []

# === INTERNAL MESH COMPONENTS ===
var _mesh: ImmediateMesh = ImmediateMesh.new()
var _mesh_instance: MeshInstance3D
var _camera: Camera3D


func _enter_tree() -> void:
	# Initialize default gradient if none is set
	if color_gradient == null:
		color_gradient = Gradient.new()
		color_gradient.add_point(0.0, Color(1.0, 1.0, 1.0))  # Start: white
		color_gradient.add_point(1.0, Color(1.0, 1.0, 1.0))  # End: white

	# Initialize default width curve if none is set
	if curve == null:
		curve = Curve.new()
		# Create a flat curve at 0.5 width (constant width)
		curve.add_point(Vector2(0.0, 0.5), 0.0, 0.0, Curve.TANGENT_FREE, Curve.TANGENT_LINEAR)
		curve.add_point(Vector2(1.0, 0.5), 0.0, 0.0, Curve.TANGENT_LINEAR)

	# Create the mesh instance that will render the line
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "MeshInstance3D"
	add_child(_mesh_instance)

	_mesh_instance.mesh = _mesh
	_mesh_instance.material_override = material
	_mesh_instance.top_level = true  # Ignore parent transforms


func _process(_delta: float) -> void:
	# Get the active camera for billboard alignment
	
	# Position mesh in world space or follow this node's transform
	_mesh_instance.global_transform = Transform3D.IDENTITY

	# Rebuild the mesh from scratch each frame
	_mesh.clear_surfaces()
	
	# Need at least 2 points to draw a line
	if points.size() < 2:
		return

	# Start building a triangle strip mesh
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	# Process each point to create the line ribbon
	for i: int in range(points.size()):
		var current_point: Point = points[i]

		# Calculate the forward direction (tangent) at this point
		var tangent: Vector3 = _calculate_tangent(i, current_point)

		# Get the vector the ribbon should align to (perpendicular to tangent)
		var alignment_vec: Vector3 = _get_alignment_vector(current_point)

		# Calculate the ribbon's local coordinate system
		# bitangent = width direction (across the ribbon)
		# normal = up direction (perpendicular to ribbon surface)
		var bitangent: Vector3 = alignment_vec.cross(tangent).normalized()
		var normal: Vector3 = tangent.cross(bitangent).normalized()

		# Calculate position along the line (0.0 to 1.0)
		var t: float = i / (points.size() - 1.0)
		
		# Sample color at this position
		var color: Color = color_gradient.sample(t)
		
		# Apply width curve and scale the bitangent
		bitangent *= curve.sample(t) * line_width * 0.5

		# Calculate UV coordinate based on texture mode
		_update_texture_offset(i, current_point)

		# Add two vertices (left and right side of the ribbon)
		# This creates a triangle strip that forms the ribbon mesh
		
		# Left vertex
		_mesh.surface_set_uv(Vector2(0, 1 - current_point.texture_offset))
		_mesh.surface_set_normal(normal)
		_mesh.surface_set_color(color)
		_mesh.surface_add_vertex(current_point.position - bitangent)

		# Right vertex
		_mesh.surface_set_uv(Vector2(1, 1 - current_point.texture_offset))
		_mesh.surface_set_normal(normal)
		_mesh.surface_set_color(color)
		_mesh.surface_add_vertex(current_point.position + bitangent)

	_mesh.surface_end()


## Calculate the forward direction (tangent) at a given point index
func _calculate_tangent(point_index: int, current_point: Point) -> Vector3:
	if point_index == 0:
		# First point: look toward the next point
		var next_point: Point = points[1]
		return current_point.position.direction_to(next_point.position)
	else:
		# Other points: look away from the previous point
		var previous_point: Point = points[point_index - 1]
		return -current_point.position.direction_to(previous_point.position)


## Get the alignment vector based on the current alignment mode
func _get_alignment_vector(current_point: Point) -> Vector3:
	var alignment_vec: Vector3
	
	# Handle special cases for world space alignment
	if alignment == Alignment.View:
		_camera = get_viewport().get_camera_3d()
		alignment_vec = _camera.global_basis.z.normalized()
	elif alignment == Alignment.TransformX:
		alignment_vec = global_basis.x.normalized()
	elif alignment == Alignment.TransformY:
		alignment_vec = global_basis.y.normalized()
	elif alignment == Alignment.TransformZ:
		alignment_vec = global_basis.z.normalized()
	else:
		# Handle remaining alignment modes
		match alignment:
			Alignment.TransformX:
				alignment_vec = global_basis.x.normalized()
			Alignment.TransformY:
				alignment_vec = global_basis.y.normalized()
			Alignment.Static:
				alignment_vec = current_point.alignment_vector.normalized()
	
	return alignment_vec


## Update the texture offset for a point based on the texture mode
func _update_texture_offset(point_index: int, current_point: Point) -> void:
	match texture_mode:
		TextureMode.Stretch:
			# UV goes from 0 to 1 along the entire line
			current_point.texture_offset = point_index / (points.size() - 1.0)
			
		TextureMode.Tile:
			# UV based on cumulative distance (tiles texture by world units)
			if point_index > 0:
				var previous: Point = points[point_index - 1]
				current_point.texture_offset = (
					current_point.position.distance_to(previous.position)
					+ previous.texture_offset
				)
				
		TextureMode.PerSegment:
			# UV is the point index (useful for discrete segments)
			current_point.texture_offset = point_index


## Copy all settings from another LineRenderer
func copy_values(lr: LineRenderer) -> void:
	curve = lr.curve
	alignment = lr.alignment
	material = lr.material
	color_gradient = lr.color_gradient
	texture_mode = lr.texture_mode
	line_width = lr.line_width


## Get a specific point by its index in the points array
func get_point(index: int) -> Point:
	return points[index]
