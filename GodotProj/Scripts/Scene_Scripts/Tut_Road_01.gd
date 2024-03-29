extends Node2D

@export var dialogue_tut_01: DialogueResource = load("res://Dialogue/Tut_Road_01_01.dialogue")

@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue


func _ready() -> void:
	# Set Fullscreen shaders: vignette, rain, Chromatic Aberration,
	# and Screen Shake, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	#GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.CHROMATIC_ABB, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.SCREEN_SHAKE, true)
	
	#also make sure the player's health is set to full,
	#since this is the start of the actual game
	GameManager.playerHealthAtLevelStart = 5
	GameManager.levelStart(0)

func _on_timer_to_first_dialogue_timeout() -> void:
	#Play intro dialogue
	DialogueManager.show_dialogue_balloon(dialogue_tut_01, "start")

func _exit_tree() -> void:
	GameManager.resetFullScreenShaders()
