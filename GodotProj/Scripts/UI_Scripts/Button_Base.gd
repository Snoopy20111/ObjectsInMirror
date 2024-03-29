extends Button
class_name LH_ButtonBase

@export_group("Sound Event Paths")
@export var hoveredAudioEvent: String = "UI_Nav_Hover"
@export var unhoveredAudioEvent: String = "UI_Nav_Unhover"
@export var pressedAudioEvent: String = "UI_Nav_Accept"

@export var wwiseObjectName: String = "Button"

var _canPlaySounds: bool = true

# When brought to life
func _ready() -> void:
	connect("mouse_entered", _mouse_entered)
	connect("mouse_exited", _mouse_exited)
	Wwise.register_game_obj(self, wwiseObjectName)


# When killed
func _exit_tree() -> void:
	Wwise.unregister_game_obj(self)

# Pressed
func _pressed() -> void:
	if (pressedAudioEvent != null) and (disabled == false) and (_canPlaySounds):
		Wwise.post_event(pressedAudioEvent, self)

# Hover
func _mouse_entered() -> void:
	if (hoveredAudioEvent != null) and (disabled == false) and (_canPlaySounds):
		Wwise.post_event(hoveredAudioEvent, self)

# Unhover
func _mouse_exited() -> void:
	if (unhoveredAudioEvent != null) and (disabled == false) and (_canPlaySounds):
		Wwise.post_event(unhoveredAudioEvent, self)
