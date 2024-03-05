extends Node2D
# Logic for controlling cinematic, dialogue, and then transition to
# the next scene (Cine_Intro_02_GasStation)

@export var loopingEnv_loopDistance: float = 4096
@export var loopingEnv_thresholdY: float = 2048
@export var loopingEnv_speed: float = 300

@onready var loopingEnv: Node2D = $LoopingEnv
@onready var loopingEnv2: Node2D = $LoopingEnv2
@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue

#func _ready():
	#pass


func _process(delta):
	loop_environment(delta)


func loop_environment(delta: float) -> void:
	if (loopingEnv.position.y >= loopingEnv_thresholdY):
		loopingEnv.position.y -= loopingEnv_loopDistance
	loopingEnv.position.y += delta * loopingEnv_speed
	if (loopingEnv2.position.y >= loopingEnv_thresholdY):
		loopingEnv2.position.y -= loopingEnv_loopDistance
	loopingEnv2.position.y += delta * loopingEnv_speed
