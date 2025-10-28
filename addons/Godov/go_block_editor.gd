@tool
extends Control

# Reference to the scene you want to instantiate when dropped
var scene_to_instantiate = preload("res://addons/Godov/drop.tscn")


func _ready():

	pass

# This function is called when you start dragging from this control
func _get_drag_data(position: Vector2):
	# Create preview for dragging
	var preview = Label.new()
	preview.text = "Godov Node"
	set_drag_preview(preview)
	
	# Return the data you want to pass (the scene path or PackedScene)
	return {
		"type": "files",
		"files": [scene_to_instantiate.resource_path],
		"from": self
	}
