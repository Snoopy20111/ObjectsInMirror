extends RigidBody2D
class_name CarController

const screenShakeFalloff: Curve = preload("res://Customs/Curves/Car_Damage_ScreenShakeFalloff.tres")

#public variables
@export_group("Controller Properties")
@export var controlMode:Enums.CONTROL_TYPE = Enums.CONTROL_TYPE.PLAYER
@export var driftFactor:float = 0.95
@export var accelerationFactor:float = 1200
@export var turnFactor:float = 3.5
@export var maxSpeed:float = 900
@export var maxSpeedReverseFactor:float = 0.4
@export var tireScreechFactor:float = 150.0

@export var maxHealth: int = 5
@export var collisionThreshold: float = 150.0
@export var screenShakeStrength: float = 10.0
@export var screenShakeLength: float = 1.5

#@export_group("No Control Properties")


var _accelerationInput:float = 0
var _steeringInput:float = 0
var _velocityVsUp = 0
#var _engineAudioOutput:float = 0
var _lateralVelocity:float = 0
var _isBraking:bool = false
var canBeDamaged:bool = true
var _lastLinearVelocity:Vector2 = Vector2(0, 0)
var _lastAngularVelocity:float = 0
var _screenShakeCounter: float = 0.0

@onready var _health: int = GameManager.playerHealthAtLevelStart

@onready var rotationAngle:float = rotation_degrees
@onready var skidMaker_L:Line2D = $SkidMaker_L/Skid
@onready var skidMaker_R:Line2D = $SkidMaker_R/Skid
@onready var skidParticles_L:CPUParticles2D = $SkidMaker_L/Particles
@onready var skidParticles_R:CPUParticles2D = $SkidMaker_R/Particles
@onready var timerInvulnurable:Timer = $Timer_Invulnurable


func _ready():
	connect("body_entered", Collided)

# Called every frame
func _process(delta):
	SetInputVector()
	if (GetTireScreeching()):
		skidParticles_L.emitting = true
		skidParticles_R.emitting = true
	else:
		skidParticles_L.emitting = false
		skidParticles_R.emitting = false
	
	var shakeAmount = screenShakeStrength * screenShakeFalloff.sample(
			lerp(1.0, 0.0, _screenShakeCounter / screenShakeLength))
	if (_screenShakeCounter == 0):
		pass
	elif (_screenShakeCounter > 0):
		GameManager.setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE,
			"shake_strength", shakeAmount)
		_screenShakeCounter -= delta
	elif (_screenShakeCounter <= 0):
			_screenShakeCounter = 0
			GameManager.setFullscreenShaderParam(Enums.CANVAS_EFFECT.SCREEN_SHAKE,
				"shake_strength", 0.0)

func _physics_process(_delta):
	_lastLinearVelocity = linear_velocity
	_lastAngularVelocity = angular_velocity

# Called when calculating physics (part of _physics_process() )
func _integrate_forces(state):
	ApplyEngineForce(state)
	KillOrthoganalVelocity()
	ApplySteering(state)


func ApplyEngineForce(state:PhysicsDirectBodyState2D) -> void:
#region Velocity Limits
	#Calculate how much "forward" we are going in terms of the direction of our velocity
	_velocityVsUp = linear_velocity.dot(transform.x)
	#Limit so we can't go faster than the max speed in the "forward" direction
	if ((_velocityVsUp > maxSpeed) && (_accelerationInput > 0)):
		return
	#Limit so we can't go faster than the max speed in reverse
	if ((_velocityVsUp < -maxSpeed * maxSpeedReverseFactor) && (_accelerationInput < 0)):
		return
	#Limit so we can't go faster in any direction while accelerating
	if ((linear_velocity.length_squared() > maxSpeed * maxSpeed) && (_accelerationInput > 0)):
		return
	# Apply drag if there's no accelerationInput so the car eventually
	# stops when the player lets go
	if (_accelerationInput == 0):
		linear_damp = lerp(linear_damp, 5.0, state.step)
	else:
		linear_damp = 0
