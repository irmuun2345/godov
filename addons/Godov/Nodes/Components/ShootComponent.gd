extends Component
class_name ShootComponent

enum FireMode { SINGLE, AUTO }
enum TriggerMode { INPUT, AUTO }
enum TargetMode { FACING, FIXED_DIRECTION, AIM_TARGET, AIM_GROUP }
enum FixedDir { RIGHT, LEFT, UP, DOWN }

@export var bullet_scene: PackedScene = null       # if null builds default bullet
@export var spawner_mode: bool = false             # if true skips ProjectileComponent/MoverComponent

@export var fire_mode: FireMode = FireMode.AUTO
@export var trigger_mode: TriggerMode = TriggerMode.INPUT
@export var fire_rate: float = 0.3

# Input trigger settings
@export var shoot_action: String = ""

# Target settings
@export var target_mode: TargetMode = TargetMode.FACING
@export var fixed_direction: FixedDir = FixedDir.RIGHT
@export var target_node: Node2D = null             # for AIM_TARGET
@export var target_group: String = ""              # for AIM_GROUP

# Bullet settings — ignored in spawner_mode
@export var bullet_speed: float = 500.0
@export var bullet_damage: float = 10.0
@export var bullet_lifetime: float = 2.0

@export var bullet_collision_layer: int = 4
@export var bullet_collision_mask: int = 2

signal fired(projectile: Node)

var _cooldown: float = 0.0
var _facing_direction: Vector2 = Vector2.RIGHT

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)

	# Sync facing from MovementComponent if present
	var move_comp = entity.get_node_or_null("MovementComponent")
	if move_comp:
		move_comp.moved.connect(_on_moved)

	match trigger_mode:
		TriggerMode.INPUT:
			if shoot_action == "":
				push_warning("ShootComponent: INPUT mode but no shoot_action set")
			set_process(true)
		TriggerMode.AUTO:
			set_process(true)

func _on_moved(velocity: Vector2) -> void:
	if velocity.length() > 0.1:
		_facing_direction = velocity.normalized()

func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta

	var should_fire := false

	match trigger_mode:
		TriggerMode.INPUT:
			if shoot_action == "":
				return
			match fire_mode:
				FireMode.SINGLE: should_fire = Input.is_action_just_pressed(shoot_action)
				FireMode.AUTO:   should_fire = Input.is_action_pressed(shoot_action)
		TriggerMode.AUTO:
			should_fire = true  # always tries to fire, rate controls it

	if should_fire and _cooldown <= 0:
		_shoot()
		_cooldown = fire_rate

func _get_fire_direction() -> Vector2:
	match target_mode:
		TargetMode.FACING:
			return _facing_direction
		TargetMode.FIXED_DIRECTION:
			match fixed_direction:
				FixedDir.RIGHT: return Vector2.RIGHT
				FixedDir.LEFT:  return Vector2.LEFT
				FixedDir.UP:    return Vector2.UP
				FixedDir.DOWN:  return Vector2.DOWN
		TargetMode.AIM_TARGET:
			if target_node and owner_entity:
				return (target_node.global_position - owner_entity.global_position).normalized()
			push_warning("ShootComponent: AIM_TARGET but no target_node set")
			return _facing_direction
		TargetMode.AIM_GROUP:
			if target_group != "" and owner_entity:
				var nearest = _get_nearest_in_group(target_group)
				if nearest:
					return (nearest.global_position - owner_entity.global_position).normalized()
			return _facing_direction
	return _facing_direction

func _get_nearest_in_group(group: String) -> Node2D:
	var nodes = owner_entity.get_tree().get_nodes_in_group(group)
	var nearest: Node2D = null
	var nearest_dist := INF
	for node in nodes:
		if node == owner_entity:
			continue
		if node is Node2D:
			var d = owner_entity.global_position.distance_to(node.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = node
	return nearest

func _shoot() -> void:
	if not owner_entity:
		return

	var projectile: CharacterBody2D
	if bullet_scene:
		projectile = bullet_scene.instantiate() as CharacterBody2D
		if not projectile:
			push_error("ShootComponent: bullet_scene root is not CharacterBody2D")
			return
	else:
		projectile = CharacterBody2D.new()
		projectile.name = "Projectile"
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 4.0
		col.shape = shape
		projectile.add_child(col)
		var sprite = ColorRect.new()
		sprite.size = Vector2(8, 8)
		sprite.position = Vector2(-4, -4)
		sprite.color = Color(1, 0.8, 0)
		projectile.add_child(sprite)

	if not spawner_mode:
		# Add movement and lifetime only for bullets
		var mover = MoverComponent.new()
		mover.name             = "MoverComponent"
		mover.pattern          = MoverComponent.MovePattern.ONE_DIRECTION
		mover.custom_direction = _get_fire_direction()
		mover.speed            = bullet_speed
		projectile.add_child(mover)

		var phys = PhysicsComponent.new()
		phys.name = "PhysicsComponent"
		projectile.add_child(phys)

		var proj = ProjectileComponent.new()
		proj.name     = "ProjectileComponent"
		proj.damage   = bullet_damage
		proj.lifetime = bullet_lifetime
		projectile.add_child(proj)

		projectile.collision_layer = bullet_collision_layer
		projectile.collision_mask  = bullet_collision_mask

	projectile.global_position = owner_entity.global_position
	owner_entity.get_parent().add_child(projectile)
	fired.emit(projectile)

func on_remove_component() -> void:
	super.on_remove_component()
