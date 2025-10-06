extends CanvasLayer

var all_coin:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	owner.coin_added.connect(handle_coin_add)


func handle_coin_add(count:int):
	all_coin += count
	$HBoxContainer/Label.text = str(all_coin)
