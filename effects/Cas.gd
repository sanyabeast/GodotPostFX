@tool
extends FXBase
class_name CasFX

@export_range(0.0, 4.0, 0.01) var intensity : float = 0.4:
	set(value):
		intensity = value
		notify_change()

@export_range(0.0, 1.0, 0.01) var treshold : float = 0.1:
	set(value):
		treshold = value
		notify_change()
		
@export_range(0.0, 3.0, 0.01) var sharpness : float = 1.0:
	set(value):
		sharpness = value
		notify_change()
		
@export_range(0.0, 5.0, 0.01) var edge_boost : float = 1.5:
	set(value):
		edge_boost = value
		notify_change()

@export var use_diagonal_sampling : bool = true:
	set(value):
		use_diagonal_sampling = value
		notify_change()

func _get_shader_code() -> String:
	return load("res://addons/postfx/shaders/cas.gdshader").code

func _update_shader() -> void:
	properties["intensity"] = intensity
	properties["treshold"] = treshold
	properties["sharpness"] = sharpness
	properties["edge_boost"] = edge_boost
	properties["use_diagonal_sampling"] = use_diagonal_sampling
