extends "res://Scipts/base_menu.gd"

signal play_pressed
signal settings_pressed

func _on_btn_1_pressed():
	emit_signal("play_pressed")


func _on_btn_2_pressed():
	emit_signal("settings_pressed")
