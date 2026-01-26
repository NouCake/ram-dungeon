extends Camera2D

@export var target: Node2D
@onready var target_offset := global_position - target.global_position

func _process(_delta: float) -> void:
	global_position.y = target.global_position.y + target_offset.y