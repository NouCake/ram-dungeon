## Lightweight snapshot of a target at cast start.
## Used to ensure cancellation rules (out of range/invalid) are consistent during windup.
class_name TargetSnapshot
extends RefCounted

var target: Node3D = null
var target_position: Vector3 = Vector3.ZERO
var max_range: float = 0.0

func is_target_valid() -> bool:
	return target != null and is_instance_valid(target)
