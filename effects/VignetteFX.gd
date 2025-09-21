@tool
extends FXBase
class_name VignetteFX

@export_range(0, 2, 0.01) var intensity : float = 1.0:
	set(value):
		intensity = value
		notify_change()
		
@export_range(0, 1, 0.01) var opacity : float = 0.5:
	set(value):
		opacity = value
		notify_change()

@export var color: Color = Color.BLACK:
	set(value):
		color = value
		notify_change()

func _get_shader_code() -> String:
	return load("res://addons/postfx/shaders/vignette.gdshader").code

func _update_shader() -> void:
	properties["vignette_intensity"] = intensity
	properties["vignette_opacity"] = opacity
	properties["vignette_rgb"] = color
