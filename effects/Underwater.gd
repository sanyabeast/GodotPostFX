@tool
extends FXBase
class_name UnderwaterFX

@export_range(0, 0.5, 0.01) var distortion_strength : float = 0.02:
	set(value):
		distortion_strength = value
		notify_change()

@export_range(0, 2, 0.01) var wave_speed : float = 0.3:
	set(value):
		wave_speed = value
		notify_change()

@export_range(0, 10, 0.01) var wave_frequency : float = 2.0:
	set(value):
		wave_frequency = value
		notify_change()

@export_range(0, 5, 0.01) var noise_scale : float = 1.0:
	set(value):
		noise_scale = value
		notify_change()	

@export var underwater_tint : Color = Color.WHITE:
	set(value):
		underwater_tint = value
		notify_change()	

@export_range(0, 1, 0.01) var tint_strength : float = 0.3:
	set(value):
		tint_strength = value
		notify_change()	

@export_range(0, 2, 0.01) var brightness : float = 0.8:
	set(value):
		brightness = value
		notify_change()	

@export_range(0, 2, 0.01) var contrast : float = 1.1:
	set(value):
		contrast = value
		notify_change()	

@export_range(0, 1, 0.01) var caustic_strength : float = 0.15:
	set(value):
		caustic_strength = value
		notify_change()	

@export_range(0, 5, 0.01) var caustic_scale : float = 3.0:
	set(value):
		caustic_scale = value
		notify_change()	

@export_range(0, 2, 0.01) var caustic_speed : float = 0.4:
	set(value):
		caustic_speed = value
		notify_change()	

@export_range(0, 1, 0.01) var depth_fade_distance : float = 1.0:
	set(value):
		depth_fade_distance = value
		notify_change()	

@export_range(1, 2, 0.01) var zoom_factor : float = 1.05:
	set(value):
		zoom_factor = value
		notify_change()	

@export_range(0, 0.05, 0.001) var micro_distortion_strength : float = 0.005:
	set(value):
		micro_distortion_strength = value
		notify_change()	

@export_range(10, 100, 1) var micro_frequency : float = 40.0:
	set(value):
		micro_frequency = value
		notify_change()	

@export_range(0, 5, 0.01) var micro_speed : float = 2.0:
	set(value):
		micro_speed = value
		notify_change()	

func _get_shader_code() -> String:
	return load("res://addons/postfx/shaders/underwater.gdshader").code

func _update_shader() -> void:
	properties["distortion_strength"] = distortion_strength
	properties["wave_speed"] = wave_speed
	properties["wave_frequency"] = wave_frequency
	properties["noise_scale"] = noise_scale
	properties["underwater_tint"] = underwater_tint
	properties["tint_strength"] = tint_strength
	properties["brightness"] = brightness
	properties["contrast"] = contrast
	properties["caustic_strength"] = caustic_strength
	properties["caustic_scale"] = caustic_scale
	properties["caustic_speed"] = caustic_speed
	properties["depth_fade_distance"] = depth_fade_distance
	properties["zoom_factor"] = zoom_factor
	properties["micro_distortion_strength"] = micro_distortion_strength
	properties["micro_frequency"] = micro_frequency
	properties["micro_speed"] = micro_speed

func _get_name() -> String:
	return "underwater"
