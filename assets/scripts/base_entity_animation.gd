extends AnimationPlayer

func _ready() -> void:
	var health_comp := HealthComponent.Get(get_parent())
	if health_comp != null:
		health_comp.connect("was_hit", Callable(self, "_on_health_was_hit"))
		print("Connected health component to animation player for ", get_parent().name)
	else:
		print("No health component found for ", get_parent().name)

func _on_health_was_hit(info: DamageInfo) -> void:
	if info.type != DamageInfo.DamageType.HEAL:
		play("blink", 0)
