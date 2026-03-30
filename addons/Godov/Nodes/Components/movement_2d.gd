extends Node
class_name MovementComponent2D

@export var SPEED: float = 300.0
@export var ACCELERATION: float = 1500.0
@export var FRICTION: float = 1200.0
@export var AIR_RESISTANCE: float = 200.0
@export var GRAVITY_MULTIPLIER: float = 1.0
@export var FALL_GRAVITY_MULTIPLIER: float = 1.5

var character: CharacterBody2D
var gravity: float

func _ready():
	character = owner as CharacterBody2D
	if not character:
		push_error("MovementComponent2D must be child of CharacterBody2D")
		return
	
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not character:
		return
	if not character.player_dead:
		apply_gravity(delta)
		handle_horizontal_movement(delta)
	else:
		var friction_value = FRICTION if character.is_on_floor() else AIR_RESISTANCE * 0.5
		character.velocity.x = move_toward(character.velocity.x, 0, friction_value * delta)

func apply_gravity(delta: float) -> void:
	if not character.is_on_floor():
		var gravity_mult = FALL_GRAVITY_MULTIPLIER if character.velocity.y > 0 else GRAVITY_MULTIPLIER
		character.velocity.y += gravity * gravity_mult * delta

func handle_horizontal_movement(delta: float) -> void:
	var direction = Input.get_axis("2d_left", "2d_right")
	
	if direction != 0:
		var target_speed = direction * SPEED
		var accel = ACCELERATION if character.is_on_floor() else AIR_RESISTANCE
		character.velocity.x = move_toward(character.velocity.x, target_speed, accel * delta)
		character.animated_sprite_2d.play("run")
		
		# Flip character based on direction
		if direction < 0:
			character.animated_sprite_2d.flip_h = true
		else:
			character.animated_sprite_2d.flip_h = false
	else:
		var friction_value = FRICTION if character.is_on_floor() else AIR_RESISTANCE * 0.5
		character.velocity.x = move_toward(character.velocity.x, 0, friction_value * delta)
		character.animated_sprite_2d.play("idle")

func get_move_direction() -> float:
	return Input.get_axis("2d_left", "2d_right")
