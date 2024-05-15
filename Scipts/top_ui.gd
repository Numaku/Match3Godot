extends TextureRect

@onready var score_label = $MarginContainer/HBoxContainer/VBoxContainer/ScoreLabel
@onready var counter_label = $MarginContainer/HBoxContainer/CounterLabel
@onready var score_bar = $MarginContainer/HBoxContainer/VBoxContainer/TextureProgressBar
@onready var goal_container = $MarginContainer/HBoxContainer/HBoxContainer
@export var goal_prefab: PackedScene
var current_score = 0
var current_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	_on_grid_update_score(current_score)


func _on_grid_update_score(amount_to_change):
	current_score += amount_to_change
	update_score_bar()
	score_label.text = str(current_score)


func _on_grid_update_couter(amount_to_change = -1):
	current_count += amount_to_change
	counter_label.text = str(current_count)

func setup_score_bar(max_score):
	score_bar.max_value = max_score
	
func update_score_bar():
	score_bar.value = current_score

func make_goal(new_max, new_texture, new_value):
	var current = goal_prefab.instantiate()
	goal_container.add_child(current)
	current.set_goal_value(new_max, new_texture, new_value)

func _on_grid_setup_max_score(max_score):
	setup_score_bar(max_score)

func _on_goal_holder_create_goals(new_max, new_texture, new_value):
	make_goal(new_max, new_texture, new_value)


func _on_grid_check_goal(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_value(goal_type)


func _on_ice_holder_break_ice(goal_type):
	for i in goal_container.get_child_count():
		goal_container.get_child(i).update_goal_value(goal_type)
