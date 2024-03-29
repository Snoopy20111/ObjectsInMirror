extends Sprite2D
class_name TrainCrossing

@export var time_threshold: float = 0.4
@export var isActive: bool = true
var _counter: float = 0
var _activeLight: int = 1

@onready var leftLight: PointLight2D = $Left
@onready var rightLight: PointLight2D = $Right


func _ready() -> void:
	Wwise.register_game_obj(self, str(self))
	Wwise.set_2d_position(self, global_transform, 0)

func _process(delta: float) -> void:
	if (isActive):
		Wwise.set_2d_position(self, global_transform, 0)
		_counter += delta
		if (_counter > time_threshold):
			_activeLight *= -1
			match _activeLight:
				-1:
					leftLight.enabled = true
					rightLight.enabled = false
				1:
					leftLight.enabled = false
					rightLight.enabled = true
			_counter -= time_threshold

func start() -> void:
	isActive = true
	Wwise.post_event("ACTR_TrainCrossing_Play", self)

func stop() -> void:
	isActive = false
	leftLight.enabled = false
	rightLight.enabled = false
	Wwise.post_event("ACTR_TrainCrossing_Stop", self)
