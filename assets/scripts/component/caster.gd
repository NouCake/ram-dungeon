## Manages windup/casting for actions and enforces that only ONE action is casting at a time.
##
## This is intentionally small and generic:
## - It tracks casting progress
## - It supports cancelling when the snapshotted target moves out of range
## - It triggers action resolution exactly once when casting completes
class_name CasterComponent
extends Node

static var component_name: String = "caster"

static func Is(node: Node) -> bool:
	assert(node != null, "CasterComponent.Is() called with null node")
	if node.has_node(component_name):
		assert(node.get_node(component_name) is CasterComponent, "Node has a %s component but type is wrong." % component_name)
		return true
	return false
static func Get(node: Node) -> CasterComponent:
	if Is(node):
		return node.get_node(component_name)
	return null

var _is_casting := false
var _elapsed_time_s := 0.0

var _current_action: BaseTimedCast = null
## Target snapshot taken at cast start (required, never null while casting).
var _target: TargetSnapshot = null

## Total windup time.
var _cast_time_s := 0.0
var _can_move_while_casting := true
var _cancel_on_target_out_of_range := true
var _cancel_on_damage_taken := false

func _ready() -> void:
	assert(name == component_name, "Component must be named %s to be recognized." % component_name)
	var health_comp := HealthComponent.Get(get_parent())
	if health_comp != null:
		health_comp.connect("was_hit", Callable(self, "_on_health_was_hit"))

func try_start_cast(
	action: Node, 
	snapshot: TargetSnapshot, 
	cast_time_s: float, 
	can_move_while_casting: bool, 
	cancel_on_target_out_of_range: bool,
	cancel_on_damage_taken: bool = false
) -> bool:
	if _is_casting:
		return false
	assert(snapshot != null, "CasterComponent.try_start_cast(): snapshot must not be null")

	_is_casting = true
	_elapsed_time_s = 0.0
	_current_action = action
	_target = snapshot
	_cast_time_s = max(cast_time_s, 0.0)
	_can_move_while_casting = can_move_while_casting
	_cancel_on_target_out_of_range = cancel_on_target_out_of_range
	_cancel_on_damage_taken = cancel_on_damage_taken

	return true

func cancel_cast() -> void:
	if !_is_casting:
		return
	_reset_state()

func _process(delta: float) -> void:
	if !_is_casting:
		return

	# Cancel if target moved out of range (only relevant for entity targets).
	if _cancel_on_target_out_of_range and _target.is_target_valid() and _target.max_range > 0.001:
		var parent_3d := get_parent() as Node3D
		if parent_3d:
			var dist := (parent_3d.global_position - _target.target.global_position).length()
			if dist > _target.max_range:
				cancel_cast()
				return

	_elapsed_time_s += delta
	#var progress:float = clamp(_elapsed_time_s / _cast_time_s, 0.0, 1.0)
	#cast_progress.emit(_current_action, progress)

	if _elapsed_time_s >= _cast_time_s:
		_current_action.resolve_action(_target)
		_reset_state()

	# resolve via BaseTimedAction contract (no runtime has_method checks)


func _reset_state() -> void:
	_is_casting = false
	_elapsed_time_s = 0.0
	_current_action = null
	_target = null
	_cast_time_s = 0.0
	_can_move_while_casting = true
	_cancel_on_target_out_of_range = true

func is_casting() -> bool:
	return _is_casting

func movement_locked() -> bool:
	return _is_casting and !_can_move_while_casting


func _on_health_was_hit(_info: DamageInfo) -> void:
	if _is_casting and _cancel_on_damage_taken and _info.type != DamageInfo.DamageType.HEAL:
		print("Casting cancelled due to damage taken")
		cancel_cast()
