## Base class for all targeting strategies.
## Subclasses implement select_targets() to define how targets are chosen.
class_name TargetingStrategy
extends Resource

## Returns array of targets based on strategy implementation.
## For single-target actions, caller takes first element.
## For multi-target actions (future), caller uses full array.
func select_targets(
	detector: TargetDetectorComponent,
	filters: Array[String],
	max_range: float,
	line_of_sight: bool
) -> Array[Node3D]:
	push_error("TargetingStrategy.select_targets() must be overridden in subclass")
	return []
