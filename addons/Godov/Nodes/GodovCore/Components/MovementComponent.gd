extends Component
class_name MovementComponent

signal moved(velocity: Vector2)

enum MovementType { PLATFORMER, TOP_DOWN }

@export var movement_type: MovementType = MovementType.PLATFORMER
@export var speed: float = 300.0
@export var move_left_action: String = ""
@export var move_right_action: String = ""
@export var move_up_action: String = ""
@export var move_down_action: String = ""

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if not entity is CharacterBody2D:
		push_error("MovementComponent requires CharacterBody2D entity")
		set_physics_process(false)
		return
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	if not owner_entity or not owner_entity is CharacterBody2D:
		return

	var body: CharacterBody2D = owner_entity as CharacterBody2D

	match movement_type:
		MovementType.PLATFORMER:
			_handle_platformer_movement(body)
		MovementType.TOP_DOWN:
			_handle_top_down_movement(body)

	body.move_and_slide()
	moved.emit(body.velocity)

func _handle_platformer_movement(body: CharacterBody2D) -> void:
	if move_left_action == "" or move_right_action == "":
		push_warning("MovementComponent: move actions not configured!")
		return
	body.velocity.x = Input.get_axis(move_left_action, move_right_action) * speed

func _handle_top_down_movement(body: CharacterBody2D) -> void:
	if move_left_action == "" or move_right_action == "" or move_up_action == "" or move_down_action == "":
		push_warning("MovementComponent: move actions not configured!")
		return
	body.velocity = Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action) * speed

func on_remove_component() -> void:
	super.on_remove_component()
