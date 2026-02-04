class_name BurnEffect

extends TickEffect

func _init() -> void:
	stackable = true
	duration = 2.0
	type = "Burn"
	tick_interval = 1.0

func do_effect_trigger(entity: Entity) -> void:
	var damage_info := DamageInfo.new(null, entity)
	damage_info.amount = stack_size
	damage_info.type = DamageInfo.DamageType.FIRE
	entity.health.do_damage(damage_info)
