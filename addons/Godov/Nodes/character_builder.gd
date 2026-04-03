@tool
extends RefCounted
class_name CharacterBuilder

static func build_to_scene(
	input_node: InputComponentNode,
	movement_node: MovementComponentNode,
	jump_node: JumpComponentNode,
	animation_node: AnimationComponentNode,
	health_node: HealthComponentNode,
	mover_node:MoverComponentNode,
	shoot_node: ShootComponentNode,
	collectable_node: CollectableComponentNode,
	collectable_display_node: CollectableDisplayComponentNode,
	save_path: String
) -> void:

	var root: CharacterBody2D
	var is_update := ResourceLoader.exists(save_path)

	if is_update:
		# Load existing scene and get a writable instance
		var existing: PackedScene = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if existing == null:
			push_error("❌ Failed to load existing scene: " + save_path)
			return
		root = existing.instantiate() as CharacterBody2D
		if root == null:
			push_error("❌ Existing scene root is not a CharacterBody2D")
			return
		# Remove only our managed component nodes — leave Sprite2D, CollisionShape2D, etc.
		_remove_node_by_name(root, "InputComponent")
		_remove_node_by_name(root, "MovementComponent")
		_remove_node_by_name(root, "JumpComponent")
		_remove_node_by_name(root, "PhysicsComponent")
		_remove_node_by_name(root, "CollectableComponent")
		_remove_node_by_name(root, "CollectableDisplayComponent")
		print("🔄 Updating existing scene: ", save_path)
	else:
		# Fresh build
		root = CharacterBody2D.new()
		root.name = "Character"

		var col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape = CapsuleShape2D.new()
		shape.radius = 16
		shape.height = 48
		col.shape = shape
		root.add_child(col)
		col.owner = root

		var sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		root.add_child(sprite)
		sprite.owner = root
		print("✨ Creating new scene: ", save_path)

	# From here, same for both paths — just add components
	if input_node:
		var input_comp = InputComponent.new()
		input_comp.name = "InputComponent"
		for row in input_node.action_rows:
			var action_name: String = row.name_edit.text
			if action_name != "":
				input_comp.actions[action_name] = row.keycode
		root.add_child(input_comp)
		input_comp.owner = root

	if movement_node:
		if not input_node:
			push_warning("MovementComponent added without InputComponent — actions won't be registered!")
		var move_comp = MovementComponent.new()
		move_comp.name = "MovementComponent"
		move_comp.speed = movement_node.speed
		move_comp.movement_type = movement_node.movement_type
		if movement_node.connected_actions.has("move_left"):
			move_comp.move_left_action  = movement_node.connected_actions["move_left"]
		if movement_node.connected_actions.has("move_right"):
			move_comp.move_right_action = movement_node.connected_actions["move_right"]
		if movement_node.connected_actions.has("move_up"):
			move_comp.move_up_action    = movement_node.connected_actions["move_up"]
		if movement_node.connected_actions.has("move_down"):
			move_comp.move_down_action  = movement_node.connected_actions["move_down"]
		root.add_child(move_comp)
		move_comp.owner = root

	if jump_node:
		if not input_node:
			push_warning("JumpComponent added without InputComponent — jump action won't be registered!")
		var jump_comp = JumpComponent.new()
		jump_comp.name = "JumpComponent"
		jump_comp.jump_force       = jump_node.jump_force
		jump_comp.gravity          = jump_node.gravity
		jump_comp.max_jump_count   = jump_node.max_jump_count
		jump_comp.coyote_time      = jump_node.coyote_time
		jump_comp.jump_buffer_time = jump_node.jump_buffer_time
		if jump_node.connected_actions.has("jump"):
			jump_comp.jump_action = jump_node.connected_actions["jump"]
		root.add_child(jump_comp)
		jump_comp.owner = root

	if movement_node or jump_node:
		var phys_comp = PhysicsComponent.new()
		phys_comp.name = "PhysicsComponent"
		root.add_child(phys_comp)
		phys_comp.owner = root
	
	#if is_update:
	_remove_node_by_name(root, "AnimationComponent")
	_remove_node_by_name(root, "AnimatedSprite2D")
	_remove_node_by_name(root, "HealthComponent")
	_remove_node_by_name(root, "HealthDisplayComponent")
	
	if animation_node and animation_node.sprite_frames:
		var anim_sprite = AnimatedSprite2D.new()
		anim_sprite.name = "AnimatedSprite2D"
		anim_sprite.sprite_frames = animation_node.sprite_frames
		root.add_child(anim_sprite)
		anim_sprite.owner = root

		var anim_comp = AnimationComponent.new()
		anim_comp.name            = "AnimationComponent"
		anim_comp.animated_sprite = anim_sprite
		anim_comp.animation_map   = animation_node.animation_map.duplicate()
		anim_comp.run_threshold   = animation_node.run_threshold
		# land_duration removed — no longer in AnimationComponent
		anim_comp.connect_movement = movement_node != null and movement_node.animation_node_ref != null
		anim_comp.connect_jump     = jump_node != null and jump_node.animation_node_ref != null
		anim_comp.connect_mover    = mover_node != null and mover_node.animation_node_ref != null
		anim_comp.connect_shoot = shoot_node != null and shoot_node.animation_node_ref != null
		anim_comp.connect_hurt  = health_node != null and health_node.animation_node_ref != null
		root.add_child(anim_comp)
		anim_comp.owner = root
	
	if health_node:
		var health_comp = HealthComponent.new()
		health_comp.name                   = "HealthComponent"
		health_comp.max_health             = health_node.max_health
		health_comp.invincibility_duration = health_node.invincibility_duration
		health_comp.die_on_death           = health_node.die_on_death
		root.add_child(health_comp)
		health_comp.owner = root

		if health_node.display_node_ref:
			var dn = health_node.display_node_ref
			var hd_comp = HealthDisplayComponent.new()
			hd_comp.name             = "HealthDisplayComponent"
			hd_comp.connect_health   = true  # ← flag set here
			hd_comp.style            = dn.style
			hd_comp.display_position = dn.display_position
			hd_comp.margin           = dn.margin
			hd_comp.above_offset     = dn.above_offset
			hd_comp.bar_color        = dn.bar_color
			hd_comp.bar_bg_color     = dn.bar_bg_color
			hd_comp.max_hearts       = dn.max_hearts
			hd_comp.heart_size       = dn.heart_size
			hd_comp.heart_full_color  = dn.heart_full_color
			hd_comp.heart_empty_color = dn.heart_empty_color
			root.add_child(hd_comp)
			hd_comp.owner = root
	_remove_node_by_name(root, "MoverComponent")
	_remove_node_by_name(root, "PhysicsComponent")

	if mover_node:
		var mover_comp = MoverComponent.new()
		mover_comp.name     = "MoverComponent"
		mover_comp.pattern  = mover_node.pattern
		mover_comp.axis     = mover_node.axis
		mover_comp.speed    = mover_node.speed
		mover_comp.distance = mover_node.distance
		mover_comp.clockwise = mover_node.clockwise
		root.add_child(mover_comp)
		mover_comp.owner = root
	_remove_node_by_name(root, "ShootComponent")

	if shoot_node:
		var shoot_comp = ShootComponent.new()
		shoot_comp.name           = "ShootComponent"
		shoot_comp.fire_mode      = shoot_node.fire_mode
		shoot_comp.fire_rate      = shoot_node.fire_rate
		shoot_comp.bullet_speed   = shoot_node.bullet_speed
		shoot_comp.bullet_damage  = shoot_node.bullet_damage
		shoot_comp.bullet_lifetime = shoot_node.bullet_lifetime
		shoot_comp.shoot_action   = shoot_node.connected_shoot_action
		root.add_child(shoot_comp)
		shoot_comp.owner = root
	
	if collectable_node:
		var col_comp = CollectableComponent.new()
		col_comp.name              = "CollectableComponent"
		col_comp.collect_type      = collectable_node.collect_type
		col_comp.value             = collectable_node.value
		col_comp.custom_value_name = collectable_node.custom_value_name
		col_comp.one_time          = collectable_node.one_time
		col_comp.respawn_time      = collectable_node.respawn_time
		root.add_child(col_comp)
		col_comp.owner = root
	
	if collectable_display_node:
		var cd_comp = CollectableDisplayComponent.new()
		cd_comp.name         = "CollectableDisplayComponent"
		cd_comp.corner       = collectable_display_node.corner
		cd_comp.margin       = collectable_display_node.margin
		cd_comp.value_name   = collectable_display_node.value_name
		cd_comp.label_format = collectable_display_node.label_format
		cd_comp.font_size    = collectable_display_node.font_size
		cd_comp.font_color   = collectable_display_node.font_color
		root.add_child(cd_comp)
		cd_comp.owner = root
	if mover_node:
		var mover_comp = MoverComponent.new()
		mover_comp.name      = "MoverComponent"
		mover_comp.pattern   = mover_node.pattern
		mover_comp.axis      = mover_node.axis
		mover_comp.speed     = mover_node.speed
		mover_comp.distance  = mover_node.distance
		mover_comp.clockwise = mover_node.clockwise
		root.add_child(mover_comp)
		mover_comp.owner = root

		var phys_comp = PhysicsComponent.new()  # ← inside if block
		phys_comp.name = "PhysicsComponent"
		root.add_child(phys_comp)
		phys_comp.owner = root
		# Save
	# Save
	var packed = PackedScene.new()
	if packed.pack(root) == OK:
		if ResourceSaver.save(packed, save_path) == OK:
			print("✅ Saved: ", save_path)
			ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
			EditorInterface.get_resource_filesystem().scan()
			var edited_scene = EditorInterface.get_edited_scene_root()
			if edited_scene and edited_scene.scene_file_path == save_path:
				EditorInterface.reload_scene_from_path(save_path)
		else:
			push_error("❌ Save failed")
	else:
		push_error("❌ Pack failed")
	# Remove old debug prints — no constraints on what components are required
	root.free()


static func _remove_node_by_name(parent: Node, node_name: String) -> void:
	var target = parent.get_node_or_null(node_name)
	if target:
		parent.remove_child(target)
		target.free()
