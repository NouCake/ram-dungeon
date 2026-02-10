class_name KnockbackComponent

extends Node

static var component_name: String = "knockback"

@export var knockback_resistance: float = 0.0

@onready var _movement_component: MovementComponent = MovementComponent.Get(get_parent())

func _ready() -> void:
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")
	assert(_movement_component != null, "KnockbackComponent requires a MovementComponent sibling.")

	var health_comp := HealthComponent.Get(get_parent())
	if health_comp != null:
		health_comp.connect("was_hit", Callable(self, "_on_health_was_hit"))

func do_knockback(knockback_source: Vector3) -> void:
	var parent: Node3D = get_parent()
	
	var dist := (parent.global_position - knockback_source).normalized()
	dist.y = 0
	var knock := dist * (1.0 - knockback_resistance) * 100.0
	_movement_component.apply_force(knock)


func _on_health_was_hit(info: DamageInfo) -> void:
	if !info.knockback_source_position || info.knockback_amount <= 0.0:
		return

	do_knockback(info.knockback_source_position)
