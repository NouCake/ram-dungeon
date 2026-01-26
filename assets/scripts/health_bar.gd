extends TextureProgressBar

var health_component: HealthComponent

func _ready():
	health_component = get_parent().get_node("health") as HealthComponent
	assert(health_component != null, "HealthBar requires a HealthComponent as a sibling node named")
	max_value = health_component.max_health
	value = health_component.current_health
	health_component.connect("health_changed", Callable(self, "update_health"))

func update_health():
	value = health_component.current_health