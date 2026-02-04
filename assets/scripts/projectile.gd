class_name Projectile

extends Area3D

@export var death_spawn: PackedScene

var projectile_speed := 8.0
var shoot_direction: Vector3 = Vector3.RIGHT
var shoot_origin: Entity
var projectile_damage := 1
var max_range := 10.0

var start_position: Vector3
func _ready() -> void:
	global_position = start_position
	assert(shoot_origin != null, "Projectile must have a shoot_origin set")
	pass

func _physics_process(delta: float) -> void:
	global_position = global_position + shoot_direction * projectile_speed * delta
	if start_position.distance_to(global_position) > max_range:
		#queue_free()
		pass


func on_hit(other: Node) -> void:
	if other == shoot_origin || !is_instance_valid(other) || !is_instance_valid(shoot_origin):
		return
		
	
	if other.has_node("health"):
		var health_component: HealthComponent = other.get_node("health")
		var info := DamageInfo.new(shoot_origin, other as Entity)
		info.amount = projectile_damage
		info.knockback_source_position = global_position
		info.knockback_amount = 1.0
		health_component.do_damage(info)
	else:
		pass
	
	if death_spawn:
		spawn_death_effects.call_deferred()
	queue_free()

func spawn_death_effects() -> void:
	var spawned: Node3D = death_spawn.instantiate()
	get_tree().get_current_scene().add_child(spawned)
	spawned.global_position = global_position
