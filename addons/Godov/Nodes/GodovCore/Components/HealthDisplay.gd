extends Component
class_name HealthDisplayComponent

enum DisplayStyle { BAR, HEARTS }
enum DisplayPosition { HUD_TOP_LEFT, HUD_TOP_RIGHT, HUD_BOTTOM_LEFT, HUD_BOTTOM_RIGHT, ABOVE_CHARACTER }

@export var style: DisplayStyle = DisplayStyle.BAR
@export var display_position: DisplayPosition = DisplayPosition.HUD_TOP_LEFT
@export var margin: Vector2 = Vector2(16, 16)
@export var above_offset: Vector2 = Vector2(0, -60)
@export var bar_size: Vector2 = Vector2(200, 20)
@export var bar_color: Color = Color(0.2, 0.8, 0.2)
@export var bar_bg_color: Color = Color(0.2, 0.2, 0.2)
@export var max_hearts: int = 5
@export var heart_size: int = 32
@export var heart_full_color: Color = Color(0.9, 0.1, 0.1)
@export var heart_empty_color: Color = Color(0.3, 0.3, 0.3)

@export var connect_health: bool = false
var _canvas_layer: CanvasLayer
var _control: Control  # bar or hearts container
var _bar: ProgressBar
var _hearts_container: HBoxContainer
var _health_comp: HealthComponent

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	if connect_health:
		_health_comp = entity.get_node_or_null("HealthComponent")
		if not _health_comp:
			push_warning("HealthDisplayComponent: connect_health=true but no HealthComponent found")
			return
	else:
		return

	_build_ui(entity)
	_health_comp.damaged.connect(_on_health_changed)
	_health_comp.healed.connect(_on_health_changed)
	_health_comp.died.connect(_on_died)
	_refresh()

	if display_position == DisplayPosition.ABOVE_CHARACTER:
		set_process(true)

func _process(_delta: float) -> void:
	if display_position == DisplayPosition.ABOVE_CHARACTER and _control and owner_entity:
		var screen_pos = get_viewport().get_canvas_transform() * (owner_entity.global_position + above_offset)
		_control.position = screen_pos - _control.size * 0.5

func _build_ui(entity: Node) -> void:
	if display_position == DisplayPosition.ABOVE_CHARACTER:
		# Use a CanvasLayer but position manually each frame
		_canvas_layer = CanvasLayer.new()
		_canvas_layer.layer = 10
		entity.call_deferred("add_child", _canvas_layer)
		
	else:
		_canvas_layer = CanvasLayer.new()
		_canvas_layer.layer = 10
		entity.call_deferred("add_child", _canvas_layer)

	match style:
		DisplayStyle.BAR:    _build_bar()
		DisplayStyle.HEARTS: _build_hearts()

	if display_position != DisplayPosition.ABOVE_CHARACTER:
		_apply_hud_corner()

func _build_bar() -> void:
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = bar_size
	_bar.min_value = 0
	_bar.max_value = _health_comp.max_health
	_bar.value = _health_comp.current_health
	_bar.show_percentage = false
	var bg = StyleBoxFlat.new(); bg.bg_color = bar_bg_color
	var fill = StyleBoxFlat.new(); fill.bg_color = bar_color
	_bar.add_theme_stylebox_override("background", bg)
	_bar.add_theme_stylebox_override("fill", fill)
	_canvas_layer.add_child(_bar)
	_control = _bar

func _build_hearts() -> void:
	_hearts_container = HBoxContainer.new()
	_hearts_container.add_theme_constant_override("separation", 4)
	_canvas_layer.add_child(_hearts_container)
	_control = _hearts_container
	for i in max_hearts:
		var heart = Label.new()
		heart.text = "♥"
		heart.add_theme_font_size_override("font_size", heart_size)
		heart.add_theme_color_override("font_color", heart_full_color)
		_hearts_container.add_child(heart)

func _apply_hud_corner() -> void:
	match display_position:
		DisplayPosition.HUD_TOP_LEFT:
			_control.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
			_control.position = margin
		DisplayPosition.HUD_TOP_RIGHT:
			_control.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			_control.position = Vector2(-bar_size.x - margin.x, margin.y)
		DisplayPosition.HUD_BOTTOM_LEFT:
			_control.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
			_control.position = Vector2(margin.x, -bar_size.y - margin.y)
		DisplayPosition.HUD_BOTTOM_RIGHT:
			_control.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			_control.position = Vector2(-bar_size.x - margin.x, -bar_size.y - margin.y)

func _on_health_changed(_amount: float) -> void:
	_refresh()

func _on_died() -> void:

	_refresh()

func _refresh() -> void:
	if not _health_comp: return
	match style:
		DisplayStyle.BAR:
			if _bar:
				_bar.max_value = _health_comp.max_health
				_bar.value = _health_comp.current_health
		DisplayStyle.HEARTS:
			if not _hearts_container: return
			var filled = roundi(_health_comp.get_health_percent() * max_hearts)
			for i in _hearts_container.get_child_count():
				(_hearts_container.get_child(i) as Label).add_theme_color_override(
					"font_color", heart_full_color if i < filled else heart_empty_color)

func on_remove_component() -> void:
	if _canvas_layer: _canvas_layer.queue_free()
	super.on_remove_component()
