class_name ActionProjectile

extends BaseActionTargeting

@export var projectile: PackedScene
@export var projectile_speed := 8.0
@export var projectile_damage := 1

func _enter_tree() -> void:
	assert(projectile != null, "ActionProjectile requires a valid projectile PackedScene to instantiate.")
	assert(targeting_strategy != null, "ActionProjectile requires a targeting_strategy to be set.")

func resolve_action(target: TargetSnapshot) -> bool:
	return shoot(target)
	
func shoot(snapshot: TargetSnapshot) -> bool:
	assert(snapshot.targets.size() == 1, "ActionProjectile only supports single target snapshots. Got " + str(snapshot.targets.size()))

	var parent: Node3D = get_parent()
	var instance: Projectile = projectile.instantiate()
	
	var dist := snapshot.targets[0].global_position - global_position
	dist.y = 0  # @futureme future enemies might be flying

	instance.projectile_speed = projectile_speed
	instance.projectile_damage = projectile_damage
	
	instance.shoot_direction = dist.normalized()
	instance.shoot_origin = parent
	
	instance.rotation.y = atan2(dist.x, dist.z)
	instance.start_position = global_position

	get_tree().get_current_scene().add_child(instance)
	return true