#endregion
	#create a force for the engine
	var engineForceVector:Vector2 = transform.x * _accelerationInput * accelerationFactor
	#apply to car and push forward
	apply_central_force(engineForceVector)


func ApplySteering(_state:PhysicsDirectBodyState2D) -> void:
	#limit car's ability to turn when moving slowly
	var minSpeedForTurningFactor:float = clampf((linear_velocity.length() / 700), 0, 1)
	#Update rotation angle based on input, faster but more arcade-y
	rotationAngle -= _steeringInput * turnFactor * minSpeedForTurningFactor
	rotation = deg_to_rad(rotationAngle)
	#Update rotation via torque inputs, kinda slower and clunkier-feeling
	#apply_torque(steeringInput * turnFactor)


func SetInputVector() -> void:
	match controlMode:
		Enums.CONTROL_TYPE.PLAYER:
			_steeringInput = lerp(_steeringInput, Input.get_axis("drive_right","drive_left"), .08)
			_accelerationInput = Input.get_axis("drive_back","drive_forward")
		Enums.CONTROL_TYPE.NONE:
			_steeringInput = lerp(_steeringInput, 0.0, .1)
			_accelerationInput = 0.0
		Enums.CONTROL_TYPE.SCRIPT:
			# Do nothing here, deliberately
			pass


func KillOrthoganalVelocity() -> void:
	var forwardVelocity:Vector2 = transform.x * transform.x.dot(linear_velocity)
	var rightVelocity:Vector2 = transform.y * transform.y.dot(linear_velocity)
	
	linear_velocity = forwardVelocity + rightVelocity * driftFactor


func GetLateralVelocity() -> float:
	#Returns how fast the car is moving sideways
	return linear_velocity.dot(transform.y)

func GetTireScreeching():
	_lateralVelocity = GetLateralVelocity()
	_isBraking = false
	# Check if we're moving forward and the player is hitting the brakes
	if (_accelerationInput < 0) and (_velocityVsUp > 0):
		_isBraking = true
		return true
	# Check if we're moving sideways over a threshold
	if (absf(GetLateralVelocity()) > tireScreechFactor):
		return true
	return false


func Collided(body: Node):
	var rotCollForce: float = angular_velocity - _lastAngularVelocity
	var linCollForce: float = (linear_velocity - _lastLinearVelocity).length()
	var collisionForce: float = linCollForce + rotCollForce
	print("Collided with " + str(body.name) + " for impact of " + str(collisionForce))
	
	if (collisionForce > collisionThreshold):
		ApplyDamage()	#apply damage
	#Do sound stuff with different thresholds

func DamageInflicted():
	#Outside force like an Enemy hit us
	#Covers for if the player isn't hit hard enough to be hurt
	pass

func ApplyDamage():
	#Start invulnurability timer, reduce health, and shake the screen
	timerInvulnurable.start()
	canBeDamaged = false
	_health -= 1
	_screenShakeCounter = screenShakeLength
	
	if (_health <= 0):
		Death()
	else:
		print("Ouch!")

func Death():
	print("Dead")
	# Stop player control
	controlMode = Enums.CONTROL_TYPE.NONE
	# Tell the Game Manager we died
	GameManager.playerDied()
	# Explode?
	# Turn on OnDeath node, set the sprite to play, and the particles to emit
	# Perhaps turn some lights on and off in order? Or perhaps one light
	# with an animated texture?	

func _on_timer_invulnurable_timeout():
	canBeDamaged = true
	print("ready to be hurt again")


func ExitLevel():
	GameManager.playerHealthAtLevelStart = _health
	controlMode = Enums.CONTROL_TYPE.NONE

func ScriptControl_GoForward():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	_accelerationInput = 1

func ScriptControl_GoReverse():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	_accelerationInput = -1

func ScriptControl_GoStop():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	_accelerationInput = 0
#@export var traction_curve:Curve = preload("res://Customs/Curves/Car_XSpeedYTraction_Default.tres")
