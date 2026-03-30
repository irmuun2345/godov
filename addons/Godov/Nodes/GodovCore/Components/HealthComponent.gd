extends Component
class_name HealthComponent

@export var max_health: float = 100.0
@export var invincibility_duration: float = 0.5
@export var die_on_death: bool = false  # if true, frees the entity automatically

signal damaged(amount: float)
signal healed(amount: float)
signal died

var current_health: float = max_health
var _invincibility_timer: float = 0.0

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	current_health = max_health
	set_process(true)

func _process(delta: float) -> void:
	if _invincibility_timer > 0:
		_invincibility_timer -= delta

func take_damage(amount: float) -> void:
	if _invincibility_timer > 0:
		return
	current_health = clampf(current_health - amount, 0.0, max_health)
	damaged.emit(amount)
	_invincibility_timer = invincibility_duration
	if current_health <= 0:
		died.emit()
		if die_on_death and owner_entity:
			owner_entity.queue_free()

func heal(amount: float) -> void:
	var prev = current_health
	current_health = clampf(current_health + amount, 0.0, max_health)
	var actual = current_health - prev
	if actual > 0:
		healed.emit(actual)

func is_dead() -> bool:
	return current_health <= 0

func is_invincible() -> bool:
	return _invincibility_timer > 0

func get_health_percent() -> float:
	return current_health / max_health

func on_remove_component() -> void:
	super.on_remove_component()
