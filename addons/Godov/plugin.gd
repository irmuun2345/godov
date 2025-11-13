@tool
extends EditorPlugin
var node = preload("res://addons/Godov/GodovEditor.tscn")
var inst

func _enter_tree() -> void:
	print("loaded")
	inst = node.instantiate()
	# Add as a main screen (like 2D, 3D, Script)
	get_editor_interface().get_editor_main_screen().add_child(inst)
	# Hide it initially
	_make_visible(false)

func _exit_tree() -> void:
	print("unloaded")
	if inst:
		inst.queue_free()

# This tells Godot your plugin has a main screen
func _has_main_screen() -> bool:
	return true

# This is the name that appears on the button
func _get_plugin_name() -> String:
	return "Godov"

# This is the icon for your button (optional)
func _get_plugin_icon() -> Texture2D:
	# You can return a custom icon here
	# return preload("res://addons/Godov/icon.svg")
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

# Called when switching to/from your screen
func _make_visible(visible: bool) -> void:
	if inst:
		inst.visible = visible
