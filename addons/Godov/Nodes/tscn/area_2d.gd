extends Area2D

# Coin properties
@export var coin_value: int = 1

# References
@onready var collision_shape = $CollisionShape2D
@onready var audio_player = $"../AudioStreamPlayer2D"

var collected: bool = false

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	
func _process(delta: float) -> void:
	$"../AnimatedSprite2D".play("default")

func _on_body_entered(body):
	if collected:
		return
	
	# Check if the body is the player
	if body.is_in_group("player") or body.name == "Player":
		collect(body)

func collect(collector):
	collected = true
	
	# Play collection sound
	if audio_player and audio_player.stream:
		get_parent().hide()
		audio_player.play()
		await audio_player.finished
	
	# Call method on collector
	if collector.has_method("add_coins"):
		collector.add_coins(coin_value)
	elif collector.has_method("collect_coin"):
		collector.collect_coin(coin_value)
	
	# Remove the coin
	get_parent().queue_free()
