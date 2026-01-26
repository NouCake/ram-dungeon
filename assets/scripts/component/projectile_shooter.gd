class_name ProjectileShooterComponent

extends Node

@export var projectile: PackedScene
@export var projectile_speed = 800
@export var projectile_damage = 1

@export var projectiles_per_second = 1;

@onready var finder: TargetFinderComponent;

var time_since_last_project = 0;

func _ready() -> void:
	finder = get_parent().get_node("finder")
	assert(finder != null, "ProjectileShooterComponent requires a TargetFinderComponent as a sibling node named 'finder'.")
	assert(projectile != null, "ProjectileShooterComponent requires a valid projectile PackedScene to instantiate.")
	
func _process(delta: float) -> void:
	time_since_last_project += delta;
	
	if time_since_last_project > 1.0 /projectiles_per_second:
		shoot();
		time_since_last_project = 0;

	
func shoot():
	var target = finder.get_target();
	
	if target == null:
		return
		
	var parent: Node2D = get_parent()
	#	print("Shooter Components shoots at: " + target.name) 
		
	var new_projectile: MyCoolBullet = projectile.instantiate();
	
	var dist = target.global_position - parent.global_position;
	new_projectile.shoot_direction = dist.normalized()
	new_projectile.shoot_source = parent
	new_projectile.global_position = parent.global_position
	new_projectile.rotation = atan2(dist.y, dist.x)
	get_tree().get_current_scene().add_child(new_projectile)
