extends RigidBody2D
class_name CarController
#public variables
@export_group("Controller Properties")
@export var controlMode:Enums.CONTROL_TYPE = Enums.CONTROL_TYPE.PLAYER

@export_group("Shared Properties")
@export var driftFactor:float = 0.95
@export var accelerationFactor:float = 1000
@export var turnFactor:float = 3.5
@export var maxSpeed:float = 800
@export var maxSpeedReverseFactor:float = 0.4
@export var tireScreechFactor:float = 150.0

#@export_group("No Control Properties")


#local variables
var accelerationInput:float = 0
var steeringInput:float = 0
var velocityVsUp = 0
var engineAudioOutput:float = 0
var lateralVelocity:float = 0
var isBraking:bool = false

@onready var rotationAngle:float = rotation_degrees
@onready var skidMaker_L:Line2D = $SkidMaker_L/Skid
@onready var skidMaker_R:Line2D = $SkidMaker_R/Skid
@onready var skidParticles_L:CPUParticles2D = $SkidMaker_L/Particles
@onready var skidParticles_R:CPUParticles2D = $SkidMaker_R/Particles

# Called every frame
func _process(_delta):
	SetInputVector()
	if (GetTireScreeching()):
		skidParticles_L.emitting = true
		skidParticles_R.emitting = true
	else:
		skidParticles_L.emitting = false
		skidParticles_R.emitting = false
	#Tell the GameManager where we are
	GameManager.playerLocation = global_position

#func _exit_tree():
	#GameManager.setPlayerCarLocation_null()


# Called when calculating physics (part of _physics_process() )
func _integrate_forces(state):
	ApplyEngineForce(state)
	KillOrthoganalVelocity()
	ApplySteering(state)


func ApplyEngineForce(state:PhysicsDirectBodyState2D) -> void:
#region Velocity Limits
	#Calculate how much "forward" we are going in terms of the direction of our velocity
	velocityVsUp = linear_velocity.dot(transform.x)
	#Limit so we can't go faster than the max speed in the "forward" direction
	if ((velocityVsUp > maxSpeed) && (accelerationInput > 0)):
		return
	#Limit so we can't go faster than the max speed in reverse
	if ((velocityVsUp < -maxSpeed * maxSpeedReverseFactor) && (accelerationInput < 0)):
		return
	#Limit so we can't go faster in any direction while accelerating
	if ((linear_velocity.length_squared() > maxSpeed * maxSpeed) && (accelerationInput > 0)):
		return
	# Apply drag if there's no accelerationInput so the car eventually
	# stops when the player lets go
	if (accelerationInput == 0):
		linear_damp = lerp(linear_damp, 5.0, state.step)
	else:
		linear_damp = 0
#endregion
	
	#create a force for the engine
	var engineForceVector:Vector2 = transform.x * accelerationInput * accelerationFactor
	#apply to car and push forward
	apply_central_force(engineForceVector)


func ApplySteering(_state:PhysicsDirectBodyState2D) -> void:
	#limit car's ability to turn when moving slowly
	var minSpeedForTurningFactor:float = clampf((linear_velocity.length() / 700), 0, 1)
	#Update rotation angle based on input, faster but more arcade-y
	rotationAngle -= steeringInput * turnFactor * minSpeedForTurningFactor
	rotation = deg_to_rad(rotationAngle)
	#Update rotation via torque inputs, kinda slower and clunkier-feeling
	#apply_torque(steeringInput * turnFactor)


func SetInputVector() -> void:
	match controlMode:
		Enums.CONTROL_TYPE.PLAYER:
			steeringInput = lerp(steeringInput, Input.get_axis("drive_right","drive_left"), .08)
			accelerationInput = Input.get_axis("drive_back","drive_forward")
		Enums.CONTROL_TYPE.NONE:
			steeringInput = lerp(steeringInput, 0.0, .1)
			accelerationInput = 0.0
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
	lateralVelocity = GetLateralVelocity()
	isBraking = false
	# Check if we're moving forward and the player is hitting the brakes
	if (accelerationInput < 0) and (velocityVsUp > 0):
		isBraking = true
		return true
	# Check if we're moving sideways over a threshold
	if (absf(GetLateralVelocity()) > tireScreechFactor):
		return true
	return false

func ScriptControl_GoForward():
	controlMode = Enums.CONTROL_TYPE.SCRIPT
	accelerationInput = 1
#@export var traction_curve:Curve = preload("res://Customs/Curves/Car_XSpeedYTraction_Default.tres")
