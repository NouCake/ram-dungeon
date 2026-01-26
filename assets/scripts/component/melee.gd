class_name MeleeComponent

extends Node

@export var melee_damage: int = 2
@export var melee_range: float = 115
@export var melee_cooldown: float = 0.5

var time_since_last_attack: float = melee_cooldown
var finder: TargetFinderComponent;

func _ready() -> void:
	finder = get_parent().get_node_or_null("finder")

func _process(delta: float) -> void:
	time_since_last_attack += delta
	if time_since_last_attack >= melee_cooldown:
		attack()

func attack() -> void:
	var parent: Node2D = get_parent()
	var targets := finder._get_all_near_targets()

	if targets.size() <= 0:
		#print("No targets found for melee attack")
		return;

	var targets_in_range = targets.filter(func(t):
		if !t.get_node("health"):
			#print("Target has no health component: " )
			return false
		var distance = (parent.global_position - t.global_position).length();
		return distance <= melee_range
	)

	if targets_in_range.size() <= 0:
		return;
	#print("Melee attack!")
	
	for target in targets_in_range:
		var health = target.get_node("health") as HealthComponent
		health.do_damage(melee_damage, parent)

	time_since_last_attack = 0
	pass
