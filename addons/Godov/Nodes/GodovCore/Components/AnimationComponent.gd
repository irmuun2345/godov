extends Component
class_name AnimationComponent

@export var animated_sprite: AnimatedSprite2D

@export var animation_map: Dictionary = {
	"idle": "idle",
	"walk": "walk",
	"run":  "run",
	"jump": "jump",
	"fall": "fall",
	"land": "land",
}

@export var run_threshold: float = 200.0
@export var land_duration: float = 0.15

signal animation_changed(new_anim: String)

var _current_state: String = "idle"
var _land_timer: float = 0.0
var _locked: bool = false  # true while a one-shot play() is running

@export var connect_movement: bool = false
@export var connect_jump: bool = false
@export var connect_mover: bool = false
func on_add_component(entity: Node) -> void:

	super.on_add_component(entity)

	if not animated_sprite:
		push_error("AnimationComponent: no AnimatedSprite2D assigned")
		return
	if not animated_sprite.sprite_frames:
		return

	_validate_map()

	if connect_movement:
		var move_comp = entity.get_node_or_null("MovementComponent")
		if move_comp:
			move_comp.moved.connect(_on_moved)
		else:
			push_warning("AnimationComponent: connect_movement=true but no MovementComponent found")
			for c in entity.get_children():
				print("     ", c.name, " : ", c.get_class())

	if connect_jump:
		var jump_comp = entity.get_node_or_null("JumpComponent")
		if jump_comp:
			jump_comp.jumped.connect(_on_jumped)
			jump_comp.landed.connect(_on_landed)
		else:
			push_warning("AnimationComponent: connect_jump=true but no JumpComponent found")
	if connect_mover:
		var mover_comp = entity.get_node_or_null("MoverComponent")
		if mover_comp:
			mover_comp.moved.connect(_on_moved)
		else:
			push_warning("AnimationComponent: connect_mover=true but no MoverComponent found")
	set_physics_process(true)

#func _connect_sibling_signals(entity: Node) -> void:
	## Connect to JumpComponent if present
	#for child in entity.get_children():
		#if child is JumpComponent:
			#child.jumped.connect(_on_jumped)
			#child.landed.connect(_on_landed)
			#
		#if child is MovementComponent:
			#child.moved.connect(_on_moved)

func _validate_map() -> void:
	for state_key in animation_map:
		var anim_name: String = animation_map[state_key]
		if anim_name != "" and not animated_sprite.sprite_frames.has_animation(anim_name):
			push_warning(
				"AnimationComponent: animation_map[\"%s\"] = \"%s\" not found in SpriteFrames. Available: %s"
				% [state_key, anim_name, str(animated_sprite.sprite_frames.get_animation_names())]
			)

# ─── Signal handlers ──────────────────────────────────────────────────────────

func _on_jumped() -> void:
	_land_timer = 0.0
	_set_state("jump")

func _on_landed() -> void:
	_land_timer = land_duration
	_set_state("land")

func _on_moved(velocity: Vector2) -> void:
	if _locked:
		return

	# Flip based on horizontal direction
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

	if _current_state in ["jump", "fall", "land"]:
		return

	var spd := velocity.length()
	if spd >= run_threshold:
		_set_state("run")
	elif spd > 0:
		_set_state("walk")
	else:
		_set_state("idle")

# ─── State machine ────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if _land_timer > 0:
		_land_timer -= delta
		if _land_timer <= 0:
			_set_state("idle")

func _set_state(new_state: String) -> void:
	if _locked or _current_state == new_state:
		return
	_current_state = new_state
	_play_state(new_state)

func _play_state(state: String) -> void:
	var anim_name: String = animation_map.get(state, "")
	if anim_name == "" or not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	if animated_sprite.animation == anim_name and animated_sprite.is_playing():
		return
	animated_sprite.play(anim_name)
	animation_changed.emit(anim_name)

# ─── Public API ───────────────────────────────────────────────────────────────

## Play a one-shot animation (attack, hurt, etc.) — state machine resumes after
func play(anim_name: String, on_finish: Callable = Callable()) -> void:
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		push_warning("AnimationComponent.play(): \"%s\" not found in SpriteFrames" % anim_name)
		return
	_locked = true
	animated_sprite.play(anim_name)
	animation_changed.emit(anim_name)
	animated_sprite.animation_finished.connect(_on_oneshot_finished.bind(on_finish), CONNECT_ONE_SHOT)

func _on_oneshot_finished(on_finish: Callable) -> void:
	_locked = false
	if on_finish.is_valid():
		on_finish.call()
	_play_state(_current_state)

func stop(reset: bool = false) -> void:
	if reset:
		animated_sprite.stop()
	else:
		animated_sprite.pause()

func get_available_animations() -> PackedStringArray:
	return animated_sprite.sprite_frames.get_animation_names() if animated_sprite and animated_sprite.sprite_frames else PackedStringArray()

func remap_state(state_key: String, anim_name: String) -> void:
	animation_map[state_key] = anim_name

func get_current_state() -> String:
	return _current_state

func on_remove_component() -> void:
	super.on_remove_component()
