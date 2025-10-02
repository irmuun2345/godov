@tool
extends EditorPlugin


func _enter_tree() -> void:
	print("loaded")
	
func _exit_tree() -> void:
	print("unloaded")
