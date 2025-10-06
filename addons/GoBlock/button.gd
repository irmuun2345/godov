
@tool
extends Control

@export var scene_path: String = "res://path/to/scene.tscn" ## These scene will intiate when

func _get_drag_data(position: Vector2):
	# Create drag preview
	var preview = Label.new()
	
	set_drag_preview(preview)
	
	# Return scene file path
	return {
		"type": "files",
		"files": [scene_path],
		"from": self
	}
