extends CharacterBody2D

@export var wheel_base:float = 50
@export var steering_angle:float = 16
@export var engine_power = 800
@export var braking = -450
@export var max_speed_reverse = 250
@export var slip_speed = 400


@export var friction = -0.9
@export var drag = -0.001
@export var traction_curve:Curve = preload("res://Curves/Car_XSpeedYTraction_Default.tres")

var acceleration = Vector2.ZERO
var steer_direction:float

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

func get_input():
	var turn = 0
	if Input.is_action_pressed("ui_right"):
		turn += 1
	if Input.is_action_pressed("ui_left"):
		turn -= 1
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking
	#if Input.is_action_pressed("ui_down"):
		

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	var traction = traction_curve.sample(velocity.x / engine_power)
	var dot_product = new_heading.dot(velocity.normalized())
	
	if dot_product > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if dot_product < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
	
	
##public variables
#@export var driftFactor:float = 0.95
#@export var accelerationFactor:float = 30.0
#@export var turnFactor:float = 3.5
#@export var maxSpeed:float = 20
#
##local variables
#var accelerationInput:float = 0
#var steeringInput:float = 0
#var rotationAngle:float = 0
#var velocityVsUp = 0

## Called when the node enters the scene tree for the first time.
##func _ready():
##	pass # Replace with function body.
#
#
 ##Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#SetInputVector()
#
#func _integrate_forces(state):
	#ApplyEngineForce(state)
	#ApplySteering(state)
#
#func ApplyEngineForce(state:PhysicsDirectBodyState2D):
	##Apply drag if there's no accelerationInput so the car eventually stops when the player lets go
	##if (accelerationInput == 0):
	##	carRigidBody2D.linear_damp = lerp(carRigidBody2D.linear_damp, 3.0, (Time.get_ticks_msec() / 1000) * 3)
	##	#carRigidbody2D.drag = Mathf.lerp(carRigidbody2D.drag, 3.0, Time.fixedDeltaTime * 3)
	##else:
	##	carRigidBody2D.linear_damp = 0
	#
	##Limit so we can't go faster than the max speed in the "forward" direction
	##if ((velocityVsUp > maxSpeed) && (accelerationInput > 0)):
	##	return
	##Limit so we can't go faster than the max speed in reverse
	##if ((velocityVsUp < -maxSpeed * 0.5) && (accelerationInput < 0)):
	##	return
	##Limit so we can't go faster in any direction while accelerating
	##if ((carRigidBody2D.linear_velocity.length_squared() > maxSpeed * maxSpeed) && (accelerationInput > 0)):
	##	return
	#
	##create a force for the engine
	#var engineForceVector:Vector2 = self.transform.x * accelerationInput * accelerationFactor
	##apply to car and push forward
	#state.apply_central_force(engineForceVector)
	##carRigidbody2D.AddForce(engineForceVector, ForceMode2D.Force)
#
#func ApplySteering(state:PhysicsDirectBodyState2D):
	##limit car's ability to turn when moving slowly
	##var minSpeedBeforeAllowTurningFactor:float #= (carRigidbody2D.velocity.magnitude / 8)
	##Update rotation angle based on input
	#rotationAngle -= steeringInput * turnFactor
	#self.transform.rotation = rotationAngle
	##carRigidbody2D.MoveRotation(rotationAngle)
#
#func SetInputVector():
	#steeringInput = Input.get_axis("ui_left","ui_right")
	#accelerationInput = Input.get_axis("ui_down","ui_up")
#
#func KillOrthoganalVelocity():
	#var forwardVelocity:Vector2 = self.transform.x * self.transform.x.dot(carRigidBody2D.linear_velocity)
	#var rightVelocity:Vector2 = self.transform.y * self.transform.y.dot(carRigidBody2D.linear_velocity)
	#
	#carRigidBody2D.linear_velocity = forwardVelocity + rightVelocity * driftFactor
