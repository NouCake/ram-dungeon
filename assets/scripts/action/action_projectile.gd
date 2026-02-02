class_name ActionProjectile

extends BaseActionTargeting

@export var projectile: PackedScene
@export var projectile_speed := 8.0
@export var projectile_damage := 1

func _enter_tree() -> void:
	assert(projectile != null, "ActionProjectile requires a valid projectile PackedScene to instantiate.")

func resolve_action(snapshot) -> bool:
	return shoot(snapshot)
	
func shoot(snapshot) -> bool:
	if snapshot == null or !snapshot.is_target_valid():
		return false
	var target := snapshot.target
	
	var parent: Node3D = get_parent()
	var new_projectile: Projectile = projectile.instantiate()
	
	var dist := target.global_position - global_position
	dist.y = 0
	new_projectile.shoot_direction = dist.normalized()
	new_projectile.shoot_origin = parent
	new_projectile.rotation.y = atan2(dist.x, dist.z)
	new_projectile.projectile_speed = projectile_speed
	new_projectile.projectile_damage = projectile_damage
	new_projectile.start_position = global_position

	get_tree().get_current_scene().add_child(new_projectile)
	return true
