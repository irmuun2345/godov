extends Component
class_name InputComponent

# action_name -> Key (keycode) — set by CharacterBuilder before _ready runs
var actions: Dictionary = {}

func _ready() -> void:
	super._ready()
	for action_name in actions.keys():
		var keycode = actions[action_name]
		_register_to_input_map(action_name, keycode)

## Internal: register a key into InputMap without touching actions dict
func _register_to_input_map(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	else:
		InputMap.action_erase_events(action_name)
	var event = InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action_name, event)

## Add a new action to InputMap
func add_action(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	actions[action_name] = KEY_NONE

## Add keyboard key to action
func add_key_input(action_name: String, keycode: Key) -> void:
	actions[action_name] = keycode
	_register_to_input_map(action_name, keycode)

## Add mouse button to action
func add_mouse_input(action_name: String, button_index: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event = InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action_name, event)

## Add gamepad button to action
func add_gamepad_button(action_name: String, button: JoyButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event = InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action_name, event)

## Add gamepad axis to action
func add_gamepad_axis(action_name: String, axis: JoyAxis, value: float = 1.0) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action_name, event)

## Remove action
func remove_action(action_name: String) -> void:
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)
	actions.erase(action_name)

## Clear all inputs from action
func clear_action_inputs(action_name: String) -> void:
	if InputMap.has_action(action_name):
		InputMap.action_erase_events(action_name)

## Check if action is pressed
func is_action_pressed(action_name: String) -> bool:
	return Input.is_action_pressed(action_name)

func is_action_just_pressed(action_name: String) -> bool:
	return Input.is_action_just_pressed(action_name)

func is_action_just_released(action_name: String) -> bool:
	return Input.is_action_just_released(action_name)

## Cleanup on remove
func on_remove_component() -> void:
	for action_name in actions.keys():
		remove_action(action_name)
	super.on_remove_component()
