extends Node
class_name JumpComponent2D

@export var JUMP_VELOCITY: float = -400.0
@export var COYOTE_TIME: float = 0.1
@export var JUMP_BUFFER_TIME: float = 0.1
@export var VARIABLE_JUMP_HEIGHT: bool = true
@export var JUMP_CUT_MULTIPLIER: float = 0.5

var character: CharacterBody2D
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0


func _ready():
	character = get_parent() as CharacterBody2D
	if not character:
		push_error("JumpComponent2D must be child of CharacterBody2D")


func _physics_process(delta):
	if not character:
		return
	
	handle_jump()
	update_timers(delta)


func handle_jump() -> void:
	if Input.is_action_just_pressed("2d_jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	var can_jump = character.is_on_floor() or coyote_timer > 0.0
	
	if jump_buffer_timer > 0.0 and can_jump:
		character.velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
	
	if VARIABLE_JUMP_HEIGHT and Input.is_action_just_released("2d_jump") and character.velocity.y < 0:
		character.velocity.y *= JUMP_CUT_MULTIPLIER


func update_timers(delta: float) -> void:
	if character.is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta


func can_jump() -> bool:
	return character.is_on_floor() or coyote_timer > 0.0
