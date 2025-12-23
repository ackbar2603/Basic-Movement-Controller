extends Node

var loading_screen = load("res://scene/loading_screen.tscn")
var scene_path : String
var previous_scene : String

func change_level(path):
	scene_path = path
	previous_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_packed(loading_screen)

func goto_previous():
	if not previous_scene.is_empty():
		scene_path = previous_scene
		get_tree().change_scene_to_packed(loading_screen)
