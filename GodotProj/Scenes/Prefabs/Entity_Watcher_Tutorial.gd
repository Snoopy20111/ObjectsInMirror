extends Node2D


@export var turningSpeed: float = 12.0

@onready var watcherLight: PointLight2D = $PointLight2D
@onready var animBeginTimer: Timer = $AnimBeginTimer

var paused: bool = true

#func _ready():
	#pass # Replace with function body.


func _process(delta):
	#early return if the watcher is paused
	if (paused):
		return
	
	# If the player's location is a valid position,
	# look towards the player with smoothing
	var new_playerLocation: Vector2
	if (typeof(GameManager.playerLocation) == TYPE_VECTOR2):
		new_playerLocation = GameManager.playerLocation
		
		#working approach
		var new_transform = transform.looking_at(new_playerLocation)
		rotation = transform.interpolate_with(new_transform, turningSpeed * delta).get_rotation()
		
		#uses less data but can't interpolate neg -> positive, does crazy spins
		#rotation = lerp(rotation, transform.looking_at(new_playerLocation).get_rotation(),
		#turningSpeed * delta)
		
		#alternate simple approach without smoothing
		#look_at(new_playerLocation)
	


func _on_visible_on_screen_entered():
	#spring to life
	print("watcher activated")
	paused = false
	animBeginTimer.start()
	

func _on_anim_begin_timer_timeout():
	#basic version, just turn off the light
	#later we'll want to lerp it down or something
	watcherLight.visible = false
