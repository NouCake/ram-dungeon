class_name BurnEffect

extends TickEffect

@export var burn_interval := 1.0
var time_since_last_damage := burn_interval

func _init() -> void:
	stackable = true
	duration = 2.0
	type = "Burn"

func do_effect_tick(delta: float, entity: Entity) -> void:
	time_since_last_damage += delta

	if time_since_last_damage >= burn_interval:
		var damage_info := DamageInfo.new(null, entity)
		damage_info.amount = stack_size
		damage_info.type = DamageInfo.DamageType.FIRE
		entity.health.do_damage(damage_info)
		time_since_last_damage -= burn_interval
	
