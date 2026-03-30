@tool
extends GraphEdit

var input_node: InputComponentNode
var movement_node: MovementComponentNode
var jump_node: JumpComponentNode
var save_path_edit: LineEdit
var build_button: Button
var animation_node: AnimationComponentNode
var _is_loading := false
var health_node: HealthComponentNode
var health_display_node: HealthDisplayComponentNode
var _state_name_label: Label  # ← store direct reference
var mover_node: MoverComponentNode
var shoot_node: ShootComponentNode
var collectable_node: CollectableComponentNode
@export var toolbar_container: Control
var _current_state_path: String = ""
const LAST_FILE_PATH = "res://addons/Godov/.last_state"

func _ready():
	add_valid_connection_type(0, 0)
	add_valid_connection_type(1, 1)
	add_valid_connection_type(2, 2)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)

	if not toolbar_container:
		push_error("GodovEditor: toolbar_container not assigned!")
		return

	build_button = Button.new()
	build_button.text = "▶ Build Character"
	build_button.pressed.connect(_on_build_pressed)
	toolbar_container.add_child(build_button)

	save_path_edit = LineEdit.new()
	save_path_edit.text = "res://Character.tscn"
	save_path_edit.custom_minimum_size.x = 300
	toolbar_container.add_child(save_path_edit)

	var new_btn = Button.new()
	new_btn.text = "🗋 New"
	new_btn.pressed.connect(_on_new_pressed)
	toolbar_container.add_child(new_btn)

	var open_btn = Button.new()
	open_btn.text = "📂 Open"
	open_btn.pressed.connect(_on_open_pressed)
	toolbar_container.add_child(open_btn)

	var save_btn = Button.new()
	save_btn.text = "💾 Save"
	save_btn.pressed.connect(_on_save_pressed)
	toolbar_container.add_child(save_btn)

	var save_as_btn = Button.new()
	save_as_btn.text = "💾 Save As"
	save_as_btn.pressed.connect(_on_save_as_pressed)
	toolbar_container.add_child(save_as_btn)

	var add_comp_btn = MenuButton.new()
	add_comp_btn.text = "➕ Add Component"
	var popup = add_comp_btn.get_popup()
	popup.add_item("Input Component",          0)
	popup.add_item("Movement Component",       1)
	popup.add_item("Jump Component",           2)
	popup.add_item("Animation Component",      3)
	popup.add_item("Health Component",         4)
	popup.add_item("Health Display Component", 5)
	popup.add_item("Mover Component", 6)
	popup.add_item("Shoot Component", 7)
	popup.add_item("Collectable Component", 8)
	popup.id_pressed.connect(_on_add_component_selected)
	toolbar_container.add_child(add_comp_btn)

	_state_name_label = Label.new()
	_state_name_label.text = "[ unsaved ]"
	toolbar_container.add_child(_state_name_label)

	# Restore last opened file
	if FileAccess.file_exists(LAST_FILE_PATH):
		var f = FileAccess.open(LAST_FILE_PATH, FileAccess.READ)
		_current_state_path = f.get_line().strip_edges()
		f.close()

	_load_editor_state()
	_update_title_label()


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var src = get_node_or_null(NodePath(from_node))
	var dst = get_node_or_null(NodePath(to_node))
	if src and dst:
		connect_node(from_node, from_port, to_node, to_port)
		if src is InputComponentNode:
			if dst is MovementComponentNode:
				dst.receive_connection(to_port, src, from_port)
			elif dst is JumpComponentNode:
				dst.receive_connection(to_port, src, from_port)
			elif dst is ShootComponentNode:
				dst.receive_connection(to_port, src, from_port)
		elif src is AnimationComponentNode:  # all animation connections here
			if dst is MovementComponentNode:
				dst.receive_animation_connection(src)
			elif dst is JumpComponentNode:
				dst.receive_animation_connection(src)
			elif dst is MoverComponentNode:   # ← must be inside this block
				dst.receive_animation_connection(src)
		elif src is HealthComponentNode and dst is HealthDisplayComponentNode:
			src.receive_display_connection(dst)



func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	var src = get_node_or_null(NodePath(from_node))
	var dst = get_node_or_null(NodePath(to_node))
	disconnect_node(from_node, from_port, to_node, to_port)
	if dst is MovementComponentNode:
		if src is InputComponentNode:
			dst.receive_disconnection(to_port)
		elif src is AnimationComponentNode:
			dst.receive_animation_disconnection()
	elif dst is JumpComponentNode:
		if src is InputComponentNode:
			dst.receive_disconnection(to_port)
		elif src is AnimationComponentNode:
			dst.receive_animation_disconnection()
	elif src is HealthComponentNode and dst is HealthDisplayComponentNode:
		src.receive_display_disconnection()
	elif dst is MoverComponentNode and src is AnimationComponentNode:
		dst.receive_animation_disconnection()
	elif dst is ShootComponentNode and src is InputComponentNode:
		dst.receive_disconnection(to_port)


