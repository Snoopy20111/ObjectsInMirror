extends Node2D

const dialogue_TrainAudible: DialogueResource = preload("res://Dialogue/Main_Road_01_TrainAudible.dialogue")

var playedTrainAudible: bool = false

func _ready() -> void:
	# Set Fullscreen shaders: vignette, rain, Chromatic Aberration,
	# and Screen Shake, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.CHROMATIC_ABB, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.SCREEN_SHAKE, true)
	
	GameManager.levelStart(2)

func _exit_tree() -> void:
	GameManager.resetFullScreenShaders()


func _on_trigger_dia_train_audible_crossed() -> void:
	if (!playedTrainAudible):
		DialogueManager.show_dialogue_balloon(dialogue_TrainAudible, "start")
		playedTrainAudible = true
