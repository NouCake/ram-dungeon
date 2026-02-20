class_name TargetDetectorComponent

extends Area3D

static var component_name: String = "detector"
static func Is(node: Node) -> bool:
	assert(node != null, "Cannot check TargetDetectorComponent on a null node.")
	
	if node.has_node(component_name):
		assert(node.get_node(component_name) is TargetDetectorComponent, "Node has a "+component_name+" component but it's type is wrong.")
		return true
	push_error("Node " + node.name + " does not have a TargetDetectorComponent.")
	return false
static func Get(node: Node) -> TargetDetectorComponent:
	if Is(node):
		return node.get_node(component_name)
	return null

@export var search_interval := 0.25

var time_since_last_search: float = search_interval
var _overlapping_nodes: Array[Node3D] = []

var _area_range: float = 0.0

func _ready() -> void:
	assert(name == component_name, "Component must be named "+component_name+" to be recognized by other components.")
	var area := $range as CollisionShape3D
	if area.shape is SphereShape3D:
		_area_range = (area.shape as SphereShape3D).radius

func _physics_process(delta: float) -> void:
	time_since_last_search += delta
	_trigger_search()

func _trigger_search() -> void:
	if time_since_last_search >= search_interval:
		time_since_last_search = 0.0
		_overlapping_nodes = _get_all_near_targets()

func _get_all_near_targets() -> Array[Node3D]:
	var overlapping: Array[Node3D] = [];
	
	# Shouldn't be necessary to check areas since targets are bodies
	for target in get_overlapping_areas():
		overlapping.append(target)
	
	for target in get_overlapping_bodies():
		overlapping.append(target)
		
	var found_targets: Array[Node3D] = [];
	
	for target in overlapping:
		if !Targetable.Is(target):
			continue;

		found_targets.append(target)
	
	return found_targets

func _is_in_line_of_sight(target: Node3D) -> bool:
	var ray_origin := (get_parent() as Node3D).global_position;
	var ray_end := target.global_position;
	
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [get_parent(), target]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	
	if result:
		return false
	
	return true

## Find all targetables within max_distance that match any of the filter_tags and (optionally) line of sight
func find_all(filter_tags: Array[String], max_distance: float, line_of_sight: bool, can_target_self: bool = false) -> Array[Node3D]:
	assert(max_distance <= _area_range, "Requested max_distance " + str(max_distance) + " exceeds detector range " + str(_area_range))

	var possible_targets: Array[Node3D] = []
	for node in _overlapping_nodes:
		if !is_instance_valid(node):
			continue

		if can_target_self == false and node == get_parent():
			continue
			
		var targetable := Targetable.Get(node)
		if filter_tags.size() > 0 and !targetable.has_any_tag(filter_tags):
			continue

		var parent: Node3D = get_parent()
		if max_distance >= 0.001:
			var distance := (node.global_position - parent.global_position).length()
			if distance > max_distance:
				continue
			
		if line_of_sight and !_is_in_line_of_sight(node):
			continue
		
		possible_targets.append(node)
	return possible_targets;


# TODO: Remove
func find_closest(filter_tags: Array[String], max_distance: float, line_of_sight: bool) -> Node3D:
	var possible_targets := find_all(filter_tags, max_distance, line_of_sight)

	var parent: Node3D = get_parent();
	return possible_targets.reduce(func(target: Node3D, acc: Node3D) -> Node3D:
		if (acc == null):
			return target
		var target_distance := (target.global_position - parent.global_position).length()
		var acc_distance := (acc.global_position - parent.global_position).length()
		if target_distance < acc_distance:
			return target
		return acc, null)
