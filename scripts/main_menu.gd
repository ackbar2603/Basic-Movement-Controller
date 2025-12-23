extends Control


func _ready() -> void:
	%newGame.pressed.connect(new_game)
	%exit.pressed.connect(quit_game)

func new_game():
	Loader.change_level("res://scene/main.tscn")

func quit_game():
	get_tree().quit()
