extends RigidBody2D
class_name Entity_Watcher

const watcherLightFadeCurve = preload("res://Customs/Curves/Watcher/Watcher_LightFade_Curve.tres")
const watcherSpriteFadeCurve = preload("res://Customs/Curves/Watcher/Watcher_SpriteFade_Curve.tres")
const watcherChaosFadeCurve = preload("res://Customs/Curves/Watcher/Watcher_ChaosFade_Curve.tres")
const watcherChaosWithDistanceCurve = preload("res://Customs/Curves/Watcher/Watcher_ChaosWithDistance_Curve.tres")
const watcherChaosRadiusWithDistanceCurve = preload("res://Customs/Curves/Watcher/Watcher_ChaosRadiusWithDistance_Curve.tres")

@export var turningSpeed: float = 12.0
@export var maxChaosDistance: float = 600
@export var maxChaosAudioDistance: float = 1500
@export var chaosFadeCounterDown: float = 3

@onready var watcherLight: PointLight2D = $Flashlight
@onready var watcherIllum: PointLight2D = $PointLight2D
@onready var animBeginTimer: Timer = $AnimBeginTimer
@onready var watcherSprite: Sprite2D = $Sprite
@onready var chaosNode: ColorRect = $Chaos
@onready var player: CarController = %PlayerCar

#Shader related params
@onready var chaosParam: float = chaosNode.material.get_shader_parameter("chaos")
@onready var chaosFadeStartValue: float = chaosFadeCounterDown

var paused: bool = true
var isFadingSelf: bool = false
var isFadingChaos: bool = false
var fadeCounter: float = 0


func _ready():
	Wwise.register_game_obj(self, "Entity_Watcher_" + str(self))
	Wwise.post_event("ACTR_Entity_Panic_Play", self)
	Wwise.set_2d_position(self, transform, 0)

func _process(delta):
	#Done every frame regardless
	Wwise.set_2d_position(self, transform, 0)
	
	var distanceToPlayer: float = Vector2(player.global_position - global_position).length()

	var chaosAdd = watcherChaosWithDistanceCurve.sample(clamp(distanceToPlayer / maxChaosDistance, 0, 1))
	var radiusAdd = watcherChaosRadiusWithDistanceCurve.sample(clamp(distanceToPlayer / maxChaosDistance, 0, 1))
	var chaosFadeMult = watcherChaosFadeCurve.sample(chaosFadeCounterDown/chaosFadeStartValue)
	
	# Set chaos shader based roughly on the inverse distance to the player
	chaosNode.material.set_shader_parameter("chaos", (chaosParam + chaosAdd) * chaosFadeMult)
	chaosNode.material.set_shader_parameter("radius", radiusAdd * clamp(chaosFadeMult, 0.0, 1.0))
	
	# And then set audio RTPC?
	var audioPanic = clamp((maxChaosAudioDistance / distanceToPlayer) - 0.1, 0, 3)
	var audioFadeMult = clamp(chaosFadeCounterDown / chaosFadeStartValue, 0, 1)

	Wwise.set_rtpc_value("Panic", audioPanic * audioFadeMult, self)
	print(audioPanic * audioFadeMult)
	
	#early return if the watcher is paused, aka off-screen
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
		watcherIllum.energy = watcherLightFadeCurve.sample(fadeCounter)
		
		watcherSprite.self_modulate.a = watcherSpriteFadeCurve.sample(fadeCounter)
	
	# Look_at with smoothing
	var new_transform = transform.looking_at(player.global_position)
	rotation = transform.interpolate_with(new_transform,
		turningSpeed * delta).get_rotation()
	
	

func _on_visible_on_screen_entered():
	#spring to life
	paused = false
	animBeginTimer.start()

func _on_anim_begin_timer_timeout():
	isFadingSelf = true

func _exit_tree():
	Wwise.post_event("ACTR_Entity_Panic_Stop", self)
	Wwise.unregister_game_obj(self)
