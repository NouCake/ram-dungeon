class_name TickEffect

extends Resource

var type : String

@export var duration := 5.0
@export var stackable: bool = false
@export var tick_interval := 1.0  # How often effect triggers (for damage/heal)

var source_entity: Entity
var stack_size := 1
var elapsed_time := 0.0
var time_since_last_tick := 0.0

func is_expired() -> bool:
	return elapsed_time >= duration

func tick(delta: float, entity: Entity) -> void:
	if is_expired():
		print("Effect tick called on expired effect")
		return

	elapsed_time += delta
	time_since_last_tick += delta
	
	# Trigger effect on interval
	if time_since_last_tick >= tick_interval:
		time_since_last_tick -= tick_interval
		do_effect_trigger(entity)

## Override this in subclasses for effect logic (damage, heal, etc)
func do_effect_trigger(_entity: Entity) -> void:
	pass