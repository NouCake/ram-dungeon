## AnimationController: Manages entity animations based on game state
##
## Listens to entity state (movement, actions) and plays appropriate animations.
## Minimal implementation with walk and attack animations.
class_name AnimationController
extends Node

@export var animation_player: AnimationPlayer

@onready var entity: Entity = get_parent()
@onready var movement: MovementComponent

enum AnimationState {
	IDLE,
	WALK,
	ATTACK
}

var current_state: AnimationState = AnimationState.IDLE
var animation_locked: bool = false

func _ready() -> void:
	assert(animation_player != null, "AnimationController requires AnimationPlayer to be set")
	assert(entity != null, "AnimationController must be child of Entity")
	
	movement = MovementComponent.Get(entity)
	assert(movement != null, "AnimationController requires MovementComponent on entity")
	
	# Connect to all actions
	for child in entity.get_children():
		if child is BaseAction:
			child.action_started.connect(_on_action_started.bind(child))
			child.action_finished.connect(_on_action_finished.bind(child))
	
	# Connect to animation finished signal
	if animation_player.has_signal("animation_finished"):
		animation_player.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	if animation_locked:
		return
	
	_update_animation_state()

func _update_animation_state() -> void:
	# Check movement
	if entity.velocity.length() > 0.1:
		_play_state(AnimationState.WALK)
	else:
		_play_state(AnimationState.IDLE)

func _play_state(state: AnimationState) -> void:
	if current_state == state and animation_player.is_playing():
		return
	
	current_state = state
	
	match state:
		AnimationState.IDLE:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")
		AnimationState.WALK:
			if animation_player.has_animation("walk"):
				animation_player.play("walk")
		AnimationState.ATTACK:
			if animation_player.has_animation("attack"):
				animation_player.play("attack")
				animation_locked = true

func _on_action_started(action: BaseAction) -> void:
	# Any action triggers attack animation for now
	_play_state(AnimationState.ATTACK)

func _on_action_finished(_action: BaseAction) -> void:
	# Action finished, but wait for animation to complete
	pass

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		animation_locked = false
		# Will return to walk/idle on next _process
