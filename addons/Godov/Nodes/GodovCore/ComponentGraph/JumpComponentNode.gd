@tool
extends GraphNode
class_name JumpComponentNode

var jump_force: float = -400.0
var gravity: float = 980.0
var max_jump_count: int = 1
var coyote_time: float = 0.1
var jump_buffer_time: float = 0.1
var connected_actions: Dictionary = {}
var animation_node_ref: AnimationComponentNode = null


func _ready() -> void:
	title = "Jump Component"
	_build_ui()

func receive_connection(to_port: int, from_node: InputComponentNode, from_port: int) -> void:
	var action_name = from_node.get_action_name_for_port(from_port)
	connected_actions["jump"] = action_name
	# slot 10 = child 10
	get_child(10).text = "Jump Action [ " + action_name + " ]"

func receive_disconnection(to_port: int) -> void:
	connected_actions.erase("jump")
	get_child(10).text = "Jump Action [ not connected ]"

func _build_ui() -> void:
	# Row 0 — Jump Force label
	var jf_label = Label.new()
	jf_label.text = "Jump Force"
	add_child(jf_label)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 1 — Jump Force spin
	var jf_spin = SpinBox.new()
	jf_spin.min_value = -5000
	jf_spin.max_value = 0
	jf_spin.step = 10
	jf_spin.value = jump_force
	jf_spin.value_changed.connect(func(val): jump_force = val)
	add_child(jf_spin)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 2 — Gravity label
	var grav_label = Label.new()
	grav_label.text = "Gravity"
	add_child(grav_label)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 3 — Gravity spin
	var grav_spin = SpinBox.new()
	grav_spin.min_value = 0
	grav_spin.max_value = 5000
	grav_spin.step = 10
	grav_spin.value = gravity
	grav_spin.value_changed.connect(func(val): gravity = val)
	add_child(grav_spin)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 4 — Max Jump Count label
	var mjc_label = Label.new()
	mjc_label.text = "Max Jump Count"
	add_child(mjc_label)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 5 — Max Jump Count spin
	var mjc_spin = SpinBox.new()
	mjc_spin.min_value = 1
	mjc_spin.max_value = 10
	mjc_spin.step = 1
	mjc_spin.value = max_jump_count
	mjc_spin.value_changed.connect(func(val): max_jump_count = int(val))
	add_child(mjc_spin)
	set_slot(5, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 6 — Coyote Time label
	var ct_label = Label.new()
	ct_label.text = "Coyote Time"
	add_child(ct_label)
	set_slot(6, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 7 — Coyote Time spin
	var ct_spin = SpinBox.new()
	ct_spin.min_value = 0.0
	ct_spin.max_value = 1.0
	ct_spin.step = 0.01
	ct_spin.value = coyote_time
	ct_spin.value_changed.connect(func(val): coyote_time = val)
	add_child(ct_spin)
	set_slot(7, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 8 — Jump Buffer Time label
	var jbt_label = Label.new()
	jbt_label.text = "Jump Buffer Time"
	add_child(jbt_label)
	set_slot(8, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 9 — Jump Buffer Time spin
	var jbt_spin = SpinBox.new()
	jbt_spin.min_value = 0.0
	jbt_spin.max_value = 1.0
	jbt_spin.step = 0.01
	jbt_spin.value = jump_buffer_time
	jbt_spin.value_changed.connect(func(val): jump_buffer_time = val)
	add_child(jbt_spin)
	set_slot(9, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 10 — Jump Action (INPUT slot, port 0)
	var action_label = Label.new()
	action_label.text = "Jump Action [ not connected ]"
	add_child(action_label)
	set_slot(10, true, 0, Color(0.4, 0.8, 1.0), false, 0, Color.WHITE)

# Animation input port
	var anim_label = Label.new()
	anim_label.text = "Animation"
	add_child(anim_label)
	set_slot(get_child_count() - 1, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)
var animation_data: Dictionary = {}

func receive_animation_connection(from_node: AnimationComponentNode) -> void:
	animation_node_ref = from_node  # ← this was missing
	animation_data = from_node.get_animation_data()
	for i in get_child_count():
		var child = get_child(i)
		if child is Label and child.text == "Animation":
			child.text = "Animation [ connected ]"
			break

func receive_animation_disconnection() -> void:
	animation_node_ref = null  # ← and this
	animation_data = {}
	for i in get_child_count():
		var child = get_child(i)
		if child is Label and child.text.begins_with("Animation"):
			child.text = "Animation"
			break

func apply_to_component(comp: JumpComponent) -> void:
	comp.jump_force = jump_force
	comp.gravity = gravity
	comp.max_jump_count = max_jump_count
	comp.coyote_time = coyote_time
	comp.jump_buffer_time = jump_buffer_time
	if connected_actions.has("jump"):
		comp.jump_action = connected_actions["jump"]

func save_state() -> Dictionary:
	return {
		"type":              "JumpComponentNode",
		"position":          position_offset,
		"jump_force":        jump_force,
		"gravity":           gravity,
		"max_jump_count":    max_jump_count,
		"coyote_time":       coyote_time,
		"jump_buffer_time":  jump_buffer_time,
		"connected_actions": connected_actions.duplicate()
	}

func restore_state(data: Dictionary) -> void:
	position_offset = data["position"]

	(get_child(1) as SpinBox).value = data["jump_force"]
	jump_force = data["jump_force"]

	(get_child(3) as SpinBox).value = data["gravity"]
	gravity = data["gravity"]

	(get_child(5) as SpinBox).value = data["max_jump_count"]
	max_jump_count = data["max_jump_count"]

	(get_child(7) as SpinBox).value = data["coyote_time"]
	coyote_time = data["coyote_time"]

	(get_child(9) as SpinBox).value = data["jump_buffer_time"]
	jump_buffer_time = data["jump_buffer_time"]
