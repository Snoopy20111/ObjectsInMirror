extends LH_ButtonBase

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

#At some point we'll need these to show a popup about overwriting saves.
#Not a problem if we don't have saves, though.
#@export var showPopup:bool = false
#@export var scenePopup:String
func _ready() -> void:
	super._ready()
	_checkTransitionShared()


func _pressed() -> void:
	super._pressed()
	SceneManager.change_scene(sceneToLoad)
	_canPlaySounds = false


func _checkTransitionShared() -> void:
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
