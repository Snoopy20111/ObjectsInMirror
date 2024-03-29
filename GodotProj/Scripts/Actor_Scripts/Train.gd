extends PathFollow2D
class_name Train

signal stopCrossing

var selfControlling: bool = false
var speed: float = 10.0

@onready var trainPassbyEmitter := $AudioEmitters/EmitterPath/ChuggaChugga
@onready var trainHornEmitter:Node2D = $AudioEmitters/ChooChoo
@onready var emitterPath:Path2D = $AudioEmitters/EmitterPath
@onready var playerCar:CarController = %PlayerCar


func _ready() -> void:
	Wwise.register_game_obj(trainHornEmitter, "Train Horn")
	Wwise.register_game_obj(trainPassbyEmitter, "Train Chug")
	Wwise.set_2d_position(trainHornEmitter, trainHornEmitter.global_transform, 0)
	Wwise.set_2d_position(trainPassbyEmitter, trainPassbyEmitter.global_transform, 0)

func _process(_delta: float) -> void:
	Wwise.set_2d_position(trainHornEmitter, trainHornEmitter.global_transform, 0)
	Wwise.set_2d_position(trainPassbyEmitter, trainPassbyEmitter.global_transform, 0)
	track_emitter_to_player()


func _physics_process(delta: float) -> void:
	if (selfControlling):
		progress += speed * delta
		if (progress_ratio > 0.8):
			emit_signal("stopCrossing")
		elif (progress_ratio > 0.98):
			Wwise.post_event("ACTR_Train_Stop", trainPassbyEmitter)

func _on_collision_body_entered(body: Node2D) -> void:
	if (body is Entity_Chaser):
		body.remove_entity()

func activate_train_sound() -> void:
	Wwise.post_event("ACTR_Train_Play", trainPassbyEmitter)
	#print("Train Sound Activated")

func activate_train() -> void:
	if (!selfControlling):
		selfControlling = true
		Wwise.post_event("ACTR_Train_Horn", trainHornEmitter)
		#print("Train Horn Activated")

func track_emitter_to_player() -> void:
	var targetGlobalPosition: Vector2 = playerCar.global_position
	var closestOffset: float = emitterPath.curve.get_closest_offset(emitterPath.to_local(targetGlobalPosition))
	trainPassbyEmitter.progress = closestOffset
	#var distToPlayer:float = Vector2(playerCar.global_position
		#- trainPassbyEmitter.global_position).length()
	#print(str(distToPlayer) + " | " + str(closestOffset))

func _exit_tree() -> void:
	Wwise.unregister_game_obj(trainHornEmitter)
	Wwise.unregister_game_obj(trainPassbyEmitter)
	#print("Train Removed")
