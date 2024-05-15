extends Node2D

@export var color: String
@export var row_texture : Texture
@export var column_texture : Texture
@export var adjacent_texture : Texture
@export var color_bomb_texture: Texture

var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false
var is_color_bomb = false

var move_tween
var matched = false
# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = get_node("move_tween")
	
func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",target,0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	#move_tween.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func make_column_bomb():
	is_column_bomb = true
	$Sprite.texture = column_texture
	$Sprite.modulate = Color(1,1,1,1)

func make_row_bomb():
	is_row_bomb = true
	$Sprite.texture = row_texture
	$Sprite.modulate = Color(1,1,1,1)

func make_adjacent_bomb():
	is_adjacent_bomb = true
	$Sprite.texture = adjacent_texture
	$Sprite.modulate = Color(1,1,1,1)

func make_color_bomb():
	is_color_bomb = true
	$Sprite.texture = color_bomb_texture
	$Sprite.modulate = Color(1,1,1,1)
	color = "Color"
	
func dim():
	var sprite = get_node("Sprite")
	sprite.modulate = Color(1,1,1,0.5)
