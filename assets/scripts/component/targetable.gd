class_name Targetable

extends Node

@export var tags: Array[String] = []

static var component_name: String = "targetable"
static func Is(node: Node) -> bool:
	if node == null:
		return false
	
	if node.has_node(component_name):
		assert(node.get_node(component_name) is Targetable, "Node has a "+component_name+" component but it's type is wrong.")
		return true
	return false
static func Get(node: Node) -> Targetable:
	if Is(node):
		return node.get_node(component_name)
	return null

func _ready() -> void:
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")

func has_tag(tag: String) -> bool:
	return tag in tags

func has_any_tag(tag_list: Array[String]) -> bool:
	for tag in tag_list:
		if tag in tags:
			return true

	return false