extends CanvasLayer
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
	Wwise.load_bank("Init") 		#Metadata bank
	Wwise.load_bank("Master")		#Master bank, holds most audio
	Wwise.register_game_obj(AmbientAudio, "AmbientAudio")	#GameObj for non-spatialized audio
	
	#Seeds RNG, may be useful later
	randomize()
	
	if (OS.has_feature("release") or LogoParade):
		SceneManager.change_scene("res://Scenes/LogoParade.tscn")
	elif ((LoadDebugLevel) and (DebugLevelPath != null)):
		SceneManager.change_scene(DebugLevelPath)
	else:
		SceneManager.change_scene("res://Scenes/MainMenu.tscn")
