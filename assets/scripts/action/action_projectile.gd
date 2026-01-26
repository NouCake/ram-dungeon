class_name ActionProjectile

extends Node3D

@export var projectile: PackedScene
@export var projectile_speed := 8.0
@export var projectile_damage := 1

@export var projectiles_cooldown := 1.0

@export var target_range := 5.0

@export var target_filters: Array[String] = [];

@onready var detector := TargetDetectorComponent.Get(get_parent());

@onready var time_since_last_project := projectiles_cooldown;

func _enter_tree() -> void:
	assert(projectile != null, "ActionProjectile requires a valid projectile PackedScene to instantiate.")
	
func _process(delta: float) -> void:
	if time_since_last_project >= projectiles_cooldown:
		if shoot():
			var cooldown_spread := randf() * 0.2 - 0.1
			time_since_last_project -= projectiles_cooldown + cooldown_spread * projectiles_cooldown;
		else:
			return
	time_since_last_project += delta;
	
func shoot() -> bool:
	var target := detector.find_closest(target_filters, target_range, true);
	
	if target == null:
		return false
		
	var parent: Node3D = get_parent()
	#print("Shooter Components shoots at: " + target.name) 
		
	var new_projectile: Projectile = projectile.instantiate();
	
	var dist := target.global_position - global_position;
	dist.y = global_position.y
	new_projectile.shoot_direction = dist.normalized()
	new_projectile.shoot_origin = parent
	new_projectile.rotation.y = atan2(dist.x, dist.z)
	new_projectile.start_position = global_position

	get_tree().get_current_scene().add_child(new_projectile)
	return true
