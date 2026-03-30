# component_graph_node.gd (base class)
extends GraphNode
class_name ComponentGraphNode

@export var component_type: String
var properties: Dictionary = {}

func _ready():
	setup_ports()
	setup_ui()

func setup_ports():
	# Override in child classes
	pass

func setup_ui():
	# Override in child classes
	pass

#func get_component_data() -> ComponentData:
	#var data = ComponentData.new(component_type, position_offset)
	#data.properties = properties.duplicate()
	#return data
#
#func load_component_data(data: ComponentData):
	#position_offset = data.position
	#properties = data.properties.duplicate()
	#apply_properties()

func apply_properties():
	# Override in child classes
	pass
