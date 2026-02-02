class_name CasterComponent
extends Node

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

var _is_casting := false
var _elapsed := 0.0

var _action: Node = null
var _snapshot: TargetSnapshot = null

var _cast_time_s := 0.0
var _can_move_while_casting := true
var _cancel_on_target_out_of_range := true
var _cancel_on_target_invalid := true
var _cancel_on_damage := false

var _health: HealthComponent = null

func _ready() -> void:
	assert(name == component_name, "Component must be named %s to be recognized." % component_name)
	_health = HealthComponent.Get(get_parent())
	if _health:
		_health.was_hit.connect(_on_was_hit)

func is_casting() -> bool:
	return _is_casting

func movement_locked() -> bool:
	return _is_casting and !_can_move_while_casting

func try_start_cast(action: Node, snapshot: TargetSnapshot, cast_time_s: float, can_move_while_casting: bool, cancel_on_target_out_of_range: bool, cancel_on_target_invalid: bool, cancel_on_damage: bool) -> bool:
	if _is_casting:
		return false

	_is_casting = true
	_elapsed = 0.0
	_action = action
	_snapshot = snapshot
	_cast_time_s = max(cast_time_s, 0.0)
	_can_move_while_casting = can_move_while_casting
	_cancel_on_target_out_of_range = cancel_on_target_out_of_range
	_cancel_on_target_invalid = cancel_on_target_invalid
	_cancel_on_damage = cancel_on_damage

	cast_started.emit(_action, _cast_time_s)
	cast_progress.emit(_action, 0.0)
	return true

func cancel_cast(reason: String) -> void:
	if !_is_casting:
		return
	var a := _action
	_reset_state()
	cast_cancelled.emit(a, reason)

func _process(delta: float) -> void:
	if !_is_casting:
		return

	# cancellation checks
	if _cancel_on_target_invalid and _snapshot != null and _snapshot.target != null and !is_instance_valid(_snapshot.target):
		cancel_cast("target_invalid")
		return

	if _cancel_on_target_out_of_range and _snapshot != null and _snapshot.is_target_valid() and _snapshot.max_range > 0.001:
		var parent_3d := get_parent() as Node3D
		if parent_3d:
			var dist := (parent_3d.global_position - _snapshot.target.global_position).length()
			if dist > _snapshot.max_range:
				cancel_cast("target_out_of_range")
				return

	_elapsed += delta
	var progress := 1.0 if _cast_time_s <= 0.0001 else clamp(_elapsed / _cast_time_s, 0.0, 1.0)
	cast_progress.emit(_action, progress)

	if _elapsed >= _cast_time_s:
		_finish_cast()

func _finish_cast() -> void:
	if !_is_casting:
		return

	# resolve action once
	var a := _action
	var snap := _snapshot
	_reset_state()

	# Call action.resolve_action(snapshot) if present
	if a != null and is_instance_valid(a) and a.has_method("resolve_action"):
		a.call("resolve_action", snap)

	cast_finished.emit(a)

func _reset_state() -> void:
	_is_casting = false
	_elapsed = 0.0
	_action = null
	_snapshot = null
	_cast_time_s = 0.0
	_can_move_while_casting = true
	_cancel_on_target_out_of_range = true
	_cancel_on_target_invalid = true
	_cancel_on_damage = false

func _on_was_hit(_info: DamageInfo) -> void:
	if _is_casting and _cancel_on_damage:
		cancel_cast("damage")
