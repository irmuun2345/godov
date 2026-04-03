@tool
extends GraphNode
class_name AnimationComponentNode

const STATE_KEYS = ["idle", "run", "jump", "shoot", "hurt"]

const OUTPUT_ROWS = {
	"run":   "movement",
	"jump":  "jump",
	"shoot": "shoot",
	"hurt":  "hurt"
}

var sprite_frames: SpriteFrames = null
var animation_map: Dictionary = {}
var run_threshold: float = 200.0
var _option_buttons: Dictionary = {}
var _picker: EditorResourcePicker

func _ready() -> void:
	title = "Animation Component"
	_build_ui()

func _build_ui() -> void:
	var sf_row = HBoxContainer.new()
	_picker = EditorResourcePicker.new()
	_picker.base_type = "SpriteFrames"
	_picker.custom_minimum_size.x = 180
	_picker.resource_changed.connect(_on_sprite_frames_changed)
	sf_row.add_child(_picker)
	var edit_btn = Button.new()
	edit_btn.text = "Edit"
	edit_btn.pressed.connect(_on_edit_pressed)
	sf_row.add_child(edit_btn)
	add_child(sf_row)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

	for state_key in STATE_KEYS:
		var row = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = state_key
		lbl.custom_minimum_size.x = 50
		row.add_child(lbl)
		var opt = OptionButton.new()
		opt.custom_minimum_size.x = 160
		opt.add_item("[ none ]")
		opt.item_selected.connect(func(idx): _on_anim_selected(state_key, opt))
		row.add_child(opt)
		_option_buttons[state_key] = opt
		add_child(row)
		var slot_idx = get_child_count() - 1
		if OUTPUT_ROWS.has(state_key):
			set_slot(slot_idx, false, 0, Color.WHITE, true, 1, Color(1.0, 0.6, 0.2))
		else:
			set_slot(slot_idx, false, 0, Color.WHITE, false, 0, Color.WHITE)

func _on_sprite_frames_changed(resource: Resource) -> void:
	sprite_frames = resource as SpriteFrames
	_repopulate_options()

func _on_edit_pressed() -> void:
	if sprite_frames:
		EditorInterface.edit_resource(sprite_frames)
	else:
		push_warning("AnimationComponentNode: no SpriteFrames loaded to edit")

func _repopulate_options() -> void:
	var anim_names: Array = []
	if sprite_frames:
		for anim in sprite_frames.get_animation_names():
			anim_names.append(anim)
	for state_key in STATE_KEYS:
		var opt: OptionButton = _option_buttons[state_key]
		opt.clear()
		opt.add_item("[ none ]")
		for anim_name in anim_names:
			opt.add_item(anim_name)
		var saved = animation_map.get(state_key, "")
		if saved != "":
			for i in opt.item_count:
				if opt.get_item_text(i) == saved:
					opt.select(i)
					break

func _on_anim_selected(state_key: String, opt: OptionButton) -> void:
	var selected = opt.get_item_text(opt.selected)
	animation_map[state_key] = "" if selected == "[ none ]" else selected

func get_animation_data() -> Dictionary:
	return {
		"animation_map": animation_map.duplicate(),
		"sprite_frames": sprite_frames.resource_path if sprite_frames else "",
		"run_threshold": run_threshold,
	}

func save_state() -> Dictionary:
	return {
		"type":          "AnimationComponentNode",
		"position":      position_offset,
		"sprite_frames": sprite_frames.resource_path if sprite_frames else "",
		"animation_map": animation_map.duplicate(),
		"run_threshold": run_threshold,
	}

func restore_state(data: Dictionary) -> void:
	position_offset = data["position"]
	run_threshold   = data.get("run_threshold", 200.0)
	animation_map   = data.get("animation_map", {}).duplicate()
	var sf_path: String = data.get("sprite_frames", "")
	if sf_path != "" and ResourceLoader.exists(sf_path):
		sprite_frames = ResourceLoader.load(sf_path) as SpriteFrames
		_picker.edited_resource = sprite_frames
		_repopulate_options()
