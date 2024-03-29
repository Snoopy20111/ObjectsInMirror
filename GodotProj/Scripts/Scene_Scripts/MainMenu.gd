extends CanvasLayer
# Will do stuff here later when we have settings to control
# and more complex menu nagivation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)

func _exit_tree() -> void:
	GameManager.resetFullScreenShaders()
