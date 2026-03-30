extends Component
class_name JumpComponent

signal jumped
signal landed

@export var jump_force: float = -400.0
@export var gravity: float = 980.0
@export var jump_action: String = "player_jump"
@export var max_jump_count: int = 1
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

var current_jump_count: int = 0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var _was_on_floor: bool = true

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if not entity is CharacterBody2D:
		push_error("JumpComponent requires CharacterBody2D entity")
		set_physics_process(false)
		return
	set_physics_process(true)
	

func _physics_process(delta: float) -> void:
	if not owner_entity or not owner_entity is CharacterBody2D:
		return

	var body: CharacterBody2D = owner_entity as CharacterBody2D

	if not body.is_on_floor():
		body.velocity.y += gravity * delta

	else:
		current_jump_count = 0
		coyote_timer = coyote_time
		if not _was_on_floor:
			landed.emit()

	if coyote_timer > 0:
		coyote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	if Input.is_action_just_pressed(jump_action):
		jump_buffer_timer = jump_buffer_time

	if jump_buffer_timer > 0:
		if can_jump(body):
			_perform_jump(body)
			jump_buffer_timer = 0

	_was_on_floor = body.is_on_floor()

func can_jump(body: CharacterBody2D) -> bool:
	if body.is_on_floor() or coyote_timer > 0:
		return current_jump_count < 1
	return current_jump_count < max_jump_count

func _perform_jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_force
	current_jump_count += 1
	coyote_timer = 0
	jumped.emit()

func on_remove_component() -> void:
	super.on_remove_component()
