class_name Moving

extends Node

@export var detection_range := 5.0
@export var prefered_target_distance := 1.0
@export var move_speed := 0.75
@export var move_back := false

@onready var detector := TargetDetectorComponent.Get(get_parent())
@onready var caster := CasterComponent.Get(get_parent())

func _process(delta: float) -> void:
	var target := detector.find_closest(["player"], detection_range, true)
	if target == null:
		return

	if caster.movement_locked():
		return
	
	var parent: Node3D = get_parent()
	var distTarget := target.global_position - parent.global_position;
	
	var preffered_position: Vector3;
	
	var _speed := move_speed
	if !move_back:
		var distance_to_target := distTarget.length();
		if distance_to_target <= prefered_target_distance:
			return
		preffered_position = target.global_position
	else:
		preffered_position = target.global_position - distTarget.normalized() * prefered_target_distance
		_speed = move_speed * 0.5
	preffered_position.y = 0;

	parent.global_position = parent.global_position + (preffered_position - parent.global_position).normalized() * _speed * delta
