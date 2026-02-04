extends AnimationPlayer

func _ready() -> void:
	var health_comp := HealthComponent.Get(get_parent())
	if health_comp != null:
		health_comp.connect("was_hit", Callable(self, "_on_health_was_hit"))

func _on_health_was_hit(info: DamageInfo) -> void:
	if info.type != DamageInfo.DamageType.HEAL:
		play("blink", 0)
