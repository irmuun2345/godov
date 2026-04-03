@tool
extends GraphNode
class_name CollectableDisplayComponentNode

var corner: int = 1  # TOP_RIGHT default
var margin: Vector2 = Vector2(16, 16)
var value_name: String = "score"
var label_format: String = "{name}: {value}"
var font_size: int = 16
var font_color: Color = Color.WHITE

var _corner_opt: OptionButton
var _vn_edit: LineEdit
var _fmt_edit: LineEdit
var _fs_spin: SpinBox
var _fc_picker: ColorPickerButton

func _ready() -> void:
	title = "Collectable Display"
	_build_ui()

func _build_ui() -> void:
	# Row 0 — Corner label
	var corner_label = Label.new()
	corner_label.text = "Screen Corner"
	add_child(corner_label)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 1 — Corner option
	_corner_opt = OptionButton.new()
	_corner_opt.add_item("Top Left",     0)
	_corner_opt.add_item("Top Right",    1)
	_corner_opt.add_item("Bottom Left",  2)
	_corner_opt.add_item("Bottom Right", 3)
	_corner_opt.select(corner)
	_corner_opt.item_selected.connect(func(idx): corner = idx)
	add_child(_corner_opt)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 2 — Value Name label
	var vn_label = Label.new()
	vn_label.text = "Value Name"
	add_child(vn_label)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 3 — Value Name edit
	_vn_edit = LineEdit.new()
	_vn_edit.text = value_name
	_vn_edit.placeholder_text = "score"
	_vn_edit.text_changed.connect(func(txt): value_name = txt)
	add_child(_vn_edit)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 4 — Format label
	var fmt_label = Label.new()
	fmt_label.text = "Label Format"
	add_child(fmt_label)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 5 — Format edit
	_fmt_edit = LineEdit.new()
	_fmt_edit.text = label_format
	_fmt_edit.placeholder_text = "{name}: {value}"
	_fmt_edit.text_changed.connect(func(txt): label_format = txt)
	add_child(_fmt_edit)
	set_slot(5, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 6 — Font Size label
	var fs_label = Label.new()
	fs_label.text = "Font Size"
	add_child(fs_label)
	set_slot(6, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 7 — Font Size spin
	_fs_spin = SpinBox.new()
	_fs_spin.min_value = 8
	_fs_spin.max_value = 128
	_fs_spin.step = 1
	_fs_spin.value = font_size
	_fs_spin.value_changed.connect(func(val): font_size = int(val))
	add_child(_fs_spin)
	set_slot(7, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 8 — Font Color row
	var fc_row = HBoxContainer.new()
	var fc_label = Label.new()
	fc_label.text = "Font Color"
	fc_label.custom_minimum_size.x = 80
	fc_row.add_child(fc_label)
	_fc_picker = ColorPickerButton.new()
	_fc_picker.color = font_color
	_fc_picker.custom_minimum_size.x = 80
	_fc_picker.color_changed.connect(func(c): font_color = c)
	fc_row.add_child(_fc_picker)
	add_child(fc_row)
	set_slot(8, false, 0, Color.WHITE, false, 0, Color.WHITE)

func save_state() -> Dictionary:
	return {
		"type":         "CollectableDisplayComponentNode",
		"position":     position_offset,
		"corner":       corner,
		"margin":       margin,
		"value_name":   value_name,
		"label_format": label_format,
		"font_size":    font_size,
		"font_color":   font_color,
	}

func restore_state(data: Dictionary) -> void:
	position_offset = data["position"]
	corner          = data.get("corner",       1)
	margin          = data.get("margin",       Vector2(16, 16))
	value_name      = data.get("value_name",   "score")
	label_format    = data.get("label_format", "{name}: {value}")
	font_size       = data.get("font_size",    16)
	font_color      = data.get("font_color",   Color.WHITE)

	_corner_opt.select(corner)
	_vn_edit.text    = value_name
	_fmt_edit.text   = label_format
	_fs_spin.value   = font_size
	_fc_picker.color = font_color
