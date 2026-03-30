@tool
extends GraphNode
class_name HealthDisplayComponentNode

enum DisplayPosition { HUD_TOP_LEFT, HUD_TOP_RIGHT, HUD_BOTTOM_LEFT, HUD_BOTTOM_RIGHT, ABOVE_CHARACTER }

var style: int = 0
var display_position: int = 0
var margin: Vector2 = Vector2(16, 16)
var above_offset: Vector2 = Vector2(0, -60)  # offset above character
var bar_size: Vector2 = Vector2(200, 20)
var bar_color: Color = Color(0.2, 0.8, 0.2)
var bar_bg_color: Color = Color(0.2, 0.2, 0.2)
var max_hearts: int = 5
var heart_size: int = 32
var heart_full_color: Color = Color(0.9, 0.1, 0.1)
var heart_empty_color: Color = Color(0.3, 0.3, 0.3)

func _ready() -> void:
	title = "Health Display"
	_build_ui()

func _build_ui() -> void:
	# Input port — receives from HealthComponentNode
	var in_label = Label.new()
	in_label.text = "Health In"
	add_child(in_label)
	set_slot(0, true, 2, Color(0.8, 0.3, 0.3), false, 0, Color.WHITE)

	# Style
	var style_label = Label.new()
	style_label.text = "Display Style"
	add_child(style_label)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var style_option = OptionButton.new()
	style_option.add_item("Bar", 0)
	style_option.add_item("Hearts", 1)
	style_option.item_selected.connect(func(idx):
		style = idx
		_refresh_visibility()
	)
	add_child(style_option)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Position
	var pos_label = Label.new()
	pos_label.text = "Position"
	add_child(pos_label)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var pos_option = OptionButton.new()
	pos_option.add_item("HUD Top Left",     0)
	pos_option.add_item("HUD Top Right",    1)
	pos_option.add_item("HUD Bottom Left",  2)
	pos_option.add_item("HUD Bottom Right", 3)
	pos_option.add_item("Above Character",  4)
	pos_option.item_selected.connect(func(idx):
		display_position = idx
		_refresh_offset_visibility()
	)
	add_child(pos_option)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# HUD Margin
	var margin_label = Label.new()
	margin_label.text = "HUD Margin"
	add_child(margin_label)
	set_slot(5, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var margin_row = HBoxContainer.new()
	var mx = SpinBox.new()
	mx.min_value = 0; mx.max_value = 500; mx.value = margin.x
	mx.value_changed.connect(func(val): margin.x = val)
	margin_row.add_child(mx)
	var my = SpinBox.new()
	my.min_value = 0; my.max_value = 500; my.value = margin.y
	my.value_changed.connect(func(val): margin.y = val)
	margin_row.add_child(my)
	add_child(margin_row)
	set_slot(6, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Above character offset
	var offset_label = Label.new()
	offset_label.text = "Above Offset"
	add_child(offset_label)
	set_slot(7, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var offset_row = HBoxContainer.new()
	var ox = SpinBox.new()
	ox.min_value = -500; ox.max_value = 500; ox.value = above_offset.x
	ox.value_changed.connect(func(val): above_offset.x = val)
	offset_row.add_child(ox)
	var oy = SpinBox.new()
	oy.min_value = -500; oy.max_value = 500; oy.value = above_offset.y
	oy.value_changed.connect(func(val): above_offset.y = val)
	offset_row.add_child(oy)
	add_child(offset_row)
	set_slot(8, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Bar section
	var bar_header = Label.new()
	bar_header.text = "── Bar ──"
	add_child(bar_header)
	set_slot(9, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var bar_color_row = HBoxContainer.new()
	var bcl = Label.new(); bcl.text = "Fill Color"; bcl.custom_minimum_size.x = 80
	bar_color_row.add_child(bcl)
	var bcp = ColorPickerButton.new(); bcp.color = bar_color; bcp.custom_minimum_size.x = 80
	bcp.color_changed.connect(func(c): bar_color = c)
	bar_color_row.add_child(bcp)
	add_child(bar_color_row)
	set_slot(10, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var bar_bg_row = HBoxContainer.new()
	var bbgl = Label.new(); bbgl.text = "BG Color"; bbgl.custom_minimum_size.x = 80
	bar_bg_row.add_child(bbgl)
	var bbgp = ColorPickerButton.new(); bbgp.color = bar_bg_color; bbgp.custom_minimum_size.x = 80
	bbgp.color_changed.connect(func(c): bar_bg_color = c)
	bar_bg_row.add_child(bbgp)
	add_child(bar_bg_row)
	set_slot(11, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Hearts section
	var hearts_header = Label.new()
	hearts_header.text = "── Hearts ──"
	add_child(hearts_header)
	set_slot(12, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var mh_row = HBoxContainer.new()
	var mhl = Label.new(); mhl.text = "Max Hearts"; mhl.custom_minimum_size.x = 80
	mh_row.add_child(mhl)
	var mhs = SpinBox.new(); mhs.min_value = 1; mhs.max_value = 20; mhs.value = max_hearts
	mhs.value_changed.connect(func(val): max_hearts = int(val))
	mh_row.add_child(mhs)
	add_child(mh_row)
	set_slot(13, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var hfc_row = HBoxContainer.new()
	var hfcl = Label.new(); hfcl.text = "Full Color"; hfcl.custom_minimum_size.x = 80
	hfc_row.add_child(hfcl)
	var hfcp = ColorPickerButton.new(); hfcp.color = heart_full_color; hfcp.custom_minimum_size.x = 80
	hfcp.color_changed.connect(func(c): heart_full_color = c)
	hfc_row.add_child(hfcp)
	add_child(hfc_row)
	set_slot(14, false, 0, Color.WHITE, false, 0, Color.WHITE)

	var hec_row = HBoxContainer.new()
	var hecl = Label.new(); hecl.text = "Empty Color"; hecl.custom_minimum_size.x = 80
	hec_row.add_child(hecl)
	var hecp = ColorPickerButton.new(); hecp.color = heart_empty_color; hecp.custom_minimum_size.x = 80
	hecp.color_changed.connect(func(c): heart_empty_color = c)
	hec_row.add_child(hecp)
	add_child(hec_row)
	set_slot(15, false, 0, Color.WHITE, false, 0, Color.WHITE)

	_refresh_visibility()
	_refresh_offset_visibility()

func _refresh_visibility() -> void:
	var is_bar = style == 0
	for i in [9, 10, 11]: get_child(i).visible = is_bar
	for i in [12, 13, 14, 15]: get_child(i).visible = not is_bar

func _refresh_offset_visibility() -> void:
	var is_above = display_position == 4
	get_child(7).visible = is_above  # offset label
	get_child(8).visible = is_above  # offset row
	get_child(5).visible = not is_above  # margin label
	get_child(6).visible = not is_above  # margin row

func save_state() -> Dictionary:
	return {
		"type":               "HealthDisplayComponentNode",
		"position":           position_offset,
		"style":              style,
		"display_position":   display_position,
		"margin":             margin,
		"above_offset":       above_offset,
		"bar_color":          bar_color,
		"bar_bg_color":       bar_bg_color,
		"max_hearts":         max_hearts,
		"heart_size":         heart_size,
		"heart_full_color":   heart_full_color,
		"heart_empty_color":  heart_empty_color,
	}

func restore_state(data: Dictionary) -> void:
	position_offset  = data["position"]
	style            = data.get("style", 0)
	display_position = data.get("display_position", 0)
	margin           = data.get("margin", Vector2(16, 16))
	above_offset     = data.get("above_offset", Vector2(0, -60))
	bar_color        = data.get("bar_color", Color(0.2, 0.8, 0.2))
	bar_bg_color     = data.get("bar_bg_color", Color(0.2, 0.2, 0.2))
	max_hearts       = data.get("max_hearts", 5)
	heart_size       = data.get("heart_size", 32)
	heart_full_color  = data.get("heart_full_color", Color(0.9, 0.1, 0.1))
	heart_empty_color = data.get("heart_empty_color", Color(0.3, 0.3, 0.3))
	(get_child(2) as OptionButton).select(style)
	(get_child(4) as OptionButton).select(display_position)
	_refresh_visibility()
	_refresh_offset_visibility()
