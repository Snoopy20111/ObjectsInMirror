extends Node2D

@export var trainNode: Train
@export var playerCar: CarController
@export var speedAvgSize: int = 20

var isTracking: bool = false
var _speedAvg: float = 0.0


# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (isTracking):
		var temp: float = abs(playerCar.linear_velocity.y)
		trainNode.progress += temp * delta
		_speedAvg -= _speedAvg / speedAvgSize
		_speedAvg += (temp / speedAvgSize)


func _on_trigger_train_start_player_crossed():
	isTracking = true


func _on_trigger_train_end_player_crossed():
	# Release the train to keep going past at its average speed so far
	isTracking = false
	trainNode.selfControlling = true
	trainNode.speed = _speedAvg
