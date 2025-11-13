@tool
extends GraphNode

@onready var add_component_button: Button = $VBoxContainer/AddComponentButton


func _ready() -> void:
	add_component_button.pressed.connect(_on_add_component_pressed)
	# Disable slot for the button container
	set_slot(0, false, 0, Color.WHITE, false, 0, Color.WHITE)

func _process(delta: float) -> void:
	pass

func _on_add_component_pressed() -> void:
	add_component_slot()

func add_component_slot() -> void:
	
	var row_hbox := HBoxContainer.new()
	row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	
	var label := Label.new()
	label.text = "Component:"
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	

	var resource_picker := EditorResourcePicker.new()
	resource_picker.base_type = "Component"
	resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_picker.editable = true
	
	
	var remove_button := Button.new()
	remove_button.text = "X"
	remove_button.pressed.connect(_on_remove_slot.bind(row_hbox))
	

	row_hbox.add_child(label)
	row_hbox.add_child(resource_picker)
	row_hbox.add_child(remove_button)
	

	add_child(row_hbox)

	var slot_idx = row_hbox.get_index()

	set_slot(slot_idx, false, 0, Color.WHITE, true, 0, Color.WHITE)

func _on_remove_slot(row: HBoxContainer) -> void:
	var slot_idx = row.get_index()

	set_slot(slot_idx, false, 0, Color.WHITE, false, 0, Color.WHITE)
	row.queue_free()
	
	call_deferred("_rebuild_slots")

func _rebuild_slots() -> void:
	
	for i in range(get_child_count()):
		var child = get_child(i)

		if child == $VBoxContainer:
			set_slot(i, false, 0, Color.WHITE, false, 0, Color.WHITE)
		elif child is HBoxContainer:
			set_slot(i, false, 0, Color.WHITE, true, 0, Color.WHITE)
