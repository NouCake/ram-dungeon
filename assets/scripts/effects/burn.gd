class_name BurnEffect

extends TickEffect

@export var burn_interval := 1.0

var _damage_timer: Timer

func _init() -> void:
	stackable = true
	duration = 2.0
	type = "Burn"

func _ready() -> void:
	super._ready()
	# Start repeating damage timer
	_damage_timer = TimerUtil.repeat(self, burn_interval, _deal_damage)

func _deal_damage() -> void:
	var entity := get_parent() as Entity
	if not entity:
		return
	
	var damage_info := DamageInfo.new(null, entity)
	damage_info.amount = stack_size
	damage_info.type = DamageInfo.DamageType.FIRE
	entity.health.do_damage(damage_info)

# Old tick-based logic removed
func do_effect_tick(delta: float, entity: Entity) -> void:
	pass
