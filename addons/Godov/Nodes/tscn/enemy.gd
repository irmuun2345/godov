extends CharacterBody2D

@export var speed = 75.0
@export var direction_change_time = 2.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction = 1
var timer

func _ready():
	# Create and setup timer
	timer = Timer.new()
	timer.wait_time = direction_change_time
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	$Area2D.connect("body_entered", died_player)

func _physics_process(delta):
	
	apply_gravity(delta)
	# Move left and right
	$AnimatedSprite2D.play("default")
	velocity.x = speed * direction
	move_and_slide()

func _on_timer_timeout():
	# Change direction when timer runs out
	direction *= -1
	$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
	
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity *  delta
		
func died_player(body:CharacterBody2D) -> void:
	if body.is_in_group("player"):
		body.player_dead = true
		body.respawn()
