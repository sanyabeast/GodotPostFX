@tool
@abstract
extends Resource
class_name FXBase

@export var enabled: bool = true:
	set(value):
		enabled = value
		notify_change()


var properties : Dictionary

func notify_change():
	changed.emit()

@abstract
func _get_name() -> String;

@abstract
func _get_shader_code() -> String;

@abstract
func _update_shader() -> void;
