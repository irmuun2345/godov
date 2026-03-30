@tool
extends GraphNode
class_name InputComponentNode

var action_rows: Array = []
var _listening_button: Button = null

func _ready() -> void:
	title = "Input Component"
	
	# Add button to create new rows
	var add_btn = Button.new()
	add_btn.text = "+ Add Action"
	add_btn.pressed.connect(func(): _add_action_row("", KEY_NONE))
	add_child(add_btn)
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

func _add_action_row(action_name: String, default_key: Key = KEY_NONE) -> void:
	var slot_index = get_child_count()

	var row = HBoxContainer.new()
	add_child(row)

	# Action name
	var name_edit = LineEdit.new()
	name_edit.text = action_name
	name_edit.custom_minimum_size.x = 130
	name_edit.placeholder_text = "action_name"
	name_edit.text_changed.connect(func(new_text):
		_register_action(new_text, _get_keycode_for_row(row))
	)
	row.add_child(name_edit)

	# Key capture button
	var key_btn = Button.new()
	key_btn.custom_minimum_size.x = 90
	key_btn.text = OS.get_keycode_string(default_key) if default_key != KEY_NONE else "[ none ]"
	key_btn.toggle_mode = true
	key_btn.toggled.connect(func(active): _on_listen_toggled(active, key_btn))
	row.add_child(key_btn)

	# Remove button
	var remove_btn = Button.new()
	remove_btn.text = "X"
	remove_btn.pressed.connect(func(): _remove_action_row(row, slot_index))
	row.add_child(remove_btn)

	action_rows.append({
		"row":      row,
		"name_edit": name_edit,
		"key_btn":   key_btn,
		"keycode":   default_key,
		"slot":      slot_index
	})

	set_slot(slot_index, false, 0, Color.WHITE, true, 0, Color(0.4, 1.0, 0.5))

	# Only register if both name and key are set
	if action_name != "" and default_key != KEY_NONE:
		_register_action(action_name, default_key)

func _remove_action_row(row: HBoxContainer, slot_index: int) -> void:
	# Unregister from InputMap and ProjectSettings
	for r in action_rows:
		if r.row == row:
			var action_name: String = r.name_edit.text
			_unregister_action(action_name)
			action_rows.erase(r)
			break

	set_slot(slot_index, false, 0, Color.WHITE, false, 0, Color.WHITE)
	row.queue_free()

func _register_action(action_name: String, keycode: Key) -> void:
	if action_name == "" or keycode == KEY_NONE:
		return  # Don't register incomplete rows

	var event = InputEventKey.new()
	event.keycode = keycode

	var action_info = {
		"deadzone": 0.5,
		"events": [event]
	}
	ProjectSettings.set_setting("input/" + action_name, action_info)
	ProjectSettings.save()

	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	else:
		InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)

	print("Godov: registered '", action_name, "' -> ", OS.get_keycode_string(keycode))

func _unregister_action(action_name: String) -> void:
	if action_name == "":
		return
	if ProjectSettings.has_setting("input/" + action_name):
		ProjectSettings.set_setting("input/" + action_name, null)
		ProjectSettings.save()
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)
	print("Godov: unregistered '", action_name, "'")

func _get_keycode_for_row(row: HBoxContainer) -> Key:
	for r in action_rows:
		if r.row == row:
			return r.keycode
	return KEY_NONE

func _on_listen_toggled(active: bool, btn: Button) -> void:
	if active:
		if _listening_button and _listening_button != btn:
			_listening_button.button_pressed = false
			_listening_button.text = _get_label_for_button(_listening_button)
		_listening_button = btn
		btn.text = "[ press key... ]"
	else:
		if _listening_button == btn:
			_listening_button = null

func _input(event: InputEvent) -> void:
	if not _listening_button or not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return

	for row in action_rows:
		if row.key_btn == _listening_button:
			row.keycode = event.keycode
			_register_action(row.name_edit.text, event.keycode)
			_listening_button.text = OS.get_keycode_string(event.keycode)
			_listening_button.button_pressed = false
			_listening_button = null
			get_viewport().set_input_as_handled()
			break

func _get_label_for_button(btn: Button) -> String:
	for row in action_rows:
		if row.key_btn == btn:
			return OS.get_keycode_string(row.keycode) if row.keycode != KEY_NONE else "[ none ]"
	return "[ none ]"

func get_action_name_for_port(port: int) -> String:
	# Port 0 = first action row. Add button is child 0 with no output port.
	# So port index maps directly to action_rows array index.
	if port < action_rows.size():
		return action_rows[port].name_edit.text
	return ""

func get_action_name_for_slot(slot_index: int) -> String:
	for row in action_rows:
		if row.slot == slot_index:
			return row.name_edit.text
	return ""

func get_keycode_for_slot(slot_index: int) -> Key:
	for row in action_rows:
		if row.slot == slot_index:
			return row.keycode
	return KEY_NONE

#func _exit_tree() -> void:
	#if not Engine.is_editor_hint():
		#return
	#for row in action_rows:
		#_unregister_action(row.name_edit.text)

func save_state() -> Dictionary:
	var actions_data = []
	for row in action_rows:
		actions_data.append({
			"name":    row.name_edit.text,
			"keycode": row.keycode
		})
	return {
		"type":     "InputComponentNode",
		"position": position_offset,
		"actions":  actions_data
	}

func restore_state(data: Dictionary) -> void:
	position_offset = data["position"]
	for entry in data["actions"]:
		_add_action_row(entry["name"], entry["keycode"] as Key)
