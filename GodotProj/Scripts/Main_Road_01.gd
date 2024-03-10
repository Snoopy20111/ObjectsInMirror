extends Node2D

@export var dialogue_main_01: DialogueResource = load("res://Dialogue/Main_Road_01_01.dialogue")

@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue


func _ready():
	# Set Fullscreen shaders: vignette, rain, Chromatic Aberration,
	# and Screen Shake, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.CHROMATIC_ABB, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.SCREEN_SHAKE, true)


func _exit_tree():
	GameManager.resetFullScreenShaders()