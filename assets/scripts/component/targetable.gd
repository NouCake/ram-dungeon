class_name Targetable

extends Node

@export var tags: Array[String] = []

static var component_name: String = "targetable"

func _ready():
	assert(name == component_name, "Component must be named " + component_name + " to be recognized by other components.")

func has_tag(tag: String) -> bool:
	return tag in tags

func has_any_tag(tag_list: Array[String]) -> bool:
	for tag in tag_list:
		if tag in tags:
			return true

	return false