func _on_build_pressed():
	var path = save_path_edit.text
	if path == "":
		push_error("No save path set!")
		return
	var folder = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_recursive_absolute(folder)
	CharacterBuilder.build_to_scene(
		input_node       if is_instance_valid(input_node)       else null,
		movement_node    if is_instance_valid(movement_node)    else null,
		jump_node        if is_instance_valid(jump_node)        else null,
		animation_node   if is_instance_valid(animation_node)   else null,
		health_node      if is_instance_valid(health_node)      else null,
		mover_node       if is_instance_valid(mover_node)       else null,
		shoot_node       if is_instance_valid(shoot_node)       else null,
		collectable_node if is_instance_valid(collectable_node) else null,
		path
	)
	EditorInterface.get_resource_filesystem().scan()


func _save_editor_state() -> void:
	if _current_state_path == "":
		return
	var state = GraphEditorState.new()
	state.save_path = save_path_edit.text
	for child in get_children():
		if child is GraphNode and child.has_method("save_state"):
			state.nodes.append(child.save_state())
	for conn in get_connection_list():
		var src = get_node_or_null(NodePath(conn.from_node))
		var dst = get_node_or_null(NodePath(conn.to_node))
		state.connections.append({
			"from_type": src.save_state().get("type") if src and src.has_method("save_state") else "",
			"from_port": conn.from_port,
			"to_type":   dst.save_state().get("type") if dst and dst.has_method("save_state") else "",
			"to_port":   conn.to_port
		})
	ResourceSaver.save(state, _current_state_path)
	print("💾 Saved state: ", _current_state_path)
	var f = FileAccess.open(LAST_FILE_PATH, FileAccess.WRITE)
	f.store_line(_current_state_path)
	f.close()


func _load_editor_state() -> void:
	_is_loading = true
	if _current_state_path == "" or not ResourceLoader.exists(_current_state_path):
		_is_loading = false
		return
	var state: GraphEditorState = ResourceLoader.load(_current_state_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not state:
		_is_loading = false
		return

	save_path_edit.text = state.save_path

	for data in state.nodes:
		var node = _create_node_of_type(data.get("type", ""))
		if node == null:
			continue
		add_child(node)
		node.restore_state(data)
		_add_remove_button(node)
		if node is InputComponentNode:        input_node = node
		if node is MovementComponentNode:     movement_node = node
		if node is JumpComponentNode:         jump_node = node
		if node is AnimationComponentNode:    animation_node = node
		if node is HealthComponentNode:       health_node = node
		if node is HealthDisplayComponentNode: health_display_node = node
		if node is MoverComponentNode: mover_node = node
		if node is ShootComponentNode: shoot_node = node
		if node is CollectableComponentNode: collectable_node = node

	var type_to_name: Dictionary = {}
	for child in get_children():
		if child is GraphNode and child.has_method("save_state"):
			type_to_name[child.save_state().get("type", "")] = child.name

	await get_tree().process_frame

	for conn in state.connections:
		var from_name = type_to_name.get(conn.from_type, "")
		var to_name   = type_to_name.get(conn.to_type, "")
		if from_name == "" or to_name == "":
			continue
		connect_node(from_name, conn.from_port, to_name, conn.to_port)
		var src = get_node_or_null(NodePath(from_name))
		var dst = get_node_or_null(NodePath(to_name))
		if src is InputComponentNode and dst and dst.has_method("receive_connection"):
			dst.receive_connection(conn.to_port, src, conn.from_port)
		elif src is AnimationComponentNode and dst and dst.has_method("receive_animation_connection"):
			dst.receive_animation_connection(src)
		elif src is HealthComponentNode and dst is HealthDisplayComponentNode:
			src.receive_display_connection(dst)
		#elif src is AnimationComponentNode and dst and dst.has_method("receive_animation_connection"):
			#dst.receive_animation_connection(src)  # already handles MoverComponentNode too

	_is_loading = false


func _create_node_of_type(type: String) -> GraphNode:
	match type:
		"InputComponentNode":          return InputComponentNode.new()
		"MovementComponentNode":       return MovementComponentNode.new()
		"JumpComponentNode":           return JumpComponentNode.new()
		"AnimationComponentNode":      return AnimationComponentNode.new()
		"HealthComponentNode":         return HealthComponentNode.new()
		"HealthDisplayComponentNode":  return HealthDisplayComponentNode.new()
		"MoverComponentNode": return MoverComponentNode.new()
		"ShootComponentNode": return ShootComponentNode.new()
		"CollectableComponentNode": return CollectableComponentNode.new()
	return null


func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE and not _is_loading:
		if _current_state_path != "":
			_save_editor_state()


func _on_new_pressed() -> void:
	_clear_graph()
	_current_state_path = ""
	_update_title_label()

func _on_open_pressed() -> void:
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.tres; Graph Editor State")
	dialog.current_dir = "res://"
	dialog.file_selected.connect(func(path):
		_current_state_path = path
		_clear_graph()
		_load_editor_state()
		_update_title_label()
		dialog.queue_free()
	)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.7)


