@tool
extends GraphNode
class_name MoverComponentNode

var pattern: int = 1
var axis: int = 0
var speed: float = 100.0
var distance: float = 200.0
var clockwise: bool = true
var animation_node_ref: AnimationComponentNode = null

# Direct references
var _anim_label: Label
var _pat_opt: OptionButton
var _axis_label: Label
var _axis_opt: OptionButton
var _spd_spin: SpinBox
var _dist_label: Label
var _dist_spin: SpinBox
var _cw_row: HBoxContainer

func _ready() -> void:
	title = "Mover Component"
	_build_ui()

func _build_ui() -> void:
	# Row 0 — Animation INPUT port FIRST
	_anim_label = Label.new()
	_anim_label.text = "Animation"
	add_child(_anim_label)
	set_slot(0, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)

	# Row 1 — Pattern label
	var pat_label = Label.new()
	pat_label.text = "Pattern"
	add_child(pat_label)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 2 — Pattern option
	_pat_opt = OptionButton.new()
	_pat_opt.add_item("One Direction", 0)
	_pat_opt.add_item("Patrol",        1)
	_pat_opt.add_item("Circular",      2)
	_pat_opt.select(pattern)
	_pat_opt.item_selected.connect(func(idx): pattern = idx; _refresh_visibility())
	add_child(_pat_opt)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 3 — Axis label
	_axis_label = Label.new()
	_axis_label.text = "Axis"
	add_child(_axis_label)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 4 — Axis option
	_axis_opt = OptionButton.new()
	_axis_opt.add_item("Horizontal", 0)
	_axis_opt.add_item("Vertical",   1)
	_axis_opt.select(axis)
	_axis_opt.item_selected.connect(func(idx): axis = idx)
	add_child(_axis_opt)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 5 — Speed label
	var spd_label = Label.new()
	spd_label.text = "Speed"
	add_child(spd_label)
	set_slot(5, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 6 — Speed spin
	_spd_spin = SpinBox.new()
	_spd_spin.min_value = 0
	_spd_spin.max_value = 5000
	_spd_spin.step = 10
	_spd_spin.value = speed
	_spd_spin.value_changed.connect(func(val): speed = val)
	add_child(_spd_spin)
	set_slot(6, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 7 — Distance label
	_dist_label = Label.new()
	_dist_label.text = "Distance"
	add_child(_dist_label)
	set_slot(7, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 8 — Distance spin
	_dist_spin = SpinBox.new()
	_dist_spin.min_value = 0
	_dist_spin.max_value = 10000
	_dist_spin.step = 10
	_dist_spin.value = distance
	_dist_spin.value_changed.connect(func(val): distance = val)
	add_child(_dist_spin)
	set_slot(8, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 9 — Clockwise
	_cw_row = HBoxContainer.new()
	var cw_label = Label.new()
	cw_label.text = "Clockwise"
	_cw_row.add_child(cw_label)
	var cw_check = CheckBox.new()
	cw_check.button_pressed = clockwise
	cw_check.toggled.connect(func(val): clockwise = val)
	_cw_row.add_child(cw_check)
	add_child(_cw_row)
	set_slot(9, false, 0, Color.WHITE, false, 0, Color.WHITE)

	_refresh_visibility()

func _refresh_visibility() -> void:
	var is_circular = pattern == 2
	_axis_label.visible = not is_circular
	_axis_opt.visible   = not is_circular
	_cw_row.visible     = is_circular
	_dist_label.text    = "Radius" if is_circular else "Distance"
	# Always keep animation slot at 0 enabled
	set_slot(0, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)

func restore_state(data: Dictionary) -> void:
	position_offset = data["position"]
	pattern   = data.get("pattern",   1)
	axis      = data.get("axis",      0)
	speed     = data.get("speed",     100.0)
	distance  = data.get("distance",  200.0)
	clockwise = data.get("clockwise", true)
	_pat_opt.select(pattern)
	_axis_opt.select(axis)
	_spd_spin.value = speed
	_dist_spin.value = distance
	(_cw_row.get_child(1) as CheckBox).button_pressed = clockwise
	_refresh_visibility()

func receive_animation_connection(from_node: AnimationComponentNode) -> void:
	animation_node_ref = from_node
	_anim_label.text = "Animation [ connected ]"  # ← use direct reference

func receive_animation_disconnection() -> void:
	animation_node_ref = null
	_anim_label.text = "Animation"  # ← use direct reference

func save_state() -> Dictionary:
	return {
		"type":      "MoverComponentNode",
		"position":  position_offset,
		"pattern":   pattern,
		"axis":      axis,
		"speed":     speed,
		"distance":  distance,
		"clockwise": clockwise,
	}
