extends PathFollow2D

@export var speed_mult:float = 0.08
const progress_curve = preload("res://Customs/Curves/LogoParade_wordFadeCurve.tres")

var is_running:bool = false
var counter_value:float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (is_running):
		counter_value += (delta * speed_mult)
		progress_ratio += progress_curve.sample(counter_value)
		if (counter_value >= 1):
			is_running = false

#fired from signal to start motion
func _on_wordstimer_timeout() -> void:
	is_running = true
	counter_value = 0
