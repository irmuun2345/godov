extends Component
class_name MoverComponent

enum MovePattern { ONE_DIRECTION, PATROL, CIRCULAR }
enum MoveAxis { HORIZONTAL, VERTICAL }
signal moved(velocity: Vector2)
@export var pattern: MovePattern = MovePattern.PATROL
@export var axis: MoveAxis = MoveAxis.HORIZONTAL       # used by ONE_DIRECTION and PATROL
@export var speed: float = 1.0
@export var distance: float = 200.0                    # patrol distance or circle radius
@export var clockwise: bool = true                     # circular only

var _origin: Vector2 = Vector2.ZERO
var _direction: float = 1.0    # 1 or -1
var _angle: float = 0.0        # circular
@export var custom_direction: Vector2 = Vector2.ZERO  # if set, overrides axis

func _handle_one_direction(body: CharacterBody2D) -> void:
	if custom_direction != Vector2.ZERO:
		body.velocity = custom_direction.normalized() * speed
		return
	match axis:
		MoveAxis.HORIZONTAL: body.velocity = Vector2(speed, 0.0)
		MoveAxis.VERTICAL:   body.velocity = Vector2(0.0, speed)


func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if not entity is CharacterBody2D:
		push_error("MoverComponent requires CharacterBody2D")
		set_physics_process(false)
		return
	_origin = entity.global_position
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not owner_entity or not owner_entity is CharacterBody2D:
		return
	var body := owner_entity as CharacterBody2D

	match pattern:
		MovePattern.ONE_DIRECTION:
			_handle_one_direction(body)
			body.move_and_slide()
			moved.emit(body.velocity)
		MovePattern.PATROL:
			_handle_patrol(body)
			body.move_and_slide()
			moved.emit(body.velocity)
		MovePattern.CIRCULAR:
			_handle_circular(body, delta)
			# no move_and_slide — position set directly
			# moved.emit already called inside _handle_circular

enum _PatrolState { GOING, RETURNING }
var _patrol_state: _PatrolState = _PatrolState.GOING

func _handle_patrol(body: CharacterBody2D) -> void:
	match axis:
		MoveAxis.HORIZONTAL:
			var traveled = body.global_position.x - _origin.x

			if _patrol_state == _PatrolState.GOING:
				body.velocity = Vector2(speed * _direction, 0.0)
				# Hit wall or reached limit — return to origin
				if abs(traveled) >= distance or body.is_on_wall():
					_patrol_state = _PatrolState.RETURNING
					_direction *= -1.0
			else:
				# Head back to origin
				var dist_to_origin = abs(body.global_position.x - _origin.x)
				body.velocity = Vector2(speed * _direction, 0.0)
				if dist_to_origin <= 4.0:
					# Snap to origin and go again
					body.global_position.x = _origin.x
					_patrol_state = _PatrolState.GOING
					_direction *= -1.0

		MoveAxis.VERTICAL:
			var traveled = body.global_position.y - _origin.y

			if _patrol_state == _PatrolState.GOING:
				body.velocity = Vector2(0.0, speed * _direction)
				if abs(traveled) >= distance or body.is_on_wall():
					_patrol_state = _PatrolState.RETURNING
					_direction *= -1.0
			else:
				var dist_to_origin = abs(body.global_position.y - _origin.y)
				body.velocity = Vector2(0.0, speed * _direction)
				if dist_to_origin <= 4.0:
					body.global_position.y = _origin.y
					_patrol_state = _PatrolState.GOING
					_direction *= -1.0

func _handle_circular(body: CharacterBody2D, delta: float) -> void:
	var angular_speed = speed / distance
	_angle += angular_speed * delta * (1.0 if clockwise else -1.0)
	# Move directly by position — no velocity-based physics
	body.global_position = _origin + Vector2(cos(_angle), sin(_angle)) * distance
	# Emit a stable horizontal velocity for animation — just direction of travel
	var tangent = Vector2(-sin(_angle), cos(_angle)) * speed * (1.0 if clockwise else -1.0)
	moved.emit(tangent)

func on_remove_component() -> void:
	super.on_remove_component()
