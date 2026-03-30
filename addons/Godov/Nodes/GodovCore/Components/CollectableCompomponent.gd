extends Component
class_name CollectableComponent

enum CollectType { HEALTH, CUSTOM }

@export var collect_type: CollectType = CollectType.HEALTH
@export var value: float = 20.0                    # health restore or custom value
@export var custom_value_name: String = "score"    # used when type is CUSTOM
@export var one_time: bool = true                  # if false, respawns
@export var respawn_time: float = 5.0

signal collected(collector: Node)
signal spawned
signal respawned

var _collected: bool = false
var _respawn_timer: float = 0.0
var _area: Area2D

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	_build_area(entity)
	set_process(true)
	spawned.emit()

func _build_area(entity: Node) -> void:
	# Reuse existing Area2D if present, otherwise create one
	_area = entity.get_node_or_null("CollectArea")
	if not _area:
		_area = Area2D.new()
		_area.name = "CollectArea"
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 24.0
		col.shape = shape
		_area.add_child(col)
		entity.call_deferred("add_child", _area)
	_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	# Only collect if body has a HealthComponent or is a player-like entity
	var health: HealthComponent = body.get_node_or_null("HealthComponent")
	match collect_type:
		CollectType.HEALTH:
			if health:
				health.heal(value)
				_do_collect(body)
				
		CollectType.CUSTOM:
			# Emit signal and let the game handle the value
			_do_collect(body)

func _do_collect(collector: Node) -> void:
	_collected = true
	collected.emit(collector)
	if one_time:
		owner_entity.queue_free()
	else:
		# Hide and start respawn timer
		owner_entity.visible = false
		if _area:
			_area.monitoring = false
		_respawn_timer = respawn_time

func _process(delta: float) -> void:
	if not _collected or one_time:
		return
	if _respawn_timer > 0:
		_respawn_timer -= delta
		if _respawn_timer <= 0:
			_collected = false
			owner_entity.visible = true
			if _area:
				_area.monitoring = true
			respawned.emit()

func on_remove_component() -> void:
	super.on_remove_component()
