extends Node2D  # or Node, CharacterBody2D, Area2D, etc.
class_name Entity

var components: Dictionary = {}  # component_name -> Component

func add_component(component: Component) -> void:
	if component.component_name.is_empty():
		push_error("Component must have a component_name")
		return
	
	components[component.component_name] = component
	add_child(component)
	component.on_add_component(self)

func remove_component(component_name: String) -> void:
	if components.has(component_name):
		var component = components[component_name]
		component.on_remove_component()
		components.erase(component_name)

func get_component(component_name: String) -> Component:
	return components.get(component_name)

func has_component(component_name: String) -> bool:
	return components.has(component_name)
