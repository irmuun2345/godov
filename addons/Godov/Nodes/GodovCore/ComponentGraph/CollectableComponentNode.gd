@tool
extends GraphNode
class_name CollectableComponentNode

var collect_type: int = 0
var value: float = 20.0
var custom_value_name: String = "score"
var one_time: bool = true
var respawn_time: float = 5.0

var _type_opt: OptionButton
var _value_spin: SpinBox
var _cvn_row: HBoxContainer
var _cvn_edit: LineEdit
var _ot_check: CheckBox
var _rt_spin: SpinBox
var _rt_label: Label
var _rt_row: HBoxContainer

func _ready() -> void:
	title = "Collectable Component"
	_build_ui()

func _build_ui() -> void:
	# Row 0 — Collect Type label
	var ct_label = Label.new()
	ct_label.text = "Collect Type"
	add_child(ct_label)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 1 — Collect Type option
	_type_opt = OptionButton.new()
	_type_opt.add_item("Health",  0)
	_type_opt.add_item("Custom",  1)
	_type_opt.select(collect_type)
	_type_opt.item_selected.connect(func(idx):
		collect_type = idx
		_refresh_visibility()
	)
	add_child(_type_opt)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 2 — Value label
	var val_label = Label.new()
	val_label.text = "Value"
	add_child(val_label)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 3 — Value spin
	_value_spin = SpinBox.new()
	_value_spin.min_value = 0
	_value_spin.max_value = 99999
	_value_spin.step = 1
	_value_spin.value = value
	_value_spin.value_changed.connect(func(val): value = val)
	add_child(_value_spin)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 4 — Custom Value Name row (custom type only)
	_cvn_row = HBoxContainer.new()
	var cvn_label = Label.new()
	cvn_label.text = "Value Name"
	cvn_label.custom_minimum_size.x = 80
	_cvn_row.add_child(cvn_label)
	_cvn_edit = LineEdit.new()
	_cvn_edit.text = custom_value_name
	_cvn_edit.custom_minimum_size.x = 120
	_cvn_edit.text_changed.connect(func(txt): custom_value_name = txt)
	_cvn_row.add_child(_cvn_edit)
	add_child(_cvn_row)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 5 — One Time row
	var ot_row = HBoxContainer.new()
	var ot_label = Label.new()
	ot_label.text = "One Time"
	ot_label.custom_minimum_size.x = 80
	ot_row.add_child(ot_label)
	_ot_check = CheckBox.new()
	_ot_check.button_pressed = one_time
	_ot_check.toggled.connect(func(val):
		one_time = val
		_refresh_visibility()
	)
	ot_row.add_child(_ot_check)
	add_child(ot_row)
	set_slot(5, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 6 — Respawn Time label
	_rt_label = Label.new()
	_rt_label.text = "Respawn Time"
	add_child(_rt_label)
	set_slot(6, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 7 — Respawn Time spin
	_rt_row = HBoxContainer.new()
	_rt_spin = SpinBox.new()
	_rt_spin.min_value = 0.5
	_rt_spin.max_value = 300.0
	_rt_spin.step = 0.5
	_rt_spin.value = respawn_time
	_rt_spin.value_changed.connect(func(val): respawn_time = val)
	_rt_row.add_child(_rt_spin)
	add_child(_rt_row)
	set_slot(7, false, 0, Color.WHITE, false, 0, Color.WHITE)

	_refresh_visibility()

func _refresh_visibility() -> void:
	_cvn_row.visible  = collect_type == 1
	_rt_label.visible = not one_time
	_rt_row.visible   = not one_time

func save_state() -> Dictionary:
	return {
		"type":              "CollectableComponentNode",
		"position":          position_offset,
		"collect_type":      collect_type,
		"value":             value,
		"custom_value_name": custom_value_name,
		"one_time":          one_time,
		"respawn_time":      respawn_time,
	}

func restore_state(data: Dictionary) -> void:
	position_offset   = data["position"]
	collect_type      = data.get("collect_type",      0)
	value             = data.get("value",             20.0)
	custom_value_name = data.get("custom_value_name", "score")
	one_time          = data.get("one_time",          true)
	respawn_time      = data.get("respawn_time",      5.0)

	_type_opt.select(collect_type)
	_value_spin.value = value
	_cvn_edit.text    = custom_value_name
	_ot_check.button_pressed = one_time
	_rt_spin.value    = respawn_time
	_refresh_visibility()
