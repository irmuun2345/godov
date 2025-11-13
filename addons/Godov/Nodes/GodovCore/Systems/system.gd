extends Node

class_name System ## It is base system

@export var active:bool = true

var entities:Array[Entity]

func _process(delta: float) -> void:
	if not active:
		return


func get_entites() -> Array:
	return []

func process_entity(entity:Entity, delta:float) -> void:
	pass
