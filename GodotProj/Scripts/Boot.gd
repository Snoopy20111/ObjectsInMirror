extends Node2D
class_name Boot

# Debug and starting Options
@export var LogoParade: bool = true
@export var Fullscreen: bool = false
@export var LoadDebugLevel: bool = false
@export var DebugWindowSize: bool = false
@export var DebugLevelPath: String = "res://Scenes/Test_2D.tscn"
@export var DebugWindowDimentions: Vector2i = Vector2i(1280, 720)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("\nWelcome to Objects in Mirror. Watch the road.")
	
	if (DebugWindowSize) && (DebugWindowDimentions.x > 0) && (DebugWindowDimentions.y > 0):
		DisplayServer.window_set_size(DebugWindowDimentions)
	elif (Fullscreen):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	#init audio
	Wwise.load_bank("Init")
	Wwise.load_bank("Master")
	
	randomize()
	
	if (LogoParade):
		SceneManager.change_scene("res://Scenes/LogoParade.tscn")
	elif ((LoadDebugLevel) and (DebugLevelPath != null)):
		SceneManager.change_scene(DebugLevelPath)
	else:
		SceneManager.change_scene("res://Scenes/MainMenu.tscn")
