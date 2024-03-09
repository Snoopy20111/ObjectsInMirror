extends Node2D

const watcherLightFadeCurve = preload("res://Customs/Curves/Watcher/Watcher_LightFade_Curve.tres")
const watcherSpriteFadeCurve = preload("res://Customs/Curves/Watcher/Watcher_SpriteFade_Curve.tres")
const watcherChaosFadeCurve = preload("res://Customs/Curves/Watcher/Watcher_ChaosFade_Curve.tres")
const watcherChaosWithDistanceCurve = preload("res://Customs/Curves/Watcher/Watcher_ChaosWithDistance_Curve.tres")
const watcherChaosRadiusWithDistanceCurve = preload("res://Customs/Curves/Watcher/Watcher_ChaosRadiusWithDistance_Curve.tres")

@export var turningSpeed: float = 12.0
@export var maxChaosDistance: float = 600
@export var chaosFadeCounterDown: float = 2


@onready var watcherLight: PointLight2D = $PointLight2D
@onready var lightEnergyFactor:float = watcherLight.energy
@onready var animBeginTimer: Timer = $AnimBeginTimer
@onready var watcherSprite: Sprite2D = $Sprite
@onready var chaosNode: ColorRect = $Chaos
@onready var chaosFadeStartValue: float = chaosFadeCounterDown

#Shader params
@onready var chaosParam: float = chaosNode.material.get_shader_parameter("chaos")
#@onready var radiusParam: float = chaosNode.material.get_shader_parameter("radius")

var paused: bool = true
var isFadingSelf: bool = false
var isFadingChaos: bool = false
var fadeCounter: float = 0

var playerLocation: Vector2


func _process(delta):
	#early return if the watcher is paused
	if (paused):
		return
	
	# Fade Chaos, if able, but if the counter is past 0, delete watcher
	if(isFadingChaos):
		if (chaosFadeCounterDown <= 0):
			queue_free()
		else:
			chaosFadeCounterDown -= delta
	
	# If the light is totally off and watcher is invisible, begin fading chaos
	if (watcherLight.energy <= 0) and (watcherSprite.self_modulate.a == 0) and (isFadingChaos == false):
		isFadingChaos = true
		isFadingSelf = false
	
	# Fade light, if able
	if (isFadingSelf):
		fadeCounter += delta
		watcherLight.energy = watcherLightFadeCurve.sample(fadeCounter)
		watcherSprite.self_modulate.a = watcherSpriteFadeCurve.sample(fadeCounter)
	
	# If the player's location is a valid position, look_at with smoothing
	if (typeof(GameManager.playerLocation) == TYPE_VECTOR2):
		playerLocation = GameManager.playerLocation
		#working approach
		var new_transform = transform.looking_at(playerLocation)
		rotation = transform.interpolate_with(new_transform,
			turningSpeed * delta).get_rotation()
	
	var distanceToPlayer: float = Vector2(global_position - playerLocation).length()

	var chaosAdd = watcherChaosWithDistanceCurve.sample(clamp(distanceToPlayer / maxChaosDistance, 0, 1)) 
	var radiusAdd = watcherChaosRadiusWithDistanceCurve.sample(clamp(distanceToPlayer / maxChaosDistance, 0, 1)) 
	var chaosFadeMult = watcherChaosFadeCurve.sample(chaosFadeCounterDown/chaosFadeStartValue)
	# Set chaos shader based roughly on the inverse distance to the player
	chaosNode.material.set_shader_parameter("chaos", (chaosParam + chaosAdd) * chaosFadeMult)
	chaosNode.material.set_shader_parameter("radius", radiusAdd * chaosFadeMult)

func _on_visible_on_screen_entered():
	#spring to life
	paused = false
	animBeginTimer.start()
	

func _on_anim_begin_timer_timeout():
	isFadingSelf = true
