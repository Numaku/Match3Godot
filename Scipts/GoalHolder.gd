extends Node

signal create_goals
signal game_won

func _ready():
	create_goal()

func create_goal():
	for i in  get_child_count():
		var current = get_child(i)
		emit_signal("create_goals", current.max_needed, current.goal_texture, current.goal_string)

func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)
	check_game_win()

func check_game_win():
	if goal_met():
		emit_signal("game_won")
		#print("won")

func goal_met():
	for i in get_child_count():
		if !get_child(i).goal_met:
			return false
	return true
	
func _on_grid_check_goal(goal_type):
	check_goals(goal_type)


func _on_ice_holder_break_ice(goal_type):
	check_goals(goal_type)
	pass # Replace with function body.

	
