extends Node2D

signal trainStartTrack
signal trainEndTrack

@export var trainNode: Train
@export var playerCar: CarController

@export var speedAvgSize: int = 20

var isTracking: bool = false
var _speedAvg: float = 0.0


func _physics_process(delta):
	if (isTracking):
		var temp: float = abs(playerCar.linear_velocity.y)
		trainNode.progress += temp * delta
		_speedAvg -= _speedAvg / speedAvgSize
		_speedAvg += (temp / speedAvgSize)

func _on_trigger_train_audio_start_player_crossed():
	trainNode.activate_train_sound()

func _on_trigger_train_start_player_crossed():
	isTracking = true
	trainNode.activate_train() 
	emit_signal("trainStartTrack")

func _on_trigger_train_end_player_crossed():
	# Release the train to keep going past at its average speed so far
	isTracking = false
	trainNode.speed = _speedAvg

func _on_train_stop_crossing():
	emit_signal("trainEndTrack")
