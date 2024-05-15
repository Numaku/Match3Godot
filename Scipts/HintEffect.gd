extends Node2D

@onready var this_sprite = $Sprite2D
var SizeTween : Tween
var ColorTween : Tween

func _ready():
	Setup(this_sprite.texture)
	pass
	
func Setup(new_sprite):
	this_sprite.texture = new_sprite
	slowly_larger_and_dimmer()

func slowly_larger_and_dimmer():
	SizeTween = self.create_tween()
	SizeTween.set_loops()
	SizeTween.parallel().tween_property(this_sprite, "scale", Vector2(0.75,0.75), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	SizeTween.parallel().tween_property(this_sprite, "modulate", Color(1,1,1,0.2), 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	SizeTween.tween_property(this_sprite, "scale", Vector2(0.5,0.5), 0.01)
	SizeTween.tween_property(this_sprite, "modulate", Color(1,1,1,1), 0.01)
	SizeTween.play()
