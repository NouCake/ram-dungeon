class_name Moving

extends Node

@export var prefered_target_distance = 100
@export var move_speed = 35
@export var move_back = false

var finder: TargetFinderComponent;

func _ready() -> void:
	finder = get_parent().get_node("finder");

func _process(delta: float) -> void:
	var target = finder.get_target()
	if target == null:
		return
	
	var parent: Node2D = get_parent()
	var dist = target.global_position - parent.global_position;
	
	var preffered_position: Vector2;
	if !move_back:
		var distance_to_target = dist.length();
		if distance_to_target <= prefered_target_distance:
			return
		preffered_position = target.global_position
	else:
		preffered_position = target.global_position - dist.normalized() * prefered_target_distance
	parent.global_position = parent.global_position + (preffered_position - parent.global_position).normalized() * move_speed * delta
