class_name KnockbackComponent

extends Node

static var component_name: String = "knockback"

func _ready():
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")

func do_knockback(knockback_source: Node2D):
	var parent: Node2D = get_parent();
	# print("I (" + parent.name + ") was knocked back from: " + knockback_source.name)
	var dist = (knockback_source.global_position - parent.global_position).normalized();
	parent.global_position = parent.global_position - dist * 10;
