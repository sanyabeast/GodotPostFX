@tool
extends Control
class_name PostFX

@export var effects : Array[FXBase] = []:
	set(value):
		effects = value
		_update_effects()

@export var always_update : bool = false

var color_rects : Array[ColorRect] = []
var fx_rects : Dictionary = {}
var fx_map : Dictionary = {}

func _ready() -> void:
	z_index = -1
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_update_effects()

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint():
		if always_update:
			_update_effects()

func _update_effects() -> void:
	for child in get_children():
		child.queue_free()
	color_rects.clear()
	
	for i in range(effects.size()):
		var fx := effects[i]
		
		if fx == null:
			continue
		
		var rect := ColorRect.new()
		rect.name = "FX_%d" % i
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var canvas_layer := CanvasLayer.new()
		canvas_layer.layer = 0
		add_child(canvas_layer)
		canvas_layer.add_child(rect)
		color_rects.append(rect)
		
		var mat := ShaderMaterial.new()
		var shader := Shader.new()
		shader.code = fx._get_shader_code()
		mat.shader = shader
		
		for key in fx.properties.keys():
			mat.set_shader_parameter(key, fx.properties[key])
		
		rect.visible = fx.enabled
		rect.material = mat

		fx_rects[fx._get_name()] = rect
		fx_map[fx._get_name()] = fx
		
		if not Engine.is_editor_hint():
			_on_fx_changed(rect, fx)
		
		if fx.is_connected("changed", Callable(self, "_on_fx_changed")):
			fx.disconnect("changed", Callable(self, "_on_fx_changed"))
		fx.connect("changed", Callable(self, "_on_fx_changed").bind(rect, fx), CONNECT_DEFERRED)

func _on_fx_changed(rect: ColorRect, fx: FXBase) -> void:
	if not is_instance_valid(rect):
		return
	
	rect.visible = fx.enabled
	
	fx._update_shader()
	var mat := rect.material
	if mat is ShaderMaterial:
		for key in fx.properties.keys():
			mat.set_shader_parameter(key, fx.properties[key])

func get_fx(type: StringName) -> FXBase:
	if not fx_map.has(type):
		print("Effect %s not found." % type)
		return null
	return fx_map[type]

func set_fx_property(type:StringName, property: StringName, value) -> void:
	var fx := get_fx(type)
	if fx == null:
		push_warning("Effect %s not found." % type)
		return
	
	fx.set(property, value)
	
func toggle_fx(type: StringName, enable: bool) -> void:
	var fx := get_fx(type)
	print("Toggle fx %s to %s" % [type, enable])
	if fx != null:
		print("FX found")
		fx.enabled = enable
		if fx_rects.has(fx._get_name()):
			print("FX rect found")
			fx_rects[fx._get_name()].visible = enable
			
