class_name KnockbackComponent

extends Node

static var component_name: String = "knockback"

@export var knockback_resistance: float = 0.0

func _ready() -> void:
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")

func do_knockback(knockback_source: Vector3) -> void:
	var parent: Node3D = get_parent();
	
	var dist := (knockback_source - parent.global_position).normalized();
	dist.y = 0;
	parent.global_position = parent.global_position - dist * 0.25 * (1.0 - knockback_resistance);

func _on_health_was_hit(info: DamageInfo) -> void:
	if !info.knockback_source_position || info.knockback_amount <= 0.0:
		return

	do_knockback(info.knockback_source_position)
