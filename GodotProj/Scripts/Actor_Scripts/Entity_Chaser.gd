extends RigidBody2D
class_name Entity_Chaser

const chaosFadeCurve = preload("res://Customs/Curves/Chaser/Chaser_ChaosFade_Curve.tres")
const chaserLightFadeCurve = preload("res://Customs/Curves/Chaser/Chaser_LightFade_Curve.tres")
const chaosWithDistanceCurve = preload("res://Customs/Curves/Chaser/Chaser_ChaosWithDistance_Curve.tres")
const chaosRadiusWithDistanceCurve = preload("res://Customs/Curves/Chaser/Chaser_ChaosRadiusWithDistance_Curve.tres")
const vaguePlayerLocSpreadCurve = preload("res://Customs/Curves/Chaser/Chaser_VaguePlayerLocationSpread.tres")

@export var startPaused: bool = false
@export var turningSpeed: float = 12.0
@export var movingSpeed: float = 1000
@export var chargeDistanceThreshold: float = 600.0
@export var maxChaosDistance: float = 600.0
@export var stalkCloseEnoughDist: float = 150.0

@export var chaosFadeCounterDown: float = 3

@onready var animBeginTimer: Timer = $Timer_AnimBegin
@onready var lostEmTimer: Timer = $Timer_LostEm
@onready var watcherSprite: Sprite2D = $Sprite
@onready var chaosNode: ColorRect = $Chaos
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var light: PointLight2D = $PointLight2D
@onready var player: CarController = %PlayerCar

#Shader related params
@onready var chaosParam: float = chaosNode.material.get_shader_parameter("chaos")
@onready var chaosFadeStartValue: float = chaosFadeCounterDown

var isVisible: bool = false
@onready var paused: bool = startPaused

var playerVector: Vector2
var vaguePlayerLocation: Vector2
var vaguePlayerVector: Vector2
var maxStalkDistance: float = 2000
var canCharge: bool = false
var state: Enums.CHASER_STATE = Enums.CHASER_STATE.STALK

var _lastLinearVelocity:Vector2 = Vector2(0, 0)
var _lastAngularVelocity:float = 0
var isFadingSelf: bool = false
var isFadingChaos: bool = false
var fadeCounter: float = 0

func _ready():
	playerVector = player.position - position
	_setVaguePlayerLocation()

func _physics_process(delta):
	#early return if the entity is paused
	if (paused):
		return
	
	# Fade Chaos, if able, but if the counter is past 0, delete watcher
	if(isFadingChaos):
		fadeCounter += delta
		if (chaosFadeCounterDown <= 0):
			queue_free()
			return
		else:
			chaosFadeCounterDown -= delta
		if (light != null):
			light.energy = chaserLightFadeCurve.sample(fadeCounter)
			if (light.energy <= 0):
				light.queue_free()
	
	# Get the distance to player position
	playerVector = player.position - position
	
	#update the linear and angular velocity, for impact with player
	_lastLinearVelocity = linear_velocity
	_lastAngularVelocity = angular_velocity
	
	match(state):
		Enums.CHASER_STATE.STOPPED:
			# Just lost the player
			# If player returns in range, back to charge
			# Otherwise just keep waiting for the timer to end
			if (_isPlayerInRange()) and (isVisible):
				state = Enums.CHASER_STATE.CHARGE
		Enums.CHASER_STATE.STALK:
			# If the player's in range, change to another state
			if (_isPlayerInRange()):
				animBeginTimer.start()
				state = Enums.CHASER_STATE.CHARGE
			else:
				# Patrolling with _some_ knowledge of the player's location
				if ((vaguePlayerLocation - position).length() < stalkCloseEnoughDist):
					_setVaguePlayerLocation()
				else:
					goTo(vaguePlayerLocation, delta, 0.5, 1.0)
			
		Enums.CHASER_STATE.CHARGE:
			# Player is within distance, charge towards/after them
			if (_isPlayerInRange()) and (isVisible) and (canCharge):
				goTo(player.position, delta, 1.0, 1.0)
			elif (_isPlayerInRange()) and (canCharge):
				goTo(player.position, delta, 0.75, 1.0)
			elif (_isPlayerInRange()) and (not canCharge):
				pass
			else:
				state = Enums.CHASER_STATE.STOPPED
				canCharge = false
				_setVaguePlayerLocation()
				lostEmTimer.start()
	
	# Look_at with some smoothing
	var new_transform = transform.looking_at(player.position)
	rotation = transform.interpolate_with(new_transform, turningSpeed * delta).get_rotation()
	
	#newNode.position = vaguePlayerLocation

func _process(_delta):
	#update the shader values
	var chaosAdd = chaosWithDistanceCurve.sample(clamp(playerVector.length() / maxChaosDistance, 0, 1)) 
	var radiusAdd = chaosRadiusWithDistanceCurve.sample(clamp(playerVector.length() / maxChaosDistance, 0, 1)) 
	chaosNode.material.set_shader_parameter("chaos", (chaosParam + chaosAdd))
	chaosNode.material.set_shader_parameter("radius", radiusAdd)


func goTo(target_pos: Vector2, delta: float, speedMult: float = 1.0, turnMult: float = 1.0):
	#move
	var new_vel = (target_pos - position).normalized() * movingSpeed * speedMult
	linear_velocity = lerp(linear_velocity, new_vel, 0.02)
	#and turn
	var new_transform = transform.looking_at(target_pos)
	rotation = transform.interpolate_with(new_transform, turningSpeed * turnMult * delta).get_rotation()

func _isPlayerInRange() -> bool:
	return playerVector.length() < chargeDistanceThreshold

func _setVaguePlayerLocation():
	var rot: float= randf_range(0, 360)
	var dist: float = vaguePlayerLocSpreadCurve.sample(clamp(playerVector.length()
	/maxStalkDistance, 0, maxStalkDistance))
	var rand_vec: Vector2 = Vector2(0, dist)
	#because .rotated() wasn't working, rotate the vector manually
	rand_vec.x = (cos(rot) * rand_vec.x) - (sin(rot) * rand_vec.y)
	rand_vec.y = (sin(rot) * rand_vec.x) - (cos(rot) * rand_vec.y)
	vaguePlayerLocation = player.position + rand_vec
	vaguePlayerVector = vaguePlayerLocation - position

func _on_visible_on_screen_entered() -> void:
	isVisible = true
	if (startPaused):
		paused = false

func _on_visible_on_screen_exited() -> void:
	isVisible = false

func _on_timer_lost_em_timeout():
	state = Enums.CHASER_STATE.STALK

func _on_timer_anim_begin_timeout():
	canCharge = true

func remove_entity():
	watcherSprite.queue_free()
	collision.queue_free()
	state = Enums.CHASER_STATE.STOPPED
	isFadingChaos = true
