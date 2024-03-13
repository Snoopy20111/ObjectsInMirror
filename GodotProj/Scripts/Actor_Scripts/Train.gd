extends PathFollow2D

class_name Train

var selfControlling: bool = false
var speed: float = 10.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (selfControlling):
		progress += speed * delta


func _on_collision_body_entered(body):
	pass # Replace with function body.
