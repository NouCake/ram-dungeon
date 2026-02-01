class_name ActionHeal

extends Node

@export var heal_amount := 2
@export var heal_cooldown := 3.0
@export var heal_range := 5.0
@export var target_filters: Array[String] = ["enemy"]
@export var heal_vfx: PackedScene

@onready var detector := TargetDetectorComponent.Get(get_parent())

var time_since_last_heal: float = heal_cooldown

func _process(delta: float) -> void:
	time_since_last_heal += delta
	if time_since_last_heal >= heal_cooldown:
		if heal():
			time_since_last_heal -= heal_cooldown

func heal() -> bool:
	var target := detector.find_closest(target_filters, heal_range, true)
	
	if target == null:
		return false
	
	if not target.has_node("health"):
		return false
		
	var health := target.get_node("health") as HealthComponent
	
	# Only heal if the target is not at full health
	if health.current_health >= health.max_health:
		return false
	
	var parent: Entity = get_parent()
	var info := DamageInfo.new(parent, target as Entity)
	info.type = DamageInfo.DamageType.HEAL
	info.amount = heal_amount
	health.do_damage(info)
	
	# Spawn VFX at target location
	if heal_vfx:
		var vfx_instance: Node3D = heal_vfx.instantiate()
		get_tree().get_current_scene().add_child(vfx_instance)
		vfx_instance.global_position = target.global_position
	
	print("Healed " + target.name + " for " + str(heal_amount) + " health")
	
	return true
