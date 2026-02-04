## Utility class for creating and managing Timer nodes.
## Simplifies common timer patterns (one-shot delays, repeating intervals).
class_name TimerUtil

## Create a one-shot timer that calls a function after delay.
## Timer is added as child of parent_node and auto-freed after timeout.
static func delay(parent_node: Node, delay_sec: float, callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.wait_time = delay_sec
	timer.one_shot = true
	timer.timeout.connect(callback)
	timer.timeout.connect(timer.queue_free)  # auto-cleanup
	parent_node.add_child(timer)
	timer.start()
	return timer

## Create a repeating timer that calls a function every interval.
## Timer is added as child of parent_node.
## Call timer.stop() or parent_node.queue_free() to stop.
static func repeat(parent_node: Node, interval_sec: float, callback: Callable) -> Timer:
	var timer := Timer.new()
	timer.wait_time = interval_sec
	timer.one_shot = false  # repeating
	timer.timeout.connect(callback)
	parent_node.add_child(timer)
	timer.start()
	return timer

## Create a one-shot timer for await pattern.
## Returns timer that can be awaited: await TimerUtil.await_delay(self, 1.0).timeout
static func await_delay(parent_node: Node, delay_sec: float) -> Timer:
	var timer := Timer.new()
	timer.wait_time = delay_sec
	timer.one_shot = true
	parent_node.add_child(timer)
	timer.start()
	return timer
