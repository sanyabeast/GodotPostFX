@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"PostFX", 
		"CanvasLayer", 
		preload("res://addons/postfx/nodes/PostFX.gd")
	)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
