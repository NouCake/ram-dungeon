class_name TargetFinderComponent

extends Area2D

static var component_name: String = "finder"

func _ready():
	assert(name == component_name, "Component must be named 'finder' to be recognized by other components.")

@export var filter: Array[String] = []

var search_interval: float = 0.1
var time_since_last_search: float = search_interval
var _current_target: Node2D = null

func _physics_process(delta):
	time_since_last_search += delta
	trigger_search()

func trigger_search():
	if time_since_last_search >= search_interval:
		time_since_last_search = 0.0
		_search_closest_target()

func get_target() -> Node2D:
	return _current_target

func _search_closest_target():
	# print("Searching for closest target...")
	var possible_targets: Array[Node2D] = _get_all_near_targets()
	
	var parent = get_parent()
	var min_distance = INF
	var min_distance_target: Node2D = null
	for target in possible_targets:
		if (target == parent):
			continue;

		var distance = (target.global_position - parent.global_position).length();
		if distance < min_distance:
			min_distance = distance
			min_distance_target = target
	
	_current_target = min_distance_target
	# print("Current target set to: " + str(_current_target))
	return min_distance_target

func _get_all_near_targets() -> Array[Node2D]:
	var overlapping: Array[Node2D] = [];
	
	for target in get_overlapping_areas():
		overlapping.append(target)
	
	for target in get_overlapping_bodies():
		overlapping.append(target)
		
	var found_targets: Array[Node2D] = [];
	
	# print("Found " + str(overlapping.size()) + " overlapping targets: " + str(overlapping))
	for target in overlapping:
		if (target == get_parent()):
			#print("Skipping self")
			continue;

		if !target.has_node("targetable"):
			#print("Target " + target.name + " has no Targetable component")
			continue;
			
		if filter.size() > 0 and !target.get_node("targetable").has_any_tag(filter):
			#print("Target " + target.name + " does not match filter tags")
			continue
			
		if !_is_in_line_of_sight(target):
			#print("Target " + target.name + " is not in line of sight")
			continue
		found_targets.append(target)
	
	return found_targets

func _is_in_line_of_sight(target: Node2D) -> bool:
	var ray_origin = get_parent().global_position;
	var ray_end = target.global_position;
	
	var query = PhysicsRayQueryParameters2D.create(ray_origin, ray_end)
	query.exclude = [self, target]
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if result:
		# print("Couldn't target at: " + target.name + " because " + result.collider.name + " was in the way")
		return false
	
	return true

