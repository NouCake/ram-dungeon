extends Node3D

@export var damage_number_scene: PackedScene

func _ready() -> void:
	Global.damage.connect(Callable(self, "_on_damage_dealt"))
	pass

func _on_damage_dealt(info: DamageInfo) -> void:
	var damage_number: Label3D = damage_number_scene.instantiate()
	damage_number.text = str(info.amount)
	damage_number.position.y = 1;
	damage_number.position.x += randf_range(-0.5, 0.5)

	if (info.type == DamageInfo.DamageType.FIRE):
		damage_number.modulate = Color(1, 0.5, 0) # Orange for fire damage
	elif (info.type == DamageInfo.DamageType.POISON):
		damage_number.modulate = Color(109.0/255.0, 34.0/255.0, 143.0/255.0) # Purple for poison damage
	elif (info.type == DamageInfo.DamageType.HEAL):
		damage_number.modulate = Color(0, 1, 0) # Green for healing
	else:
		damage_number.modulate = Color(1, 1, 1) # White for basic damage
		
	info.target.add_child(damage_number)
	pass
