## Base class for action that target entities and perform in an interval
class_name BaseActionTargeting

extends BaseTimedAction

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]

## How far the action can reach targets
@export var action_range: float

@onready var detector := TargetDetectorComponent.Get(get_parent())