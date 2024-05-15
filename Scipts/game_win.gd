extends "res://Scipts/base_menu.gd"

func _on_continue_button_pressed():
	get_tree().reload_current_scene()

func _on_goal_holder_game_won():
	slide_in()
	get_tree().paused
