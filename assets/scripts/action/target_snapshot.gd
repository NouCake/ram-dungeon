## Lightweight snapshot of a targets at cast start.
## Used to ensure cancellation rules (out of range/invalid) are consistent during windup.
class_name TargetSnapshot
extends RefCounted

var targets: Array[Node3D] = []
var target_position: Vector3 = Vector3.ZERO
var max_range: float = 0.0

func is_target_valid() -> bool:
	return targets != null and is_instance_valid(targets)
