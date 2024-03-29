extends Node2D
# Logic for controlling cinematic, dialogue, and then transition to
# the next scene (Cine_Intro_02_GasStation)

@export var loopingEnv_loopDistance: float = 4096
@export var loopingEnv_thresholdY: float = 2048
@export var loopingEnv_speed: float = 300

@export var dialogue_Outro_01: DialogueResource = load("res://Dialogue/Cine_Outro_01.dialogue")
@export var dialogue_Outro_02: DialogueResource = load("res://Dialogue/Cine_Outro_02.dialogue")

@export var sceneToLoad: String = "res://Scenes/Cine_Outro_02_TruckStop.tscn"

@onready var loopingEnv: Node2D = $LoopingEnv
@onready var loopingEnv2: Node2D = $LoopingEnv2
@onready var timerToFirstDialogue: Timer = $Timers/Timer_ToFirstDialogue
@onready var timerToSecondDialogue: Timer = $Timers/Timer_ToSecondDialogue
@onready var timerToExit: Timer = $Timers/Timer_ToExit

var currentDialogue: int = 0


func _ready() -> void:
	# Connect dialogue manager signals
	DialogueManager.dialogue_ended.connect(dia_end)
	
	# Set Fullscreen shaders: vignette and rain, if not already on
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.VIGNETTE, true)
	GameManager.setFullscreenShaderActive(Enums.CANVAS_EFFECT.RAIN, true)

func _process(delta: float) -> void:
	loop_environment(delta)

func loop_environment(delta: float) -> void:
	if (loopingEnv.position.y >= loopingEnv_thresholdY):
		loopingEnv.position.y -= loopingEnv_loopDistance
	loopingEnv.position.y += delta * loopingEnv_speed
	if (loopingEnv2.position.y >= loopingEnv_thresholdY):
		loopingEnv2.position.y -= loopingEnv_loopDistance
	loopingEnv2.position.y += delta * loopingEnv_speed

#Disgusting custom scripts, chain reaction of signals pinging back and forth
func _on_timer_to_first_dialogue_timeout() -> void:
	DialogueManager.show_dialogue_balloon(dialogue_Outro_01, "start")
	currentDialogue += 1

func _on_timer_to_second_dialogue_timeout() -> void:
	currentDialogue += 1
	DialogueManager.show_dialogue_balloon(dialogue_Outro_02, "start")

func _on_timer_to_exit_timeout() -> void:
	SceneManager.change_scene(sceneToLoad)

func dia_end(_resource: DialogueResource) -> void:
	match (currentDialogue):
		1:
			timerToSecondDialogue.start()
		2:
			timerToExit.start()

func _exit_tree() -> void:
	GameManager.resetFullScreenShaders()
