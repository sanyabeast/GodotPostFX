@tool
extends FXBase
class_name LensFlareFX

@export_multiline var WARNING : String = """
!!! WARNING !!!
Experimental
"""

func _get_shader_code() -> String:
	return load("res://addons/postfx/shaders/lens_flare.gdshader").code

func _update_shader() -> void:
	pass

func _get_name() -> String:
	return "lens_flare"
