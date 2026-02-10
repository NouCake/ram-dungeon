class_name ActionMelee

extends BaseActionTargeting

@export var melee_damage := 2

func resolve_action(snapshot: TargetSnapshot):
	var parent: Entity = get_parent()

	for target in snapshot.targets:
		if not target.has_node("health"):
			assert(false, "MeleeComponent.attack(): Target has no health node")
			continue
		var health := target.get_node("health") as HealthComponent

		var info := DamageInfo.new(parent, target as Entity)
		info.amount = melee_damage
		info.knockback_source_position = parent.global_position
		info.knockback_amount = 1.0
		health.do_damage(info)

	return true
