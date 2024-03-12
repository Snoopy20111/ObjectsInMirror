extends Node2D

@export var trainNode: Train
@export var playerCar: CarController

var isTracking: bool = false
var _speedAvg: float = 0.0
var _speedAvgSize: int = 60

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (isTracking):
		var temp: float = abs(playerCar.linear_velocity.y)
		trainNode.progress += temp * delta
		_speedAvg -= _speedAvg / _speedAvgSize
		_speedAvg += (temp / _speedAvgSize)
		print("Speed avg: " + str(_speedAvg) + " | Input of: " + str(temp))


func _on_trigger_train_start_player_crossed():
	isTracking = true
	print("Start")


func _on_trigger_train_end_player_crossed():
	# Release the train to keep going past
	# Use a speed value we rolling average from the final run
	print("End")
	isTracking = false
	trainNode.selfControlling = true
	trainNode.speed = _speedAvg
