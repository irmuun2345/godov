@tool
extends GraphNode
class_name MovementComponentNode

var movement_type: int = 0
var speed: float = 300.0
var connected_actions: Dictionary = {}
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

	# Row 4 — Move Left  (port 0) — always visible
	_make_action_slot("Move Left")
	# Row 5 — Move Right (port 1) — always visible
	_make_action_slot("Move Right")

	# Row 6 — Animation slot — always visible
	var anim_container = HBoxContainer.new()
	var anim_label = Label.new()
	anim_label.text = "Animation"
	anim_container.add_child(anim_label)
	add_child(anim_container)
	_animation_slot_index = get_child_count() - 1  # = 6
	set_slot(_animation_slot_index, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)

	# Row 7 — Move Up   (port 2) — top-down only, AFTER animation
	_make_action_slot("Move Up")
	# Row 8 — Move Down (port 3) — top-down only, AFTER animation
	_make_action_slot("Move Down")

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

	# Move Up (child 7) and Move Down (child 8) — top-down only
	get_child(7).modulate.a = 1.0 if is_top_down else 0.3
	get_child(8).modulate.a = 1.0 if is_top_down else 0.3
	set_slot(7, is_top_down, 0, action_color, false, 0, Color.WHITE)
	set_slot(8, is_top_down, 0, action_color, false, 0, Color.WHITE)

	# Animation slot (child 6) — always on, never touched by movement type
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

func receive_animation_connection(from_node: AnimationComponentNode) -> void:
	animation_node_ref = from_node
	var anim_container = get_child(_animation_slot_index)
	var lbl = anim_container.get_child(0) as Label
	if lbl:
		lbl.text = "Animation [ connected ]"

func receive_animation_disconnection() -> void:
	animation_node_ref = null
	var anim_container = get_child(_animation_slot_index)
	var lbl = anim_container.get_child(0) as Label
	if lbl:
		lbl.text = "Animation"

func _port_to_key(port: int) -> String:
	match port:
		0: return "move_left"
		1: return "move_right"
		2: return "move_up"
		3: return "move_down"
	return ""

func _port_to_slot(port: int) -> int:
	# Move Left=4, Move Right=5, Move Up=7, Move Down=8
	match port:
		0: return 4
		1: return 5
		2: return 7
		3: return 8
	return -1

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
