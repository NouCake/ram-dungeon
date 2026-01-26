class_name MyCoolBullet

extends Area2D

@export var death_spawn: PackedScene;

var bullet_speed = 800
var shoot_direction: Vector2 = Vector2.UP
var shoot_source: Node2D
var bullet_damage = 1
var max_range = 1000;

var start_position: Vector2;
func _ready():
	start_position = global_position;
	pass

func _physics_process(delta: float) -> void:
	global_position = global_position + shoot_direction * bullet_speed * delta;
	if start_position.distance_to(global_position) > max_range:
		#queue_free()
		pass


func on_hit(other: Node):
	if other == shoot_source:
		# print("I was about to hit my source, so ignore")
		return
		
	
	if other.has_node("health"):
		var health_component: HealthComponent = other.get_node("health");
		health_component.do_damage(bullet_damage, self)
	
	if death_spawn:
		spawn_death_effects.call_deferred()
	queue_free()

func spawn_death_effects():
	var spawned = death_spawn.instantiate();
	get_tree().get_current_scene().add_child(spawned);
	spawned.global_position = global_position;
