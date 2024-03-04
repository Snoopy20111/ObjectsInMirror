extends Node

@export var fullscreen_effects: Array

### Specific Utilities ###
func retarget_camera2D(_new_target: Node2D):
	#Set camera to target this object
	pass

func setFullscreenShaderParam(effect: int, param_name: String, new_value):
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
	if (new_value == null):
		push_error("value given was null")
		return
		
	# Don't know of any way to error-check names and types of shader params,
	# So we just have to hope Godot will throw meaningful errors
	var my_material = get_node(fullscreen_effects[effect]).get_material()
	my_material.set_shader_parameter(param_name, new_value)

### Utilities ###
func reparent_other(child:Node, new_parent:Node) -> void:
	child.reparent(new_parent)

func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)
