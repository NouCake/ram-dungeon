class_name MoveDungeonClearComponent

extends Node

@export var move_speed := 1.0
@export var target_distance := 2.0
@export var target_detection_range := 5.0

var character_controller: CharacterBody3D
@onready var detector := TargetDetectorComponent.Get(get_parent())

func _ready() -> void:
	character_controller = get_parent()

func move_towards_target() -> void:
	var target := detector.find_closest(["enemy"], target_detection_range, true)
	var dist: = target.global_position - character_controller.global_position
	var distance := dist.length()

	if distance < target_distance:
		character_controller.velocity = Vector3.ZERO
		character_controller.move_and_slide()
		return

	var target_pos := dist.normalized() * target_distance + character_controller.global_position
	character_controller.velocity = (target_pos - character_controller.global_position).normalized() * move_speed
	character_controller.move_and_slide()


func _physics_process(_delta: float) -> void:
	if detector.find_closest(["enemy"], target_detection_range, true):
		move_towards_target()
		return
	
	var target_position := Vector3(character_controller.global_position.x + 3, 0, 0)
	var target_dist := target_position - character_controller.global_position
	character_controller.velocity = target_dist.normalized() * move_speed
	character_controller.move_and_slide()
