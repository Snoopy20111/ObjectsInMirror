extends CanvasLayer
# Will do stuff here later when we have settings to control
# and more complex menu nagivation

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
#
func _exit_tree():
	GameManager.resetFullScreenShaders()
