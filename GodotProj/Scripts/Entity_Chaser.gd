extends CharacterBody2D

const chaosFadeCurve = preload("res://Customs/Curves/Chaser/Chaser_ChaosFade_Curve.tres")
const chaosWithDistanceCurve = preload("res://Customs/Curves/Chaser/Chaser_ChaosWithDistance_Curve.tres")
const chaosRadiusWithDistanceCurve = preload("res://Customs/Curves/Chaser/Chaser_ChaosRadiusWithDistance_Curve.tres")
const vaguePlayerLocSpreadCurve = preload("res://Customs/Curves/Chaser/Chaser_VaguePlayerLocationSpread.tres")

@export var turningSpeed: float = 12.0
@export var movingSpeed: float = 400.0
@export var chargeDistanceThreshold: float = 1000.0
@export var maxChaosDistance: float = 600.0

@onready var animBeginTimer: Timer = $Timer_AnimBegin
@onready var lostEmTimer: Timer = $Timer_LostEm
@onready var watcherSprite: Sprite2D = $Sprite
@onready var chaosNode: ColorRect = $Chaos

#Shader params
@onready var chaosParam: float = chaosNode.material.get_shader_parameter("chaos")

var paused: bool = false
var isVisible: bool = false

var playerLocation: Vector2
var playerVector: Vector2
var vaguePlayerLocation: Vector2
var maxStalkDistance: float = 2000
var canCharge: bool = false
var state: Enums.CHASER_STATE = Enums.CHASER_STATE.STALK


func _process(delta):
	#early return if the chaser is paused
	if (paused):
		return
	
	# If the player's location is a valid position, get the newest value
	if (typeof(GameManager.playerLocation) == TYPE_VECTOR2):
		playerLocation = GameManager.playerLocation
	# Also get the distance to said location
	if (typeof(playerLocation) != null):
		playerVector = playerLocation - global_position
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
			# Patrolling with _some_ knowledge of the player's location
			if ((global_position - vaguePlayerLocation).length() < 100):
				print("Stalk: set new target")
				_setVaguePlayerLocation()
			else:
				set_velocity((global_position - vaguePlayerLocation).normalized()
				* movingSpeed / 2)
				move_and_slide()
		Enums.CHASER_STATE.CHARGE:
			# Player is within distance, charge towards/after them
			if (_isPlayerInRange()) and (isVisible) and (canCharge):
				set_velocity(playerVector.normalized() * movingSpeed)
				move_and_slide()
			elif (_isPlayerInRange()) and (canCharge):
				set_velocity(playerVector.normalized() * movingSpeed * 0.75)
				move_and_slide()
			elif (_isPlayerInRange()) and (not canCharge):
				pass
			else:
				state = Enums.CHASER_STATE.STOPPED
				lostEmTimer.start()
	
	# Look_at with some smoothing
	var new_transform = transform.looking_at(playerLocation)
	rotation = transform.interpolate_with(new_transform,
		turningSpeed * delta).get_rotation()
	
	

	var chaosAdd = chaosWithDistanceCurve.sample(clamp(playerVector.length() / maxChaosDistance, 0, 1)) 
	var radiusAdd = chaosRadiusWithDistanceCurve.sample(clamp(playerVector.length() / maxChaosDistance, 0, 1)) 
	chaosNode.material.set_shader_parameter("chaos", (chaosParam + chaosAdd))
	chaosNode.material.set_shader_parameter("radius", radiusAdd)

func _isPlayerInRange() -> bool:
	return playerVector.length() < chargeDistanceThreshold

func _setVaguePlayerLocation():
	var rot: float= randf_range(0, 360)
	var dist: float = vaguePlayerLocSpreadCurve.sample(clamp(playerVector.length()
	/maxStalkDistance, 0, maxStalkDistance))
	var rand_vec: Vector2 = Vector2(dist, 0)
	rand_vec.rotated(rot)
	print("Rand_vec: " + str(rand_vec))
	vaguePlayerLocation = GameManager.playerLocation + rand_vec

func _on_visible_on_screen_entered() -> void:
	#animBeginTimer.start()
	isVisible = true
	

func _on_visible_on_screen_exited() -> void:
	isVisible = false

func _on_timer_lost_em_timeout():
	state = Enums.CHASER_STATE.STALK


func _on_timer_anim_begin_timeout():
	canCharge = true