func _on_save_pressed() -> void:
	if _current_state_path == "":
		_on_save_as_pressed()
		return
	_save_editor_state()


func _on_save_as_pressed() -> void:
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.add_filter("*.tres; Graph Editor State")
	dialog.current_dir = "res://"
	dialog.file_selected.connect(func(path):
		_current_state_path = path
		_save_editor_state()
		_update_title_label()
		dialog.queue_free()
	)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.7)


func _clear_graph() -> void:
	for child in get_children():
		if child is GraphNode:
			child.queue_free()
	input_node = null
	movement_node = null
	jump_node = null
	animation_node = null
	health_node = null
	health_display_node = null
	mover_node = null
	shoot_node = null
	collectable_node = null

func _update_title_label() -> void:
	if _state_name_label:
		_state_name_label.text = _current_state_path.get_file() if _current_state_path != "" else "[ unsaved ]"


func _on_add_component_selected(id: int) -> void:
	var node: GraphNode = null
	match id:
		0:
			if input_node:
				push_warning("InputComponent already exists"); return
			node = InputComponentNode.new()
			input_node = node
		1:
			if movement_node:
				push_warning("MovementComponent already exists"); return
			node = MovementComponentNode.new()
			movement_node = node
		2:
			if jump_node:
				push_warning("JumpComponent already exists"); return
			node = JumpComponentNode.new()
			jump_node = node
		3:
			if animation_node:
				push_warning("AnimationComponent already exists"); return
			node = AnimationComponentNode.new()
			animation_node = node
		4:
			if health_node:
				push_warning("HealthComponent already exists"); return
			node = HealthComponentNode.new()
			health_node = node
		5:
			if health_display_node:
				push_warning("HealthDisplayComponent already exists"); return
			node = HealthDisplayComponentNode.new()
			health_display_node = node
		6:
			if mover_node:
				push_warning("MoverComponent already exists"); return
			node = MoverComponentNode.new()
			mover_node = node
		7:
			if shoot_node:
				push_warning("ShootComponent already exists"); return
			node = ShootComponentNode.new()
			shoot_node = node
		8:
			if collectable_node:
				push_warning("CollectableComponent already exists"); return
			node = CollectableComponentNode.new()
			collectable_node = node

	if node:
		node.position_offset = scroll_offset + get_size() * 0.5 - Vector2(100, 100)
		add_child(node)
		_add_remove_button(node)


func _add_remove_button(node: GraphNode) -> void:
	var remove_btn = Button.new()
	remove_btn.text = "✕"
	remove_btn.tooltip_text = "Remove this component"
	remove_btn.pressed.connect(func(): _remove_component_node(node))
	node.get_titlebar_hbox().add_child(remove_btn)


func _remove_component_node(node: GraphNode) -> void:
	for conn in get_connection_list():
		var from = get_node_or_null(NodePath(conn.from_node))
		var to   = get_node_or_null(NodePath(conn.to_node))
		if from == node or to == node:
			disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
			if to and to.has_method("receive_disconnection") and from is InputComponentNode:
				to.receive_disconnection(conn.to_port)
			elif to and to.has_method("receive_animation_disconnection") and from is AnimationComponentNode:
				to.receive_animation_disconnection()
			elif from is HealthComponentNode and to is HealthDisplayComponentNode:
				from.receive_display_disconnection()
	if node == input_node:           input_node = null
	elif node == movement_node:      movement_node = null
	elif node == jump_node:          jump_node = null
	elif node == animation_node:     animation_node = null
	elif node == health_node:        health_node = null
	elif node == health_display_node: health_display_node = null
	elif node == mover_node: mover_node = null
	elif node == shoot_node: shoot_node = null
	elif node == collectable_node: collectable_node = null
	node.queue_free()
