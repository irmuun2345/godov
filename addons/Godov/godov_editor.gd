@tool
extends GraphEdit

func _ready():
	add_valid_connection_type(0, 0)
	add_valid_connection_type(0, 1)
	add_valid_connection_type(1, 0)
	add_valid_connection_type(1, 1)
	
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	# Try to find nodes even if they're inside GraphFrames
	var from = get_node_or_null(NodePath(from_node))
	var to = get_node_or_null(NodePath(to_node))
	
	if from and to:
		connect_node(from_node, from_port, to_node, to_port)
		print("Connected: ", from_node, " -> ", to_node)
	else:
		print("Could not find nodes: ", from_node, " or ", to_node)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	disconnect_node(from_node, from_port, to_node, to_port)
