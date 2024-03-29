extends Area2D

@export var sceneToLoad:String = "res://Scenes/Test_2D.tscn"
@export var SharedEasing: bool = true
@export var SharedAnimName: bool = true
@export var SceneLoadOptions: Dictionary = {
	"speed": 2,
	"color": Color("#000000"),
	"pattern": "fade",
	"wait_time": 0.5,
	"invert": false,
	"invert_on_leave": true,
	"ease": 1.0,
	"ease_leave": 1.0,
	"ease_enter": 1.0,
	"skip_scene_change": false,
	"skip_fade_out": false,
	"skip_fade_in": false,
	"animation_name": null,
	"animation_name_enter": null,
	"animation_name_leave": null
}

@onready var TrimmedLoadOptions: Dictionary = SceneLoadOptions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkTransitionShared()
	area_entered.connect(Callable(onAreaEntered))

func checkTransitionShared() -> void:
	if (SharedEasing == true):
		TrimmedLoadOptions.erase("ease_leave")
		TrimmedLoadOptions.erase("ease_enter")
	else:
		TrimmedLoadOptions.erase("ease")
	
	if (SharedAnimName == true):
		TrimmedLoadOptions.erase("animation_name_enter")
		TrimmedLoadOptions.erase("animation_name_leave")
	else:
		TrimmedLoadOptions.erase("animation_name")

func onAreaEntered(area: Area2D) -> void:
	# If it's the player, change the scene
	# Brittle as hell methods to see if this is the Player Car
	if ((area.collision_layer == 2)
	and (area.get_parent() is CarController)):
		SceneManager.change_scene(sceneToLoad, TrimmedLoadOptions)
		var playerCar := area.get_parent() as CarController
		playerCar.ExitLevel()
		playerCar.ScriptControl_GoForward()
