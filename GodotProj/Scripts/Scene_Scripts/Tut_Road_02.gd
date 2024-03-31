extends Node2D

#const dialogue_tut_01: DialogueResource = preload("res://Dialogue/Tut_Road_01_01.dialogue")


func _ready() -> void:
	# Set Fullscreen shaders: vignette, rain, Chromatic Aberration,
	# and Screen Shake, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.CHROMATIC_ABB, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.SCREEN_SHAKE, true)
	
	GameManager.levelStart(1)

func _exit_tree() -> void:
	GameManager.resetFullScreenShaders()
