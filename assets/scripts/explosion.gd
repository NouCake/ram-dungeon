class_name Explosion

extends Node2D

@export var damage = 3
var timer := 0.0

func _physics_process(delta):
	if timer == 0:
		deal_damage()

	timer += delta
	if timer > 0.2:
		queue_free()

func deal_damage():
	var finder = get_node("finder") as TargetFinderComponent
	var targets = finder._get_all_near_targets()

	print("Explosion dealing damage to " + str(targets.size()) + " targets")
	for target in targets:
		if !target.has_node("health"):
			continue

		var health_component: HealthComponent = target.get_node("health")
		health_component.do_damage(damage, self)
