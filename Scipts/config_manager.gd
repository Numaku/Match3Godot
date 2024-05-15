extends Node

@onready var path = "user://config.ini"
var sound_on = true
var music_on = true


# Called when the node enters the scene tree for the first time.
func _ready():
	load_config()

func save_config():
	var config = ConfigFile.new()
	config.set_value("sound", sound_on, 0)
	config.set_value("music", music_on, 0)
	
	var err = config.save(path)
	if err != OK:
		print("Something went wrong while saving the configuration.")

		
func load_config():
	var config = ConfigFile.new()
	var default_option = {
		"sound": true,
		"music": true
	}
	var err = config.load(path)
	if err != OK:
		return default_option
	var options = {}
	options.sound = config.get_value("sound", "")
	options.music = config.get_value("music", "")
	return options
	
