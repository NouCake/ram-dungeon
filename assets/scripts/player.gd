class_name Player
extends CharacterBody3D

@onready var sprite: AnimatedSprite3D = $sprite

func _ready() -> void:
	sprite.animation_finished.connect(on_animation_finished)

func play_blink(_hit_source: Node3D) -> void:
	sprite.play("blink")

func on_animation_finished() -> void:
	sprite.play("idle")

func _process(_delta: float) -> void:
	if sprite.animation == "blink":
		return

	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
	pass