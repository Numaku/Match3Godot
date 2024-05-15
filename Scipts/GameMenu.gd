extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Main.slide_in()


func _on_main_settings_pressed():
	$Main.slide_out()
	$Setting.slide_in()


func _on_setting_back_button():
	$Main.slide_in()
	$Setting.slide_out()


func _on_main_play_pressed():
	get_tree().change_scene_to_file("res://Sences/level_select_sence.tscn")
