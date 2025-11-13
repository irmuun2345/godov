extends System
class_name MovementSystem

@export var managed_entities: Array[Entity] = []

# Track last movement direction for each entity (for idle animations)
var last_directions: Dictionary = {}

func _ready() -> void:
	# Use the manually assigned entities
	entities = managed_entities

func get_entities() -> Array:
	return entities

func _process(delta: float) -> void:
	if not active:
		return
	
	for entity in entities:
		process_entity(entity, delta)

func process_entity(entity: Entity, delta: float) -> void:
	var movement_comp = entity.get_component("MovementComponent") as MovementComponent
	if not movement_comp:
		return
	
	# Get parent CharacterBody2D
	var parent = entity.get_parent()
	if not parent is CharacterBody2D:
		return
	
	# Get input direction (top-down: all 8 directions)
	var input_dir = get_input_direction()
	
	# Calculate target velocity based on input
	var target_velocity = input_dir * movement_comp.speed
	
	# Apply acceleration/deceleration
	var accel_rate = movement_comp.accelartaion * delta
	movement_comp.velcoity = movement_comp.velcoity.lerp(target_velocity, accel_rate)
	
	# Set parent velocity and move
	parent.velocity = movement_comp.velcoity
	parent.move_and_slide()
	
	# Handle animations through AnimationSystem singleton
	var is_moving = movement_comp.velcoity.length() > 10.0
	
	if is_moving:
		# Store the current movement direction
		last_directions[entity] = movement_comp.velcoity.normalized()
		AnimationSystem.play_walk(entity, movement_comp.velcoity.normalized())
	else:
		# Use last known direction for idle, or default to down
		var last_dir = last_directions.get(entity, Vector2.DOWN)
		AnimationSystem.play_idle(entity, last_dir)

func get_input_direction() -> Vector2:
	var dir = Vector2.ZERO
	dir.x = Input.get_axis("left", "right")
	dir.y = Input.get_axis("up", "down")
	return dir.normalized()
