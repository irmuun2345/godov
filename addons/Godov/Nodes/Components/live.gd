extends Node
class_name LivesComponent

signal lives_changed(old_value: int, new_value: int)
signal life_lost()
signal life_gained()
signal game_over()
signal lives_depleted()

@export var MAX_LIVES: int = 3
@export var STARTING_LIVES: int = 3
@export var INFINITE_LIVES: bool = false

var current_lives: int

func _ready():
	current_lives = STARTING_LIVES


func lose_life() -> bool:
	if INFINITE_LIVES or current_lives <= 0:
		return false
	
	var old_lives = current_lives
	current_lives -= 1
	
	lives_changed.emit(old_lives, current_lives)
	life_lost.emit()
	
	if current_lives <= 0:
		lives_depleted.emit()
		game_over.emit()
		return true
	
	return true


func gain_life() -> bool:
	if current_lives >= MAX_LIVES:
		return false
	
	var old_lives = current_lives
	current_lives += 1
	
	lives_changed.emit(old_lives, current_lives)
	life_gained.emit()
	
	return true


func set_lives(value: int) -> void:
	var old_lives = current_lives
	current_lives = clamp(value, 0, MAX_LIVES)
	
	if current_lives != old_lives:
		lives_changed.emit(old_lives, current_lives)
	
	if current_lives <= 0:
		lives_depleted.emit()
		game_over.emit()


func get_lives() -> int:
	return current_lives


func get_max_lives() -> int:
	return MAX_LIVES


func has_lives() -> bool:
	return current_lives > 0 or INFINITE_LIVES


func reset_lives() -> void:
	var old_lives = current_lives
	current_lives = STARTING_LIVES
	lives_changed.emit(old_lives, current_lives)
