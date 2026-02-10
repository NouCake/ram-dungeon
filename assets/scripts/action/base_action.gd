## Base class for all actions that target entities and perform in an interval
class_name BaseAction

extends Node3D

## Time in seconds between each action attempt
@export var action_interval: float = 1.0
## If true, the action is ready immediately on start
@export var start_ready := true
## If true, the action will only reset its timer on a successful action
@export var pause_until_action_success := false

## Priority for movement control (higher = takes control first when multiple actions ready)
@export var priority := 10

## Movement strategy for this action (how to position relative to target)
@export var movement_strategy: MovementStrategy

## Filters to apply when searching for targets
@export var target_filters: Array[String] = ["enemy"]
## Minimum distance to execute action (won't execute if target closer, but will still target for movement)
@export var min_execution_range: float = 0.0
## Maximum distance to execute action (won't execute if target farther, but will still target for movement)
@export var max_execution_range: float = 0.0
## Targeting strategy to use (configurable per action)
@export var targeting_strategy: TargetingStrategy
@export var line_of_sight := true

## Time before action is performed
@export var cast_time := 0.0
@export var can_move_while_casting := true
@export var cancel_on_target_out_of_range := true
@export var cancel_on_damage_taken := false

## Runtime override for targeting (e.g., debuffs like "Desynced")
var targeting_override: TargetingStrategy = null

@onready var time_since_last_action: float = action_interval if start_ready else 0.0
@onready var detector := TargetDetectorComponent.Get(get_parent())

func _process(delta: float) -> void:
	if time_since_last_action >= action_interval:
		if !pause_until_action_success:
			time_since_last_action -= action_interval
			
		if perform_action() && pause_until_action_success:
			time_since_last_action -= action_interval
	else:
		time_since_last_action += delta

func perform_action() -> bool:
	var caster := CasterComponent.Get(get_parent())
	if caster.is_casting():
		return false

	var snapshot := get_target_snapshot()
	if snapshot == null or snapshot.targets.is_empty():
		return false
	
	# Check execution range (target exists but too close/far to execute)
	if min_execution_range > 0.0 or max_execution_range > 0.0:
		var entity := get_parent() as Entity
		if entity:
			var distance := entity.global_position.distance_to(snapshot.targets[0].global_position)
			if min_execution_range > 0.0 and distance < min_execution_range:
				return false  # Too close to execute, but target still valid for movement
			if max_execution_range > 0.0 and distance > max_execution_range:
				return false  # Too far to execute, but target still valid for movement

	if cast_time <= 0.0001:
		resolve_action(snapshot)
		return true

	return caster.try_start_cast(self, snapshot, cast_time, can_move_while_casting, cancel_on_target_out_of_range, cancel_on_damage_taken)

func get_target_snapshot() -> TargetSnapshot:
	var active_strategy := targeting_override if targeting_override else targeting_strategy
	if active_strategy == null:
		return null
	
	var targets := active_strategy.select_targets(detector, target_filters, line_of_sight)
	
	if targets.is_empty():
		return null
	
	var snapshot := TargetSnapshot.new()
	snapshot.max_range = active_strategy.max_range
	snapshot.targets = targets
	return snapshot

## Override: do the actual action (damage/heal/spawn/etc.).
## Called immediately when casting finished.
func resolve_action(_snapshot: TargetSnapshot) -> bool:
	return false

## Check if this action's cooldown is ready
func is_cooldown_ready() -> bool:
	return time_since_last_action >= action_interval

## Get remaining cooldown time in seconds
func get_cooldown_remaining() -> float:
	if is_cooldown_ready():
		return 0.0
	return action_interval - time_since_last_action

## Get the current target for this action (from targeting system)
func get_current_target() -> Entity:
	var snapshot := get_target_snapshot()
	if snapshot and not snapshot.targets.is_empty():
		return snapshot.targets[0]
	return null
