extends Node2D
# Logic for controlling cinematic, dialogue, and then transition to
# the next scene (Main Menu, because that's the game's end)

@export var dialogue_Outro_03: DialogueResource = load("res://Dialogue/Cine_Outro_03.dialogue")
@export var sceneToLoad: String = "res://Scenes/MainMenu.tscn"
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


@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue
@onready var timerToExit: Timer = $Timers/Timer_ToExit
@onready var TrimmedLoadOptions: Dictionary = SceneLoadOptions

var _isCounting: bool = false
var _counter: float

var chromWiggleMult: float = 500
var chromOffsetMult: float = 500
var shakeStrengthMult: float = 0.75

func _ready():
	# Connect dialogue manager signals
	DialogueManager.dialogue_ended.connect(dia_end)
	
	checkTransitionShared()
	
	# Set all Fullscreen Shaders on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.CHROMATIC_ABB, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.SCREEN_SHAKE, true)

func _process(delta):
	# If the effect is running, update the shader params accordingly
	if (_isCounting):
		#Chromatic Aberration isn't working here, not sure why
		GameManager.setFullscreenShaderParam(Enums.CANVAS_EFFECT.CHROMATIC_ABB,
			"wiggle", _counter * chromWiggleMult)
		GameManager.setFullscreenShaderParam(Enums.CANVAS_EFFECT.CHROMATIC_ABB,
			"offset", _counter * chromOffsetMult)
		GameManager.setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE,
			"shake_strength", _counter * shakeStrengthMult)
		_counter += delta

## Disgusting custom script, chain reaction of signals pinging back and forth
#Timer callback that calls the first line of dialogue
func _on_timer_to_first_dialogue_timeout():
	DialogueManager.show_dialogue_balloon(dialogue_Outro_03, "start")

#Timer callback that transitions to the next scene
func _on_timer_to_exit_timeout():
	SceneManager.change_scene(sceneToLoad, TrimmedLoadOptions)

func dia_end(_resource: DialogueResource):
	_isCounting = true
	timerToExit.start()

func _exit_tree():
	GameManager.resetFullScreenShaders()

func checkTransitionShared():
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
