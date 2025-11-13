extends Node2D
class_name Entity ## It is base entity
@export var entity_name = ""
@export var components: Array[Component] = []


func _ready() -> void:
	if get_parent().has_node("AnimatedSprite2D"):
		
		get_component("AnimationComponent").set_animated_sprite(get_parent().get_node("AnimatedSprite2D"))

func get_component(component_class_name: String) -> Component:
	for component in components:
		
		if component.component_name == component_class_name:
			
			return component
			
	return null


func add_component(component: Component) -> void:
	components.append(component)
	component.on_add_component(self)


func remove_component(component: Component) -> Component:
	var index = components.find(component)
	if index != -1:
		component.on_remove_component()
		return components.pop_at(index)
	return null
