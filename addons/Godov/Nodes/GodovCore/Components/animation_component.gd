extends Component
class_name AnimationComponent

var animated_sprite: AnimatedSprite2D
func set_animated_sprite(sprite: AnimatedSprite2D) -> void:
	animated_sprite = sprite
	print(animated_sprite)

var current_animation: String = ""

func play_animation(anim_name: String) -> void:
	if not animated_sprite:
		return
	
	if current_animation != anim_name:
		animated_sprite.play(anim_name)
		current_animation = anim_name

func stop_animation() -> void:
	if animated_sprite:
		animated_sprite.stop()
		current_animation = ""
