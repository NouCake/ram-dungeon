class_name HealthComponent

extends Node

@export var current_health := 5
@export var max_health := 5
@export var auto_delete := true
@export var invulnerable := false

signal was_hit(info: DamageInfo)

static var component_name: String = "health"
static func Is(node: Node) -> bool:
	if node == null:
		return false
	
	if node.has_node(component_name):
		assert(node.get_node(component_name) is HealthComponent, "Node has a "+component_name+" component but it's type is wrong.")
		return true
	return false
static func Get(node: Node) -> HealthComponent:
	if Is(node):
		return node.get_node(component_name)
	return null

func _ready() -> void:
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")

func do_damage(info: DamageInfo) -> void:
	was_hit.emit(info)
	Global.damage.emit(info)
	
	if invulnerable:
		return

	if info.type == DamageInfo.DamageType.HEAL:
		# Healing - amount is positive, restore health
		current_health = min(current_health + info.amount, max_health)
	else:
		# Damage - subtract health
		current_health -= info.amount
	
	if auto_delete && current_health <= 0:
		get_parent().queue_free()
	
