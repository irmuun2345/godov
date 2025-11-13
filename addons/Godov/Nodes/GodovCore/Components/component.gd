extends Resource

class_name Component ## It is base component

@export var component_name:String = ""

var owner_entity:Node2D

func on_add_component(entity) -> void:
	owner_entity = entity

func on_remove_component() -> void:
	owner_entity = null
