extends Component
class_name PhysicsComponent

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if not entity is CharacterBody2D:
		push_error("PhysicsComponent requires CharacterBody2D")
		set_physics_process(false)
		return
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not owner_entity is CharacterBody2D:
		return
	(owner_entity as CharacterBody2D).move_and_slide()
