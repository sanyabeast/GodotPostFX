@tool
extends FXBase
class_name ChromaticAberrationFX

@export var strength : float = 2.0:
	set(value):
		strength = value
		notify_change()

@export_range(0.0, 1.0, 0.01) var vignette_size : float = 0.5:
	set(value):
		vignette_size = value
		notify_change()


func _get_shader_code() -> String:
	return load("res://addons/postfx/shaders/chromatic_aberration.gdshader").code

func _update_shader() -> void:
	properties["offset"] = strength
	properties["vignette_size"] = vignette_size

func _get_name() -> String:
	return "chromatic_aberration"
