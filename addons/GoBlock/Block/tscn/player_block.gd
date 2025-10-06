@icon("res://addons/GoBlock/IconGodotNode/node_2D/icon_character.png")
extends CharacterBody2D
class_name PLAYER_CHARACTER_2D

@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player_dead:bool = false

signal coin_added(count:int)

func _ready():
	# Set collision layers and mask
	collision_layer = 0b110  # Layers 2 and 3 (binary: 110 = decimal 6)
	collision_mask = 0b1     # Layer 1 (binary: 1 = decimal 1)
	
	# Add to player group
	add_to_group("player")

func _physics_process(delta):
	move_and_slide()

func add_coins(count:int):
	coin_added.emit(count)

func respawn():
	animated_sprite_2d.play("hit")
	await animated_sprite_2d.animation_finished
	await get_tree().create_timer(0.2).timeout
	position = Vector2.ZERO
	player_dead = false
