extends Node

@export var fullscreen_effects: Array

@onready var timerToRespawn: Timer = $Timers/Timer_ToRespawn
@onready var akListener: AkListener2D = $Camera2D/AkListener2D

@export_category("Transitions")
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

#region Fullscreen Shader Defaults
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
#endregion

var playerHealthAtLevelStart: int = 5
var playerMaxHealth: int = 5
var playerCurrentLevel: int = 0

func _ready() -> void:
	# Replaces the NodePaths with actual referenced nodes
	# Feels like a dangerous move, but saves some memory and
	# simplifies the code below
	for i in fullscreen_effects.size():
		fullscreen_effects[i] = get_node(fullscreen_effects[i]) as ColorRect
	_grabFullscreenShaderDefaults()
	checkTransitionShared()

func checkTransitionShared() -> void:
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
func levelStart(levelID: int) -> void:
	playerCurrentLevel = levelID

func playerDied() -> void:
	timerToRespawn.start()
	#Also set player health back to max when they respawn, to reduce frustration
	playerHealthAtLevelStart = playerMaxHealth

func _on_timer_to_respawn_timeout() -> void:
	# Disgusting workaround to Scene Manager bug with reloading scenes
	# Game just doesn't know what scene we've currently loaded, so we
	# Just gotta reload the old fashioned way.
	match (playerCurrentLevel):
		0:
			SceneManager.change_scene("res://Scenes/Tut_Road_01.tscn", TrimmedLoadOptions)
		1:
			SceneManager.change_scene("res://Scenes/Tut_Road_02.tscn", TrimmedLoadOptions)
		2:
			SceneManager.change_scene("res://Scenes/Main_Road_01.tscn", TrimmedLoadOptions)

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

@warning_ignore("untyped_declaration") #Deliberately untyped
func setFullscreenShaderParam(effect: int, param_name: String, new_value) -> void:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
	if (new_value == null):
		push_error("value given was null")
		return
	# Don't know of any way to error-check names and types of shader params,
	# So we just have to hope Godot will throw meaningful errors
	var my_material: Material = fullscreen_effects[effect].get_material()
	my_material.set_shader_parameter(param_name, new_value)

func getFullscreenShaderParam_i(effect: int, param_name: String) -> int:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return -1
	return fullscreen_effects[effect].get_material().get_shader_parameter(param_name)

func getFullscreenShaderParam_f(effect: int, param_name: String) -> float:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return -1.0
	return fullscreen_effects[effect].get_material().get_shader_parameter(param_name)
	
func getFullscreenShaderParam_c(effect: int, param_name: String) -> Color:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return Color(0, 0, 0)
	return fullscreen_effects[effect].get_material().get_shader_parameter(param_name)

func getFullscreenShaderParam_v2(effect: int, param_name: String) -> Vector2:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return Vector2(0, 0)
	return fullscreen_effects[effect].get_material().get_shader_parameter(param_name)

func resetFullScreenShaders() -> void:
	for i in fullscreen_effects.size():
		fullscreen_effects[i].visible = false
	_setFullscreenShadersToDefaults()

# Disgusting blocks of code that could 100% be done more efficiently on the eyes,
# but I fear would lose readability or flexability.
# A dictionary could be better, but to hell with it
func _grabFullscreenShaderDefaults() -> void:
	_vignetteAlpha = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.VIGNETTE, "alpha")
	_vignetteInnerRadius = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.VIGNETTE, "inner_radius")
	_vignetteOuterRadius = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.VIGNETTE, "outer_radius")

	_rainCount = getFullscreenShaderParam_i(Enums.CANVAS_EFFECT.RAIN, "count")
	_rainSlant = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.RAIN, "slant")
	_rainSpeed = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.RAIN, "speed")
	_rainBlur = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.RAIN, "blur")
	_rainColor = getFullscreenShaderParam_c(Enums.CANVAS_EFFECT.RAIN, "color")
	_rainSize = getFullscreenShaderParam_v2(Enums.CANVAS_EFFECT.RAIN, "size")

	_chromAbWiggle = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.CHROMATIC_ABB, "wiggle")
	_chromAbOffset = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.CHROMATIC_ABB, "offset")

	_screenShakeStrength = getFullscreenShaderParam_f(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "shake_strength")
	_screenShakeFactorA = getFullscreenShaderParam_v2(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "factor_a")
	_screenShakeFactorB = getFullscreenShaderParam_v2(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "factor_b")
	_screenShakeMagnitude = getFullscreenShaderParam_v2(Enums.CANVAS_EFFECT.SCREEN_SHAKE, "magnitude")

func _setFullscreenShadersToDefaults() -> void:
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

func get_Listener() -> AkListener2D:
	return akListener

### Utilities ###
#func reparent_other(child:Node, new_parent:Node) -> void:
	#child.reparent(new_parent)
#
#func findByClass(node: Node, className : String, result : Array) -> void:
	#if node.is_class(className):
		#result.push_back(node)
	#for child in node.get_children():
		#findByClass(child, className, result)
