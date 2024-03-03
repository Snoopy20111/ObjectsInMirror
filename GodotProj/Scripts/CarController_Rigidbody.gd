extends RigidBody2D


#public variables
@export_group("Basic Car properties")
@export var driftFactor:float = 0.95
@export var accelerationFactor:float = 1000
@export var turnFactor:float = 3.5
@export var maxSpeed:float = 800
@export var maxSpeedReverseFactor:float = 0.35

#local variables
var accelerationInput:float = 0
var steeringInput:float = 0
var rotationAngle:float = 0
var velocityVsUp = 0


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	SetInputVector()


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
	steeringInput = Input.get_axis("drive_right","drive_left")
	accelerationInput = Input.get_axis("drive_back","drive_forward")


func KillOrthoganalVelocity() -> void:
	var forwardVelocity:Vector2 = transform.x * transform.x.dot(linear_velocity)
	var rightVelocity:Vector2 = transform.y * transform.y.dot(linear_velocity)
	
	linear_velocity = forwardVelocity + rightVelocity * driftFactor


func GetLateralVelocity() -> float:
	#Returns how fast the car is moving sideways
	return linear_velocity.dot(transform.y)

#@export var traction_curve:Curve = preload("res://Curves/Car_XSpeedYTraction_Default.tres")