@tool
extends GraphFrame
class_name ECSFrame


signal child_node_added(node: GraphNode)
signal child_node_removed(node: GraphNode)


var contained_nodes: Array[GraphNode] = []
var graph_edit: GraphEdit

func _ready():
	graph_edit = get_parent() as GraphEdit
