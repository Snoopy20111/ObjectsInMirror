extends Node2D
# Logic for controlling cinematic, dialogue, and then transition to
# the next scene (Tut_Road_01)

@export var dialogue_Outro_03: DialogueResource = load("res://Dialogue/Cine_Outro_03.dialogue")
@export var sceneToLoad: String = "res://Scenes/Sets/MainMenu.tscn"

@onready var Cam_01: PhantomCamera2D = $PhantomCamera2D_01
@onready var Cam_02: PhantomCamera2D = $PhantomCamera2D_02
@onready var Cam_03: PhantomCamera2D = $PhantomCamera2D_03

@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue
@onready var timerToExit: Timer = $Timers/Timer_ToExit

@onready var playerCar: CarController = $PlayerCar


func _ready():
	# Connect dialogue manager signals
	DialogueManager.dialogue_ended.connect(dia_end)
	
	# Set Fullscreen shaders: vignette and rain, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)


## Disgusting custom script, chain reaction of signals pinging back and forth
#Timer callback that calls the first line of dialogue
func _on_timer_to_first_dialogue_timeout():
	DialogueManager.show_example_dialogue_balloon(dialogue_Outro_03, "start")

#Timer callback that transitions to the next scene
func _on_timer_to_exit_timeout():
	SceneManager.change_scene(sceneToLoad)

func dia_end(_resource: DialogueResource):
	playerCar.ScriptControl_GoForward()
	timerToExit.start()

func _exit_tree():
	GameManager.resetFullScreenShaders()
