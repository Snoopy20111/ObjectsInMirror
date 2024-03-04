extends CharacterBody2D

@export_group("Basic Car properties")
@export var wheel_base:float = 50
@export var steering_angle:float = 25
@export var engine_power:float = 2000
@export var braking_power:float = -450
@export var max_speed_reverse:float = 250


@export var friction:float = -0.9
@export var drag:float = -0.001
@export var steering_mult:float = 10
@export var traction_curve:Curve = preload("res://Customs/Curves/Car_XSpeedYTraction_Default.tres")

var acceleration:Vector2 = Vector2.ZERO
var steer_direction:float
var last_heading:Vector2 = Vector2.ZERO

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
	if Input.is_action_pressed("drive_right"):
		turn += 1
	if Input.is_action_pressed("drive_left"):
		turn -= 1
	if sign(turn) != sign(steer_direction):
		turn *= 1.5
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("drive_forward"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("drive_back"):
		acceleration = transform.x * braking_power

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
	
	#this is the source of the sudden turns, but I don't know exactly how to smooth it out
	#rotation = new_heading.angle()
	var new_angle: Vector2 = Vector2(lerp(new_heading.x, last_heading.x, traction),
	lerp(new_heading.y, last_heading.y, traction))

	rotation = new_angle.angle()
	last_heading = new_heading
	
