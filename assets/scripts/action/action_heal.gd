class_name ActionHeal

extends BaseActionTargeting

@export var heal_amount := 2
@export var heal_vfx: PackedScene

func _enter_tree() -> void:
	# Default to lowest HP% targeting (makes sense for heal)
	if not targeting_strategy:
		targeting_strategy = TargetLowestHPPercent.new()

func resolve_action(snapshot: TargetSnapshot) -> bool:
	return heal(snapshot)

func heal(snapshot: TargetSnapshot) -> bool:
	assert(snapshot.targets.size() == 1, "ActionHeal only supports single target. Found: " + str(snapshot.targets.size()))
	var target := snapshot.targets[0]

	var health := target.get_node("health") as HealthComponent
	var parent: Entity = get_parent()
	
	var info := DamageInfo.new(parent, target as Entity)
	info.type = DamageInfo.DamageType.HEAL
	info.amount = heal_amount
	health.do_damage(info)
	
	# Spawn VFX at target location
	if heal_vfx:
		var vfx_instance: Node3D = heal_vfx.instantiate()
		get_tree().get_current_scene().add_child(vfx_instance)
		vfx_instance.global_position = target.global_position
	
	return true
