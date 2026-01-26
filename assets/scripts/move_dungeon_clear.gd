class_name MoveDungeonClearComponent

extends Node

@export var move_speed := 100.0
@export var target_distance := 200.0

var character_controller: CharacterBody2D
var finder: TargetFinderComponent

func _ready():
	character_controller = get_parent()
	finder = character_controller.get_node("finder") as TargetFinderComponent

func move_towards_target() -> void:
	var target = finder.get_target()
	var dist = target.global_position - character_controller.global_position
	var distance = dist.length()

	if distance < target_distance:
		character_controller.velocity = Vector2.ZERO
		character_controller.move_and_slide()
		return

	var target_pos = dist.normalized() * target_distance + character_controller.global_position
	character_controller.velocity = (target_pos - character_controller.global_position).normalized() * move_speed
	character_controller.move_and_slide()


func _physics_process(delta: float) -> void:
	if finder.get_target():
		move_towards_target()
		return;
	
	var target = Vector2(0, character_controller.global_position.y - 50)
	character_controller.velocity = (target - character_controller.global_position).normalized() * move_speed
	character_controller.move_and_slide()
	