@tool
extends GraphNode
class_name HealthComponentNode

var max_health: float = 100.0
var invincibility_duration: float = 0.5
var die_on_death: bool = false
var display_node_ref: HealthDisplayComponentNode = null

var animation_node_ref: AnimationComponentNode = null
var _anim_label: Label

func _ready() -> void:
	title = "Health Component"
	_build_ui()

func _build_ui() -> void:
	var mh_label = Label.new()
	mh_label.text = "Max Health"
	add_child(mh_label)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var mh_spin = SpinBox.new()
	mh_spin.min_value = 1
	mh_spin.max_value = 99999
	mh_spin.step = 1
	mh_spin.value = max_health
	mh_spin.value_changed.connect(func(val): max_health = val)
	add_child(mh_spin)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var inv_label = Label.new()
	inv_label.text = "Invincibility Duration"
	add_child(inv_label)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var inv_spin = SpinBox.new()
	inv_spin.min_value = 0.0
	inv_spin.max_value = 10.0
	inv_spin.step = 0.05
	inv_spin.value = invincibility_duration
	inv_spin.value_changed.connect(func(val): invincibility_duration = val)
	add_child(inv_spin)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var dod_row = HBoxContainer.new()
	var dod_label = Label.new()
	dod_label.text = "Auto Free on Death"
	dod_row.add_child(dod_label)
	var dod_check = CheckBox.new()
	dod_check.button_pressed = die_on_death
	dod_check.toggled.connect(func(val): die_on_death = val)
	dod_row.add_child(dod_check)
	add_child(dod_row)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Output port — connects to HealthDisplayComponentNode
	var out_label = Label.new()
	out_label.text = "Health Out"
	add_child(out_label)
	set_slot(5, false, 0, Color.WHITE, true, 2, Color(0.8, 0.3, 0.3))
	
	_anim_label = Label.new()
	_anim_label.text = "Animation"
	add_child(_anim_label)
	set_slot(get_child_count() - 1, true, 1, Color(1.0, 0.6, 0.2), false, 0, Color.WHITE)

func receive_animation_connection(from_node: AnimationComponentNode) -> void:
	animation_node_ref = from_node
	_anim_label.text = "Animation [ connected ]"


func receive_animation_disconnection() -> void:
	animation_node_ref = null
	_anim_label.text = "Animation"

func receive_display_connection(from_node: HealthDisplayComponentNode) -> void:
	display_node_ref = from_node

func receive_display_disconnection() -> void:
	display_node_ref = null

func save_state() -> Dictionary:
	return {
		"type":                   "HealthComponentNode",
		"position":               position_offset,
		"max_health":             max_health,
		"invincibility_duration": invincibility_duration,
		"die_on_death":           die_on_death,
	}

func restore_state(data: Dictionary) -> void:
	position_offset        = data["position"]
	max_health             = data.get("max_health", 100.0)
	invincibility_duration = data.get("invincibility_duration", 0.5)
	die_on_death           = data.get("die_on_death", false)
	(get_child(1) as SpinBox).value = max_health
	(get_child(3) as SpinBox).value = invincibility_duration
	(get_child(4).get_child(1) as CheckBox).button_pressed = die_on_death
