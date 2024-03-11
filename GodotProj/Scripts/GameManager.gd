extends Node

@export var fullscreen_effects: Array

@onready var timerToRespawn: Timer = $Timers/Timer_ToRespawn

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
@onready var TrimmedLoadOptions: Dictionary = SceneLoadOptions

#var didCompleteTutorialArea: bool = false

var _vignetteAlpha: float
var _vignetteInnerRadius: float
var _vignetteOuterRadius: float

var _rainCount: int
var _rainSlant: float
var _rainSpeed: float
var _rainBlur: float
var _rainColor: Color
var _rainSize: Vector2

var _chromAbWiggle: float
var _chromAbOffset: float

var _screenShakeStrength: float
var _screenShakeFactorA: Vector2
var _screenShakeFactorB: Vector2
var _screenShakeMagnitude: Vector2

func _ready():
	# Replaces the NodePaths with actual referenced nodes
	# Feels like a dangerous move, but saves some memory and
	# simplifies the code below
	for i in fullscreen_effects.size():
		fullscreen_effects[i] = get_node(fullscreen_effects[i]) as ColorRect
	_grabFullscreenShaderDefaults()
	checkTransitionShared()
	
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

### Game Handling functions ###
func playerDied():
	print("GameManager: player has died. Reloading shortly...")
	timerToRespawn.start()

func _on_timer_to_respawn_timeout():
	SceneManager.reload_scene()


### Specific Utilities ###
## Fullscreen Shader effects ##
func setFullscreenShaderActive(effect: int, is_active: bool = true) -> void:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
	if (is_active == null):
		push_error("value given was null")
		return
	fullscreen_effects[effect].visible = is_active

func setFullscreenShaderParam(effect: int, param_name: String, new_value) -> void:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
	if (new_value == null):
		push_error("value given was null")
		return
	# Don't know of any way to error-check names and types of shader params,
	# So we just have to hope Godot will throw meaningful errors
	var my_material = fullscreen_effects[effect].get_material()
	my_material.set_shader_parameter(param_name, new_value)

func getFullscreenShaderParam(effect: int, param_name: String):
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
		
	# Don't know of any way to error-check names and types of shader params,
	# So we just have to hope Godot will throw meaningful errors
	return fullscreen_effects[effect].get_material().get_shader_parameter(param_name)


func resetFullScreenShaders() -> void:
	for i in fullscreen_effects.size():
		fullscreen_effects[i].visible = false
	_setFullscreenShadersToDefaults()

# Disgusting blocks of code that could 100% be done more efficiently on the eyes,
# but I fear would lose readability or flexability.
# A dictionary could be better, but to hell with it
func _grabFullscreenShaderDefaults():
	_vignetteAlpha = getFullscreenShaderParam(Enums.CANVAS_EFFECT.VIGNETTE, "alpha")
	_vignetteInnerRadius = getFullscreenShaderParam(Enums.CANVAS_EFFECT.VIGNETTE, "inner_radius")
	_vignetteOuterRadius = getFullscreenShaderParam(Enums.CANVAS_EFFECT.VIGNETTE, "outer_radius")

	_rainCount = getFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "count")
	_rainSlant = getFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "slant")
	_rainSpeed = getFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "speed")
	_rainBlur = getFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "blur")
	_rainColor = getFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "color")
	_rainSize = getFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "size")

	_chromAbWiggle = getFullscreenShaderParam(Enums.CANVAS_EFFECT.CHROMATIC_ABB, "wiggle")
	_chromAbOffset = getFullscreenShaderParam(Enums.CANVAS_EFFECT.CHROMATIC_ABB, "offset")

	_screenShakeStrength = getFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "shake_strength")
	_screenShakeFactorA = getFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "factor_a")
	_screenShakeFactorB = getFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "factor_b")
	_screenShakeMagnitude = getFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "magnitude")

func _setFullscreenShadersToDefaults():
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.VIGNETTE, "alpha", _vignetteAlpha)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.VIGNETTE, "inner_radius", _vignetteInnerRadius)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.VIGNETTE, "outer_radius", _vignetteOuterRadius)
	
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "count", _rainCount)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "slant", _rainSlant)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "speed", _rainSpeed)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "blur", _rainBlur)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "color", _rainColor)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.RAIN, "size", _rainSize)
	
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.CHROMATIC_ABB, "wiggle", _chromAbWiggle)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.CHROMATIC_ABB, "offset", _chromAbOffset)
	
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "shake_strength", _screenShakeStrength)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "factor_a", _screenShakeFactorA)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "factor_b", _screenShakeFactorB)
	setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "magnitude", _screenShakeMagnitude)


### Utilities ###
func reparent_other(child:Node, new_parent:Node) -> void:
	child.reparent(new_parent)

func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)
