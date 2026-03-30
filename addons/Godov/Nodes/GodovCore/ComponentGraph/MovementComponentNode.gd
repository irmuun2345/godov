@tool
extends GraphNode
class_name MovementComponentNode

var movement_type: int = 0
var speed: float = 300.0
var connected_actions: Dictionary = {}  # key -> action_name, purely from connections
var animation_data: Dictionary = {}
var _animation_slot_index: int = -1


var animation_node_ref: AnimationComponentNode = null
func _ready() -> void:
	title = "Movement Component"
	_build_ui()

func _build_ui() -> void:
	# Row 0 — Movement Type label
	var type_label = Label.new()
	type_label.text = "Movement Type"
	add_child(type_label)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 1 — OptionButton
	var type_option = OptionButton.new()
	type_option.add_item("Platformer", 0)
	type_option.add_item("Top Down", 1)
	type_option.item_selected.connect(func(idx):
		movement_type = idx
		_refresh_slots()
	)
	add_child(type_option)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 2 — Speed label
	var speed_label = Label.new()
	speed_label.text = "Speed"
	add_child(speed_label)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 3 — SpinBox
	var speed_spin = SpinBox.new()
	speed_spin.min_value = 0
	speed_spin.max_value = 5000
	speed_spin.step = 10
	speed_spin.value = speed
	speed_spin.value_changed.connect(func(val): speed = val)
	add_child(speed_spin)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Rows 4–7 — action input slots
	_make_action_slot("Move Left")   # child 4, input port 0
	_make_action_slot("Move Right")  # child 5, input port 1
	_make_action_slot("Move Up")     # child 6, input port 2
	_make_action_slot("Move Down")   # child 7, input port 3

	var anim_label = Label.new()
	anim_label.text = "Animation"
	add_child(anim_label)
	_animation_slot_index = get_child_count() - 1
	set_slot(_animation_slot_index, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)


	_refresh_slots()

func _make_action_slot(label_text: String) -> void:
	var slot_index = get_child_count()
	var label = Label.new()
	label.text = label_text + " [ not connected ]"
	add_child(label)
	set_slot(slot_index, true, 0, Color(0.4, 0.8, 1.0), false, 0, Color.WHITE)

func _refresh_slots() -> void:
	var is_top_down = movement_type == 1
	var action_color = Color(0.4, 0.8, 1.0)
	get_child(6).visible = is_top_down
	get_child(7).visible = is_top_down
	set_slot(6, is_top_down, 0, action_color, false, 0, Color.WHITE)
	set_slot(7, is_top_down, 0, action_color, false, 0, Color.WHITE)
	# Always keep animation slot enabled regardless of movement type
	if _animation_slot_index != -1:
		set_slot(_animation_slot_index, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)

func receive_connection(to_port: int, from_node: InputComponentNode, from_port: int) -> void:
	var action_name := from_node.get_action_name_for_port(from_port)
	var key := _port_to_key(to_port)
	connected_actions[key] = action_name
	get_child(_port_to_slot(to_port)).text = _slot_label_for_key(key) + " [ " + action_name + " ]"

func receive_disconnection(to_port: int) -> void:
	var key := _port_to_key(to_port)
	connected_actions.erase(key)
	get_child(_port_to_slot(to_port)).text = _slot_label_for_key(key) + " [ not connected ]"
	
	var animation_data: Dictionary = {}

func receive_animation_connection(from_node: AnimationComponentNode) -> void:
	animation_node_ref = from_node
	# Update label
	for i in get_child_count():
		var child = get_child(i)
		if child is Label and child.text.begins_with("Animation"):
			child.text = "Animation [ connected ]"
			break

func receive_animation_disconnection() -> void:
	animation_node_ref = null
	for i in get_child_count():
		var child = get_child(i)
		if child is Label and child.text.begins_with("Animation"):
			child.text = "Animation"
			break

func _port_to_key(port: int) -> String:
	match port:
		0: return "move_left"
		1: return "move_right"
		2: return "move_up"
		3: return "move_down"
	return ""

func _port_to_slot(port: int) -> int:
	return port + 4  # children 4, 5, 6, 7

func _slot_label_for_key(key: String) -> String:
	match key:
		"move_left":  return "Move Left"
		"move_right": return "Move Right"
		"move_up":    return "Move Up"
		"move_down":  return "Move Down"
	return ""

func save_state() -> Dictionary:
	return {
		"type":              "MovementComponentNode",
		"position":          position_offset,
		"movement_type":     movement_type,
		"speed":             speed,
		"connected_actions": connected_actions.duplicate()
	}

func restore_state(data: Dictionary) -> void:
	position_offset = data["position"]

	(get_child(3) as SpinBox).value = data["speed"]
	speed = data["speed"]

	var type_option := get_child(1) as OptionButton
	type_option.select(data["movement_type"])
	type_option.item_selected.emit(data["movement_type"])
