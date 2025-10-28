@tool
extends EditorPlugin


var node = preload("res://addons/Godov/GodovEditor.tscn")
var inst

func _enter_tree() -> void:
	print("loaded")
	inst = node.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, inst)

func _exit_tree() -> void:
	print("unloaded")
	if inst:
		remove_control_from_docks(inst)
		inst.queue_free()
