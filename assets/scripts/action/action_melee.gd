class_name MeleeComponent

extends Node

@export var melee_range := 1.5
@export var melee_damage := 2
@export var melee_cooldown := 0.5

@onready var detector := TargetDetectorComponent.Get(get_parent())

var time_since_last_attack: float = melee_cooldown

func _process(delta: float) -> void:
	time_since_last_attack += delta
	if time_since_last_attack >= melee_cooldown:
		time_since_last_attack -= melee_cooldown
		attack()

func attack() -> void:
	var parent: Entity = get_parent()
	var targets := detector.find_all(["player"], melee_range, false)
	
	

	for target in targets:
		if not target.has_node("health"):
			assert(false, "MeleeComponent.attack(): Target has no health node")
			continue
		var health := target.get_node("health") as HealthComponent;

		var info := DamageInfo.new(parent, target as Entity)
		info.amount = melee_damage
		info.knockback_source_position = parent.global_position
		info.knockback_amount = 1.0
		health.do_damage(info)

	pass
