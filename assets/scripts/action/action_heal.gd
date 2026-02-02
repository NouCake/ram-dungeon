class_name ActionHeal

extends BaseActionTargeting

@export var heal_amount := 2
@export var heal_vfx: PackedScene

func resolve_action(snapshot) -> bool:
	return heal(snapshot)

func heal(snapshot) -> bool:
	if snapshot == null or !snapshot.is_target_valid():
		return false
	var target := snapshot.target
	
	if not target.has_node("health"):
		return false
		
	var health := target.get_node("health") as HealthComponent
	
	# Only heal if the target is not at full health
	if health.current_health >= health.max_health:
		return false
	
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
	
	print("Healed " + target.name + " for " + str(heal_amount) + " health")
	
	return true
