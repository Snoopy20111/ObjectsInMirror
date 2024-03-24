extends PathFollow2D

class_name Train

var selfControlling: bool = false
var speed: float = 10.0

@onready var trainPassbyEmitter = $AudioEmitters/ChuggaChugga
@onready var trainHornEmitter = $AudioEmitters/ChooChoo


func _ready():
	Wwise.register_game_obj(trainHornEmitter, "Train Horn")
	Wwise.register_game_obj(trainPassbyEmitter, "Train Chug")
	Wwise.set_2d_position(trainHornEmitter, trainHornEmitter.global_transform, 0)
	Wwise.set_2d_position(trainPassbyEmitter, trainPassbyEmitter.global_transform, 0)

func _process(_delta):
	Wwise.set_2d_position(trainHornEmitter, trainHornEmitter.global_transform, 0)
	Wwise.set_2d_position(trainPassbyEmitter, trainPassbyEmitter.global_transform, 0)
	#print(trainHornEmitter.global_transform);

func _physics_process(delta):
	if (selfControlling):
		progress += speed * delta


func _on_collision_body_entered(body) -> void:
	if (body is Entity_Chaser):
		body.remove_entity()

func activate_train() -> void:
	if (!selfControlling):
		selfControlling = true
		Wwise.post_event("ACTR_Train_Horn", trainHornEmitter)
		Wwise.post_event("ACTR_Train_Play", trainPassbyEmitter)
		#print("Should be playing sound")

func _exit_tree():
	Wwise.post_event("ACTR_Train_Stop", trainPassbyEmitter)
	Wwise.unregister_game_obj(trainHornEmitter)
	Wwise.unregister_game_obj(trainPassbyEmitter)
