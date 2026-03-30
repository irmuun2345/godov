extends Component
class_name ShootComponent

enum FireMode { SINGLE, AUTO }
@export var bullet_scene: PackedScene = null
@export var fire_mode: FireMode = FireMode.SINGLE
@export var fire_rate: float = 0.3
@export var bullet_speed: float = 500.0
@export var bullet_damage: float = 10.0
@export var bullet_lifetime: float = 2.0
@export var shoot_action: String = ""

signal fired(projectile: Node)

var _cooldown: float = 0.0
var _facing_right: bool = true

func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta
	if shoot_action == "":
		return
	var should_fire := false
	match fire_mode:
		FireMode.SINGLE: should_fire = Input.is_action_just_pressed(shoot_action)
		FireMode.AUTO:   should_fire = Input.is_action_pressed(shoot_action)
	if should_fire and _cooldown <= 0:
		_shoot()
		_cooldown = fire_rate

var _facing_direction: Vector2 = Vector2.RIGHT

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if shoot_action == "":
		push_warning("ShootComponent: no shoot_action configured")

	# Connect to MovementComponent if present
	var move_comp = entity.get_node_or_null("MovementComponent")
	if move_comp:
		move_comp.moved.connect(_on_moved)
		print("ShootComponent: connected to MovementComponent.moved")
	else:
		push_warning("ShootComponent: no MovementComponent found — facing defaults to RIGHT")

	set_process(true)

func _on_moved(velocity: Vector2) -> void:
	if velocity.length() > 0.1:
		_facing_direction = velocity.normalized()

func _shoot() -> void:
	if not owner_entity:
		return

	var projectile: CharacterBody2D
	if bullet_scene:
		projectile = bullet_scene.instantiate() as CharacterBody2D
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

	var mover = MoverComponent.new()
	mover.name             = "MoverComponent"
	mover.pattern          = MoverComponent.MovePattern.ONE_DIRECTION
	mover.custom_direction = _facing_direction
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
	projectile.collision_layer = 4   # layer 3
	projectile.collision_mask  = 2   # hits layer 2 only
	projectile.global_position = owner_entity.global_position
	get_tree().root.add_child(projectile)
	fired.emit(projectile)

func on_remove_component() -> void:
	super.on_remove_component()
