class_name TickEffect

extends Resource

var type : String

@export var duration := 5.0
@export var stackable: bool = false

var stack_size := 1
var elapsed_time := 0.0

func is_expired() -> bool:
	return elapsed_time >= duration

func tick(delta: float, entity: Entity) -> void:
	if is_expired():
		print("Effect tick called on expired effect")
		return

	elapsed_time += delta
	do_effect_tick(delta, entity)

func do_effect_tick(_delta: float, _entity: Entity) -> void:
	pass