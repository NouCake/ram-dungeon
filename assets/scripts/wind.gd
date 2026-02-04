extends Node3D

@export var wind_director: Vector3 = Vector3(1, 0, 0)
@export var strength: float = 2.0

@onready var detector: TargetDetectorComponent = TargetDetectorComponent.Get(self)

func _process(delta: float) -> void:
	var targets := detector.find_all(["cloud"], 0, false)
	for target in targets:
		target.global_position += wind_director.normalized() * delta * strength