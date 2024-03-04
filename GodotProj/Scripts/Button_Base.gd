extends Button
class_name LH_ButtonBase

@export_group("Sound Event Paths")
@export var hoveredAudioEvent: String = "Play_UI_Nav_Hover"
@export var unhoveredAudioEvent: String = "Play_UI_Nav_Unhover"
@export var pressedAudioEvent: String = "Play_UI_Nav_Accept"

@export var wwiseObjectName: String = "Button"

# When brought to life
func _ready():
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)
	Wwise.register_game_obj(self, wwiseObjectName)


# When killed
func _exit_tree():
	Wwise.unregister_game_obj(self)

# Pressed
func _pressed():
	if (pressedAudioEvent != null):
		Wwise.post_event(pressedAudioEvent, self)

# Hover
func _mouse_entered():
	if (hoveredAudioEvent != null):
		Wwise.post_event(hoveredAudioEvent, self)

# Unhover
func _mouse_exited():
	if (unhoveredAudioEvent != null):
		Wwise.post_event(unhoveredAudioEvent, self)
