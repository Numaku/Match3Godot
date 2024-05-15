extends TextureRect

var current_number = 0
var max_value
var goal_value =""
@onready var goal_label = $VBoxContainer/Label
@onready var this_texture = $VBoxContainer/TextureRect

func set_goal_value(new_max, new_texture, new_value):
	this_texture.texture = new_texture
	max_value = new_max
	goal_value = new_value
	goal_label.text =  "" + str(current_number) + "/" + str(max_value)

func update_goal_value(goal_type):
	if goal_type == goal_value:
		current_number +=1
		if current_number <= max_value:
			goal_label.text = "" + str(current_number) + "/" + str(max_value)
		
