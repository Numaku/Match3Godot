extends Node2D

#Level
@export var level: int
@export var level_to_load: String
@export var enable: bool
@export var score_goal_met: bool

#Texture
@export var blocked_texture: Texture
@export var open_texture: Texture
@export var goal_met: Texture
@export var goal_not_met: Texture

@onready var level_label = $TextureButton/Label
@onready var button = $TextureButton
@onready var star1 = $star1
@onready var star2 = $star2
@onready var star3 = $star3

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

func setup():
	level_label.text = str(level)
	if enable:
		button.texture_normal = open_texture
	else:
		button.texture_normal = blocked_texture
	if score_goal_met:
		star1.texture = goal_met
	else:
		star1.texture = goal_not_met

func _on_texture_button_pressed():
	if enable:
		get_tree().change_scene_to_file(level_to_load)
