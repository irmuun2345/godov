extends Node
# This should be added as an Autoload in Project Settings
# Project -> Project Settings -> Autoload -> Add this script

func play_animation(entity: Entity, anim_name: String) -> void:
	var anim_comp = entity.get_component("AnimationComponent") as AnimationComponent
	if anim_comp:
		anim_comp.play_animation(anim_name)

func play_idle(entity: Entity, direction: Vector2 = Vector2.DOWN) -> void:
	var anim_comp = entity.get_component("AnimationComponent") as AnimationComponent
	if anim_comp:
		var anim_name = get_directional_animation("idle", direction)
		anim_comp.play_animation(anim_name)
		
		# Flip sprite when facing left/right
		flip_sprite_horizontal(entity, direction)

func play_walk(entity: Entity, direction: Vector2) -> void:
	var anim_comp = entity.get_component("AnimationComponent") as AnimationComponent
	if anim_comp:
		var anim_name = get_directional_animation("move", direction)
		anim_comp.play_animation(anim_name)
		
		# Flip sprite when moving left/right
		flip_sprite_horizontal(entity, direction)

func get_directional_animation(base_name: String, direction: Vector2) -> String:
	# Determine which direction the character is facing
	# For left/right, we use the same "right" animation but flip the sprite
	# This means you only need: up, down, right animations (left uses right flipped)
	
	if direction.length() < 0.1:
		return base_name + "_down"  # Default direction when no input
	
	# Determine primary direction
	var angle = direction.angle()
	
	# Convert angle to direction name
	# Right/Left: -45 to 45 degrees or 135 to -135 (use right animation, flip for left)
	# Down: 45 to 135 degrees
	# Up: -135 to -45 degrees
	
	if angle > -PI/4 and angle <= PI/4:
		return base_name + "_right"  # Moving right
	elif angle > PI/4 and angle <= 3*PI/4:
		return base_name + "_down"
	elif angle > 3*PI/4 or angle <= -3*PI/4:
		return base_name + "_right"  # Moving left (will flip sprite)
	else:
		return base_name + "_up"

func flip_sprite_horizontal(entity: Entity, direction: Vector2) -> void:
	var anim_comp = entity.get_component("AnimationComponent") as AnimationComponent
	if anim_comp and anim_comp.animated_sprite:
		# Flip left, don't flip right
		if abs(direction.x) > 0.1:  # If there's horizontal movement
			anim_comp.animated_sprite.flip_h = direction.x < 0

func stop_animation(entity: Entity) -> void:
	var anim_comp = entity.get_component("AnimationComponent") as AnimationComponent
	if anim_comp:
		anim_comp.stop_animation()
