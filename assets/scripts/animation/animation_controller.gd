## AnimationController: Manages entity animations based on game state
##
## Listens to entity state (movement, actions) and plays appropriate animations.
## Minimal implementation with walk and attack animations.
class_name AnimationController
extends AnimationPlayer

@onready var entity: Entity = get_parent()
@onready var movement: MovementComponent

enum AnimationState {
	IDLE,
	WALK,
	ATTACK,
	HIT
}

var current_state: AnimationState = AnimationState.IDLE
var animation_locked: bool = false

func _ready() -> void:
	assert(entity != null, "AnimationController must be child of Entity")
	
	movement = MovementComponent.Get(entity)
	assert(movement != null, "AnimationController requires MovementComponent on entity")
	
	# Connect to all actions
	for child in entity.get_children():
		if child is BaseAction:
			var action := child as BaseAction
			action.action_started.connect(_on_action_started.bind(action))
	
	# Connect to health component for hit reactions
	var health = HealthComponent.Get(entity)
	if health:
		health.was_hit.connect(_on_entity_hit)
	
	# Connect to animation finished signal
	if has_signal("animation_finished"):
		animation_finished.connect(_on_animation_finished)

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

func _play_state(state: AnimationState, animation_name: String = "") -> void:
	if current_state == state and is_playing():
		return
	
	current_state = state
	
	match state:
		AnimationState.IDLE:
			if has_animation("idle"):
				play("idle")
		AnimationState.WALK:
			if has_animation("walk"):
				play("walk")
		AnimationState.ATTACK:
			assert(has_animation(animation_name), "AnimationController: No animation named %s for attack state" % animation_name)
			play(animation_name)
			animation_locked = true
		AnimationState.HIT:
			if has_animation("hit"):
				play("hit")
				animation_locked = true

func _on_action_started(_action: BaseAction) -> void:
	_play_state(AnimationState.ATTACK, _action.animation_name)

func _on_entity_hit(info: DamageInfo) -> void:
	if info.type == DamageInfo.DamageType.HEAL:
		return  # Don't play hit animation on heal
	
	# Check if entity has super-armor (casting with cancel_on_damage_taken = false)
	var caster = CasterComponent.Get(entity)
	if caster and caster.is_casting():
		var action = caster.get_current_action()
		if action and !action.cancel_on_damage_taken:
			return  # Ignore hit, keep attacking! (super-armor)
	
	# Play hit animation (interrupts current animation if any)
	animation_locked = false  # Unlock first
	_play_state(AnimationState.HIT)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("attack") or anim_name == "hit":
		animation_locked = false
