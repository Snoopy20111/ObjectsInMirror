extends Control

const LogoFade_Curve = preload("res://Customs/Curves/LogoFade_Curve.tres")

# Declare member variables here. Examples:

@onready var StartTimer: Timer = $StartTimer as Timer
@onready var FreezeTimer: Timer = $FreezeTimer as Timer
@onready var LogoAnim: AnimatedSprite2D = $CenterContainer/LogoAnim as AnimatedSprite2D

var fadeCounter:float = 0
@export var fade_value: Enums.FADE_STATE = Enums.FADE_STATE.PAUSE

@export var FadeIn_Length: float = .5
@export var FadeOut_Length: float = .5

var transitioning : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StartTimer.start()
	Wwise.register_game_obj(self, "LogoParade")		#Uses its own GameObj
	#Wwise.post_event("MUS_Menu", AmbientAudio)
	Wwise.post_event("AMB_Menu", AmbientAudio)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match (fade_value):
		Enums.FADE_STATE.IN:
			# add to alpha value, and run fade counter value through the fade curve
			fadeCounter += delta
			LogoAnim.modulate.a = LogoFade_Curve.sample(fadeCounter / FadeIn_Length)
			# once we pass 1, pause the animation and reset the counter
			if (fadeCounter >= 1):
				fade_value = Enums.FADE_STATE.PAUSE
				fadeCounter = 0
		Enums.FADE_STATE.OUT:
			# add to alpha value, and go in reverse down through the fade curve values
			fadeCounter += delta
			LogoAnim.modulate.a = LogoFade_Curve.sample(1 - (fadeCounter / FadeOut_Length))
			# once we pass 1 again, pause the animation (should be invisible) and wait the length of the timer before dying
			if (fadeCounter >= 1):
				fade_value = Enums.FADE_STATE.PAUSE
			if (!transitioning) and (fadeCounter >= .18):
				SceneManager.change_scene("res://Scenes/MainMenu.tscn")
				transitioning = true


func _on_LogoAnim_finished() -> void:
	# pause anim and start Freeze Timer
	FreezeTimer.start()
	fade_value = Enums.FADE_STATE.PAUSE


func _on_StartTimer_timeout() -> void:
	fade_value = Enums.FADE_STATE.IN
	LogoAnim.play()
	Wwise.post_event("UI_LogoParade", self)
	Wwise.unregister_game_obj(self) #can do because it's a oneshot

func _on_FreezeTimer_timeout() -> void:
	fade_value = Enums.FADE_STATE.OUT
