extends CharacterBody3D

@onready var animation: AnimationPlayer = $animation

func play_blink() -> void:
	animation.stop()
	animation.play("blink")

func _on_health_was_hit(_info: DamageInfo) -> void:
	play_blink()
