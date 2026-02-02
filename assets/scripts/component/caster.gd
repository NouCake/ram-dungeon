## Manages windup/casting for actions and enforces that only ONE action is casting at a time.
##
## This is intentionally small and generic:
## - It tracks casting progress
## - It supports cancelling when the snapshotted target moves out of range
## - It triggers action resolution exactly once when casting completes
class_name CasterComponent
extends Node

const BaseTimedActionRes = preload("res://assets/scripts/action/base_action_timed.gd")
const TargetSnapshotRes = preload("res://assets/scripts/action/target_snapshot.gd")

static var component_name: String = "caster"

signal cast_started(action: Node, cast_time_s: float)
signal cast_progress(action: Node, progress_0_1: float)
signal cast_cancelled(action: Node, reason: String)
signal cast_finished(action: Node)

static func Is(node: Node) -> bool:
	if node == null:
		return false
	if node.has_node(component_name):
		assert(node.get_node(component_name) is CasterComponent, "Node has a %s component but type is wrong." % component_name)
		return true
	return false

static func Get(node: Node) -> CasterComponent:
	if Is(node):
		return node.get_node(component_name)
	return null

## True while an action is in its windup.
var _is_casting := false
## Time since cast started.
var _elapsed_time_s := 0.0

## The action currently being cast.
var _current_action: Node = null
## Target snapshot taken at cast start (required, never null while casting).
var _target_snapshot = null

## Total windup time.
var _cast_time_s := 0.0
## Whether the parent is allowed to move while casting.
var _can_move_while_casting := true
## Whether to cancel if the target moves out of range.
var _cancel_on_target_out_of_range := true

func _ready() -> void:
	assert(name == component_name, "Component must be named %s to be recognized." % component_name)

func is_casting() -> bool:
	return _is_casting

func movement_locked() -> bool:
	return _is_casting and !_can_move_while_casting

func try_start_cast(action: Node, snapshot: TargetSnapshotRes, cast_time_s: float, can_move_while_casting: bool, cancel_on_target_out_of_range: bool) -> bool:
	if _is_casting:
		return false
	assert(snapshot != null, "CasterComponent.try_start_cast(): snapshot must not be null")

	_is_casting = true
	_elapsed_time_s = 0.0
	_current_action = action
	_target_snapshot = snapshot
	_cast_time_s = max(cast_time_s, 0.0)
	_can_move_while_casting = can_move_while_casting
	_cancel_on_target_out_of_range = cancel_on_target_out_of_range

	cast_started.emit(_current_action, _cast_time_s)
	cast_progress.emit(_current_action, 0.0)
	return true

func cancel_cast(reason: String) -> void:
	if !_is_casting:
		return
	var a := _current_action
	_reset_state()
	cast_cancelled.emit(a, reason)

func _process(delta: float) -> void:
	if !_is_casting:
		return

	# Cancel if target moved out of range (only relevant for entity targets).
	if _cancel_on_target_out_of_range and _target_snapshot.is_target_valid() and _target_snapshot.max_range > 0.001:
		var parent_3d := get_parent() as Node3D
		if parent_3d:
			var dist := (parent_3d.global_position - _target_snapshot.target.global_position).length()
			if dist > _target_snapshot.max_range:
				cancel_cast("target_out_of_range")
				return

	_elapsed_time_s += delta
	var progress := 1.0 if _cast_time_s <= 0.0001 else clamp(_elapsed_time_s / _cast_time_s, 0.0, 1.0)
	cast_progress.emit(_current_action, progress)

	if _elapsed_time_s >= _cast_time_s:
		_finish_cast()

func _finish_cast() -> void:
	if !_is_casting:
		return

	# resolve action once
	var a := _current_action
	var snap := _target_snapshot
	_reset_state()

	# resolve via BaseTimedAction contract (no runtime has_method checks)
	if a != null and is_instance_valid(a) and a is BaseTimedActionRes:
		(a as BaseTimedActionRes).resolve_action(snap)

	cast_finished.emit(a)

func _reset_state() -> void:
	_is_casting = false
	_elapsed_time_s = 0.0
	_current_action = null
	_target_snapshot = null
	_cast_time_s = 0.0
	_can_move_while_casting = true
	_cancel_on_target_out_of_range = true
