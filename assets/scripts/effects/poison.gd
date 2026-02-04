class_name PoisonEffect

extends TickEffect

var damage_interval := 1.0
var origin: Entity

var _damage_timer: Timer

func _init() -> void:
	type = "Poison"

func _ready() -> void:
	super._ready()
	# Start repeating damage timer
	_damage_timer = TimerUtil.repeat(self, damage_interval, _deal_damage)

func merge_stack(other: TickEffect) -> void:
	if other is PoisonEffect:
		var other_poison: PoisonEffect = other as PoisonEffect
		stack_size += other_poison.stack_size
		duration = max(duration, other_poison.duration)
	else: 
		print("Tried to merge non-poison effect into poison effect")

func _deal_damage() -> void:
	var entity := get_parent() as Entity
	if not entity:
		return
	
	var damage_info := DamageInfo.new(origin, entity)
	damage_info.amount = stack_size
	damage_info.type = DamageInfo.DamageType.POISON
	entity.health.do_damage(damage_info)

# Old tick-based logic removed
func do_effect_tick(delta: float, entity: Entity) -> void:
	pass
