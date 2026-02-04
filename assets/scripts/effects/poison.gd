class_name PoisonEffect

extends TickEffect

func _init() -> void:
	type = "Poison"
	tick_interval = 1.0
	duration = 5.0

func merge_stack(other: TickEffect) -> void:
	assert(other is PoisonEffect, "Cannot merge non-PoisonEffect into PoisonEffect")
	
	var other_poison: PoisonEffect = other as PoisonEffect
	stack_size += other_poison.stack_size
	duration = max(duration, other_poison.duration)
	time_since_last_tick = min(time_since_last_tick, other_poison.time_since_last_tick)
		

func do_effect_trigger(entity: Entity) -> void:
	var damage_info := DamageInfo.new(source_entity, entity)
	damage_info.amount = stack_size
	damage_info.type = DamageInfo.DamageType.POISON
	entity.health.do_damage(damage_info)
