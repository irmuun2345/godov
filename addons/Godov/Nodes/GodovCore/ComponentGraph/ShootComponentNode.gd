@tool
extends GraphNode
class_name ShootComponentNode

var fire_mode: int = 0
var fire_rate: float = 0.3
var bullet_speed: float = 500.0
var bullet_damage: float = 10.0
var bullet_lifetime: float = 2.0
var connected_shoot_action: String = ""

var _fm_opt: OptionButton
var _fr_spin: SpinBox
var _bs_spin: SpinBox
var _bd_spin: SpinBox
var _bl_spin: SpinBox
var _action_label: Label

func _ready() -> void:
	title = "Shoot Component"
	_build_ui()

func _build_ui() -> void:
	# Row 0 — Shoot Action input port (connects from InputComponentNode)
	_action_label = Label.new()
	_action_label.text = "Shoot Action [ not connected ]"
	add_child(_action_label)
	set_slot(0, true, 0, Color(0.4, 0.8, 1.0), false, 0, Color.WHITE)

	# Row 1 — Fire Mode label
	var fm_label = Label.new()
	fm_label.text = "Fire Mode"
	add_child(fm_label)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 2 — Fire Mode option
	_fm_opt = OptionButton.new()
	_fm_opt.add_item("Single", 0)
	_fm_opt.add_item("Auto",   1)
	_fm_opt.select(fire_mode)
	_fm_opt.item_selected.connect(func(idx): fire_mode = idx)
	add_child(_fm_opt)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 3 — Fire Rate label
	var fr_label = Label.new()
	fr_label.text = "Fire Rate (sec)"
	add_child(fr_label)
	set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 4 — Fire Rate spin
	_fr_spin = SpinBox.new()
	_fr_spin.min_value = 0.05
	_fr_spin.max_value = 10.0
	_fr_spin.step = 0.05
	_fr_spin.value = fire_rate
	_fr_spin.value_changed.connect(func(val): fire_rate = val)
	add_child(_fr_spin)
	set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 5 — Bullet Speed label
	var bs_label = Label.new()
	bs_label.text = "Bullet Speed"
	add_child(bs_label)
	set_slot(5, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 6 — Bullet Speed spin
	_bs_spin = SpinBox.new()
	_bs_spin.min_value = 10
	_bs_spin.max_value = 5000
	_bs_spin.step = 10
	_bs_spin.value = bullet_speed
	_bs_spin.value_changed.connect(func(val): bullet_speed = val)
	add_child(_bs_spin)
	set_slot(6, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 7 — Bullet Damage label
	var bd_label = Label.new()
	bd_label.text = "Bullet Damage"
	add_child(bd_label)
	set_slot(7, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 8 — Bullet Damage spin
	_bd_spin = SpinBox.new()
	_bd_spin.min_value = 0
	_bd_spin.max_value = 9999
	_bd_spin.step = 1
	_bd_spin.value = bullet_damage
	_bd_spin.value_changed.connect(func(val): bullet_damage = val)
	add_child(_bd_spin)
	set_slot(8, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 9 — Bullet Lifetime label
	var bl_label = Label.new()
	bl_label.text = "Bullet Lifetime"
	add_child(bl_label)
	set_slot(9, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Row 10 — Bullet Lifetime spin
	_bl_spin = SpinBox.new()
	_bl_spin.min_value = 0.1
	_bl_spin.max_value = 30.0
	_bl_spin.step = 0.1
	_bl_spin.value = bullet_lifetime
	_bl_spin.value_changed.connect(func(val): bullet_lifetime = val)
	add_child(_bl_spin)
	set_slot(10, false, 0, Color.WHITE, false, 0, Color.WHITE)

func receive_connection(to_port: int, from_node: InputComponentNode, from_port: int) -> void:
	connected_shoot_action = from_node.get_action_name_for_port(from_port)
	_action_label.text = "Shoot Action [ " + connected_shoot_action + " ]"

func receive_disconnection(to_port: int) -> void:
	connected_shoot_action = ""
	_action_label.text = "Shoot Action [ not connected ]"

func save_state() -> Dictionary:
	return {
		"type":                  "ShootComponentNode",
		"position":              position_offset,
		"fire_mode":             fire_mode,
		"fire_rate":             fire_rate,
		"bullet_speed":          bullet_speed,
		"bullet_damage":         bullet_damage,
		"bullet_lifetime":       bullet_lifetime,
		"connected_shoot_action": connected_shoot_action,
	}

func restore_state(data: Dictionary) -> void:
	position_offset        = data["position"]
	fire_mode              = data.get("fire_mode",       0)
	fire_rate              = data.get("fire_rate",       0.3)
	bullet_speed           = data.get("bullet_speed",    500.0)
	bullet_damage          = data.get("bullet_damage",   10.0)
	bullet_lifetime        = data.get("bullet_lifetime", 2.0)
	connected_shoot_action = data.get("connected_shoot_action", "")

	_fm_opt.select(fire_mode)
	_fr_spin.value = fire_rate
	_bs_spin.value = bullet_speed
	_bd_spin.value = bullet_damage
	_bl_spin.value = bullet_lifetime
	if connected_shoot_action != "":
		_action_label.text = "Shoot Action [ " + connected_shoot_action + " ]"
