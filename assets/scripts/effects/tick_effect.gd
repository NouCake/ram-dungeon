## Effect that triggers repeatedly at a fixed interval (e.g., damage/heal over time).
class_name TickEffect

extends Effect

## How often the effect triggers (in seconds)
@export var tick_interval := 1.0

var _tick_timer: Timer = null

## Override in subclasses, call super() to preserve tick timer setup.
func on_applied() -> void:
	super()
	_tick_timer = TimerUtil.repeat(target, tick_interval, on_tick)

## Override in subclasses, MUST call super() to clean up tick timer.
func on_expired() -> void:
	if _tick_timer and is_instance_valid(_tick_timer):
		_tick_timer.queue_free()
		_tick_timer = null
	super()

## Override in subclasses: called every tick_interval
func on_tick() -> void:
	pass