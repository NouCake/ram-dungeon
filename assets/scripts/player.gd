class_name Player
extends CharacterBody2D

@export var player_speed = 300
@export var bullet_scene: PackedScene
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		shoot()


func shoot():
	var target = $finder.get_target();
	if target == null:
		print("Couldn't find a target to shoot at")
		return
	var new_bullet: MyCoolBullet = bullet_scene.instantiate();
	
	var dist = target.global_position - global_position
	new_bullet.shoot_direction = dist.normalized()
	new_bullet.shoot_source = self
	new_bullet.global_position = global_position
	new_bullet.rotation = atan2(dist.y, dist.x)
	get_tree().get_current_scene().add_child(new_bullet)
