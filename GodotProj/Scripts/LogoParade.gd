extends Control

const LogoFade_Curve = preload("res://Customs/Curves/LogoFade_Curve.tres")

# Declare member variables here. Examples:

@onready var StartTimer: Timer = $StartTimer as Timer
@onready var FreezeTimer: Timer = $FreezeTimer as Timer
@onready var LogoAnim: AnimatedSprite2D = $CenterContainer/LogoAnim as AnimatedSprite2D
@onready var AudioObject: Node = $LogoParadeEmitter as Node

var FadeCounter = 0
@export var fade_value = Enums.FADE_STATE.PAUSE

@export var FadeIn_Length = .5
@export var FadeOut_Length = .5

var transitioning : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	StartTimer.start()
	Wwise.register_game_obj(AudioObject, "LogoParade")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match (fade_value):
		Enums.FADE_STATE.IN:
			# add to alpha value, and run fade counter value through the fade curve
			FadeCounter += delta
			LogoAnim.modulate.a = LogoFade_Curve.sample(FadeCounter / FadeIn_Length)
			# once we pass 1, pause the animation and reset the counter
			if (FadeCounter >= 1):
				fade_value = Enums.FADE_STATE.PAUSE
				FadeCounter = 0
		Enums.FADE_STATE.OUT:
			# add to alpha value, and go in reverse down through the fade curve values
			FadeCounter += delta
			LogoAnim.modulate.a = LogoFade_Curve.sample(1 - (FadeCounter / FadeOut_Length))
			# once we pass 1 again, pause the animation (should be invisible) and wait the length of the timer before dying
			if (FadeCounter >= 1):
				fade_value = Enums.FADE_STATE.PAUSE
			if (!transitioning && FadeCounter >= .18):
				SceneManager.change_scene("res://Scenes/MainMenu.tscn")
				transitioning = true


func _on_LogoAnim_finished():
	# pause anim and start Freeze Timer
	FreezeTimer.start()
	fade_value = Enums.FADE_STATE.PAUSE


func _on_StartTimer_timeout():
	fade_value = Enums.FADE_STATE.IN
	LogoAnim.play()
	Wwise.post_event("Play_UI_LogoParade", AudioObject)
	Wwise.unregister_game_obj(AudioObject) #can do because it's a oneshot

func _on_FreezeTimer_timeout():
	fade_value = Enums.FADE_STATE.OUT
