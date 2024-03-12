extends LH_ButtonBase

@export var QuitOptions: Dictionary = {
	"speed": 2.0,
	"color": Color("#000000"),
	"pattern": "fade",
	"ease": 1.0,
}
@export var timeAfterFade: float = 0.075
var isListeningToQuit: bool = false

#At some point we'll need these to show a popup about overwriting saves.
#Not a problem if we don't have saves, though.
#@export var showPopup:bool = false
#@export var scenePopup:String

func _pressed():
	super._pressed()
	SceneManager.connect("fade_complete", quit_fade_completed)
	SceneManager.fade_out(QuitOptions)
	print("fadeout called")
	isListeningToQuit = true
	_canPlaySounds = false
	
func quit_fade_completed():
	print("fade completed signal received")
	if (isListeningToQuit):
		await get_tree().create_timer(timeAfterFade, true, false, true).timeout
		get_tree().quit()
		
