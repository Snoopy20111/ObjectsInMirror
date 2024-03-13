extends Node2D
# Logic for controlling cinematic, dialogue, and then transition to
# the next scene (Main Menu, because that's the game's end)

@export var dialogue_Outro_03: DialogueResource = load("res://Dialogue/Cine_Outro_03.dialogue")
@export var sceneToLoad: String = "res://Scenes/Sets/MainMenu.tscn"

@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue
@onready var timerToExit: Timer = $Timers/Timer_ToExit


func _ready():
	# Connect dialogue manager signals
	DialogueManager.dialogue_ended.connect(dia_end)
	
	# Set Fullscreen shaders: vignette and rain, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)


## Disgusting custom script, chain reaction of signals pinging back and forth
#Timer callback that calls the first line of dialogue
func _on_timer_to_first_dialogue_timeout():
	DialogueManager.show_dialogue_balloon(dialogue_Outro_03, "start")

#Timer callback that transitions to the next scene
func _on_timer_to_exit_timeout():
	SceneManager.change_scene(sceneToLoad)

func dia_end(_resource: DialogueResource):
	timerToExit.start()

func _exit_tree():
	GameManager.resetFullScreenShaders()
