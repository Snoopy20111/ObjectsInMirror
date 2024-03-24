extends RigidBody2D
class_name CarController

const screenShakeFalloff: Curve = preload("res://Customs/Curves/Car_Damage_ScreenShakeFalloff.tres")

#public variables
@export_group("Controller Properties")
@export var controlMode:Enums.CONTROL_TYPE = Enums.CONTROL_TYPE.PLAYER
@export var driftFactor:float = 0.95
@export var accelerationFactor:float = 1000
@export var turnFactor:float = 3.5
@export var maxSpeed:float = 900
@export var maxSpeedReverseFactor:float = 0.4
@export var tireScreechFactor:float = 175.0

@export var maxHealth: int = 5
@export var collisionThreshold: float = 150.0
@export var screenShakeStrength: float = 10.0
@export var screenShakeLength: float = 1.5
@export var lightsOn: bool = true

@export_group("Script Control Properties")
@export var scriptSpeed: float = 1
@export var scriptRPM: float = 0.6
@export var useScriptValues: bool = false


var _accelerationInput:float = 0
var _steeringInput:float = 0
var _velocityVsUp = 0
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
@onready var damageAnimSprite:AnimatedSprite2D = $OnDeath/AnimatedSprite2D
@onready var damageAnimSmoke:GPUParticles2D = $OnDeath/GPUParticles2D
@onready var headlights:PointLight2D = $Headlights_Full


func _ready():
	connect("body_entered", Collided)
	
	# If we're on Windows, set the car to be the distance probe
	# Only supported on Windows because I built the library myself
	# and I can't build for Linux et. al.
	if(OS.has_feature("Windows")):
		Wwise.set_distance_probe(GameManager.get_Listener(), self)
	
	if (lightsOn == false):
		headlights.enabled = false
	if (controlMode != Enums.CONTROL_TYPE.JUST_PROP):
		Wwise.register_game_obj(self, "Player Car")
		#Wwise.set_2d_position(self, transform, 0)
		Wwise.post_event("ACTR_Car_Engine_Play", self)
		Wwise.post_event("ACTR_Car_Tires_Play", self)
	if (useScriptValues):
		Wwise.set_rtpc_value("RPM", scriptRPM, self)

# Called every frame
func _process(delta):
	#Wwise.set_2d_position(self, transform, 0)
	SetInputVector()
	if (GetTireScreeching()):
		skidParticles_L.emitting = true
		skidParticles_R.emitting = true
		_setTireScreechAudio()
	else:
		skidParticles_L.emitting = false
		skidParticles_R.emitting = false
		Wwise.set_rtpc_value("TireScreech", 0.0, self)
	
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
	var speed: float
	if (useScriptValues):
		speed = scriptSpeed
	else:
		speed = linear_velocity.length() / maxSpeed
	Wwise.set_rtpc_value("Speed", speed, self)

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
	
	var temp = absf(_accelerationInput) * clampf((linear_velocity.length() / maxSpeed) + 0.1, 0, 1)
	if (useScriptValues):
		Wwise.set_rtpc_value("RPM", scriptRPM, self)
	elif (_accelerationInput >= 0):
		Wwise.set_rtpc_value("RPM", temp, self)
	else:
		Wwise.set_rtpc_value("RPM", temp * 0.5, self)

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
		Enums.CONTROL_TYPE.NONE, Enums.CONTROL_TYPE.JUST_PROP:
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

func _setTireScreechAudio() -> void:
	var temp: float
	if (_isBraking):
		temp = clamp((linear_velocity.length() - tireScreechFactor)
		/ (maxSpeed - tireScreechFactor), 0, 1)
	else:
		temp = clamp((absf(GetLateralVelocity()) - tireScreechFactor)
		/ (maxSpeed - tireScreechFactor), 0, 1)
	Wwise.set_rtpc_value("TireScreech", temp, self)

func Collided(_body: Node):
	var rotCollForce: float = angular_velocity - _lastAngularVelocity
	var linCollForce: float = (linear_velocity - _lastLinearVelocity).length()
	var collisionForce: float = linCollForce + rotCollForce
	#print("Collided with " + str(body.name) + " for impact of " + str(collisionForce))
	
	if (_body is Entity_Chaser):
		#var entityRotCollForce: float = angular_velocity - _lastAngularVelocity
		#var entityLinColl: Vector2 = (linear_velocity - _lastLinearVelocity)
		var relativePosition = _body.position - position
		apply_force(-relativePosition * 1000, relativePosition)
		print("relativePosition: " + str(relativePosition))
		_body.remove_entity()
		if (canBeDamaged):
			ApplyDamage()
	
	if (collisionForce > collisionThreshold) and (canBeDamaged):
		ApplyDamage()	#apply damage
	else:
		Wwise.set_rtpc_value("ImpactForce", collisionForce, self)
		Wwise.post_event("ACTR_Car_Impact_Tap", self)

func ApplyDamage():
	#Start invulnurability timer, reduce health, and shake the screen
	timerInvulnurable.start()
	canBeDamaged = false
	_health -= 1
	_screenShakeCounter = screenShakeLength
	
	
	if (_health <= 0):
		Death()
		Wwise.post_event("ACTR_Car_Impact_Death", self)
	else:
		damageAnimSmoke.emitting = true
		Wwise.post_event("ACTR_Car_Impact_Hurt", self)

func Death():
	# Stop player control
	controlMode = Enums.CONTROL_TYPE.NONE
	#Turn on the fun FX
	damageAnimSmoke.emitting = true
	damageAnimSprite.play()
	# Tell the Game Manager we died
	GameManager.playerDied()
	
	#and stop the engine audio
	Wwise.post_event("ACTR_Car_Engine_Stop", self)

func _on_timer_invulnurable_timeout():
	canBeDamaged = true
	damageAnimSmoke.emitting = false

func ExitLevel():
	GameManager.playerHealthAtLevelStart = _health
	controlMode = Enums.CONTROL_TYPE.NONE

func _exit_tree():
	Wwise.post_event("ACTR_Car_Engine_Stop", self)
	Wwise.post_event("ACTR_Car_Tires_Stop", self)
	if(OS.has_feature("Windows")):
		Wwise.reset_distance_probe(GameManager.get_Listener())
	Wwise.unregister_game_obj(self)

func ScriptControl_GoForward():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	_accelerationInput = 1

func ScriptControl_GoReverse():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	_accelerationInput = -1

func ScriptControl_GoStop():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	_accelerationInput = 0
