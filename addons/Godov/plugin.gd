@tool
extends EditorPlugin
var node = preload("res://addons/Godov/GodovEditor.tscn")
var inst

func _enter_tree() -> void:
	
	inst = node.instantiate()
	# Add to bottom panel (like Output, Debugger, etc.)
	add_control_to_bottom_panel(inst, "Godov")

func _exit_tree() -> void:
	
	if inst:
		remove_control_from_bottom_panel(inst)
		inst.queue_free()
