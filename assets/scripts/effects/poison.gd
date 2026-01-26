class_name PoisonEffect

extends TickEffect

var damage_interval := 1.0
var time_since_last_damage := damage_interval
var origin: Entity

func _init() -> void:
	type = "Poison"

func merge_stack(other: TickEffect) -> void:
	if other is PoisonEffect:
		var other_poison: PoisonEffect = other as PoisonEffect
		stack_size += other_poison.stack_size
		duration = max(duration, other_poison.duration)
		time_since_last_damage = min(time_since_last_damage, other_poison.time_since_last_damage)
	else: 
		print("Tried to merge non-poison effect into poison effect")

func do_effect_tick(delta: float, entity: Entity) -> void:
	time_since_last_damage += delta

	if time_since_last_damage >= damage_interval:
		var damage_info := DamageInfo.new(origin, entity)
		damage_info.amount = stack_size
		damage_info.type = DamageInfo.DamageType.POISON
		entity.health.do_damage(damage_info)
		time_since_last_damage -= damage_interval
	
