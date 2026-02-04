class_name Explosion

extends Node3D

var origin: Entity

@export var damage := 3

func _ready() -> void:
	assert(origin != null, "Explosion must have an origin set")
	deal_damage()
	TimerUtil.delay(self, 0.2, queue_free)

func deal_damage() -> void:
	var detector := TargetDetectorComponent.Get(self)
	var targets := detector._get_all_near_targets()

	print("Explosion dealing damage to " + str(targets.size()) + " targets")
	for target in targets:
		if !target.has_node("health"):
			continue

		var health: HealthComponent = target.get_node("health")
		var info := DamageInfo.new(origin, target as Entity)
		info.amount = damage
		info.knockback_source_position = global_position
		info.knockback_amount = 2.0
		health.do_damage(info)
