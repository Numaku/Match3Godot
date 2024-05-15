extends "res://Scipts/base_menu.gd"

signal sound_change
signal back_button

func _on_btn_1_pressed():
	emit_signal("sound_change")


func _on_btn_2_pressed():
	emit_signal("back_button")
