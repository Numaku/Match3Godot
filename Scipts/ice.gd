extends Node2D

var health : int

func _ready():
	pass # Replace with function body.

func take_damage(damage):
	health -= damage
	
	
