extends Node
class_name Component

var owner_entity: Node = null

func _ready() -> void:
	# Auto-initialize when added to scene at runtime
	if get_parent() and not Engine.is_editor_hint():
		on_add_component(get_parent())

func on_add_component(entity: Node) -> void:
	owner_entity = entity

func on_remove_component() -> void:
	owner_entity = null
