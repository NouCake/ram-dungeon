class_name BurnEffect

extends TickEffect

func _init() -> void:
	stackable = true
	duration = 2.0
	tick_interval = 1.0

func on_tick() -> void:
	var damage_info := DamageInfo.new(source, target)
	damage_info.amount = stack_count
	damage_info.type = DamageInfo.DamageType.FIRE
	target.health.do_damage(damage_info)
