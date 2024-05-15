extends "res://Scipts/base_menu.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Sences/GameMenu.tscn")

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_grid_game_over():
	slide_in()

