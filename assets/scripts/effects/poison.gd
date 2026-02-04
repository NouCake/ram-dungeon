class_name PoisonEffect

extends TickEffect

func _init() -> void:
	effect_type = "Poison"
	tick_interval = 1.0
	duration = 5.0
	stackable = true

func _on_tick() -> void:
	var damage_info := DamageInfo.new(source, target)
	damage_info.amount = stack_size
	damage_info.type = DamageInfo.DamageType.POISON
	target.health.do_damage(damage_info)
