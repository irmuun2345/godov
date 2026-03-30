extends Component
class_name ProjectileComponent

@export var damage: float = 10.0
@export var lifetime: float = 2.0

var _timer: float = 0.0

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if not entity is CharacterBody2D:
		push_error("ProjectileComponent requires CharacterBody2D")
		return
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not owner_entity or not owner_entity is CharacterBody2D:
		return

	_timer += delta
	if _timer >= lifetime:
		owner_entity.queue_free()
		return

	var body := owner_entity as CharacterBody2D
	# Check what we hit after move_and_slide (called by MoverComponent)
	for i in body.get_slide_collision_count():
		var collision = body.get_slide_collision(i)
		var collider = collision.get_collider()
		if collider:
			_try_deal_damage(collider)
			owner_entity.queue_free()
			return

func _try_deal_damage(collider: Node) -> void:
	# Check collider itself and its parent for HealthComponent
	var health: HealthComponent = null
	if collider.has_node("HealthComponent"):
		health = collider.get_node("HealthComponent")
	elif collider.get_parent() and collider.get_parent().has_node("HealthComponent"):
		health = collider.get_parent().get_node("HealthComponent")

	if health:
		
		health.take_damage(damage)

func on_remove_component() -> void:
	super.on_remove_component()
