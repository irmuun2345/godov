extends Component
class_name CollectableDisplayComponent

enum ScreenCorner { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT }

@export var corner: ScreenCorner = ScreenCorner.TOP_RIGHT
@export var margin: Vector2 = Vector2(16, 16)
@export var value_name: String = "score"
@export var label_format: String = "{name}: {value}"  # e.g. "Score: 100"
@export var font_size: int = 16
@export var font_color: Color = Color.WHITE

var _canvas_layer: CanvasLayer
var _label: Label
var _current_value: float = 0.0

func on_add_component(entity: Node) -> void:
	super.on_add_component(entity)
	_build_ui(entity)

func _build_ui(entity: Node) -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.name = "CollectableDisplayLayer"
	_canvas_layer.layer = 10
	entity.add_child(_canvas_layer)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", font_color)
	_canvas_layer.add_child(_label)

	_apply_corner()
	_refresh()

func _apply_corner() -> void:
	match corner:
		ScreenCorner.TOP_LEFT:
			_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
			_label.position = margin
		ScreenCorner.TOP_RIGHT:
			_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			_label.position = Vector2(-200 - margin.x, margin.y)
		ScreenCorner.BOTTOM_LEFT:
			_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
			_label.position = Vector2(margin.x, -40 - margin.y)
		ScreenCorner.BOTTOM_RIGHT:
			_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			_label.position = Vector2(-200 - margin.x, -40 - margin.y)

func add_value(amount: float) -> void:
	_current_value += amount
	_refresh()

func set_value(amount: float) -> void:
	_current_value = amount
	_refresh()

func _refresh() -> void:
	if not _label:
		return
	var display_name = value_name.capitalize()
	_label.text = label_format\
		.replace("{name}", display_name)\
		.replace("{value}", str(int(_current_value)))

func on_remove_component() -> void:
	if _canvas_layer:
		_canvas_layer.queue_free()
	super.on_remove_component()
