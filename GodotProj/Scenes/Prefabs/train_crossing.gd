extends Sprite2D
class_name TrainCrossing

@export var threshold: float = 0.5
@export var isActive: bool = true
var _counter: float = 0
var _activeLight: int = 1

@onready var leftLight: PointLight2D = $Left
@onready var rightLight: PointLight2D = $Right


func _ready():
	isActive = true

func _process(delta):
	if (isActive):
		_counter += delta
		if (_counter > threshold):
			_activeLight *= -1
			match _activeLight:
				-1:
					leftLight.enabled = true
					rightLight.enabled = false
				1:
					leftLight.enabled = false
					rightLight.enabled = true
			_counter -= threshold

func stop():
	isActive = false
	leftLight.enabled = false
	rightLight.enabled = false
