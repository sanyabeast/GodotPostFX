@tool
extends CanvasLayer

@export var effects : Array[FXBase] = []:
	set(value):
		effects = value
		_update_effects()

var color_rects : Array[ColorRect] = []

func _ready() -> void:
	_update_effects()

func _update_effects() -> void:
	for child in get_children():
		child.queue_free()
	color_rects.clear()
	
	for i in range(effects.size()):
		var fx = effects[i]
		if fx == null or not fx.enabled:
			continue
		
		var rect := ColorRect.new()
		rect.name = "FX_%d" % i
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var canvas_layer := CanvasLayer.new()
		add_child(canvas_layer)
		canvas_layer.add_child(rect)
		color_rects.append(rect)
		
		var mat := ShaderMaterial.new()
		var shader := Shader.new()
		shader.code = fx._get_shader_code()
		mat.shader = shader
		
		for key in fx.properties.keys():
			mat.set_shader_parameter(key, fx.properties[key])
		
		#rect.visible = fx.enabled
		rect.material = mat
		
		if fx.is_connected("changed", Callable(self, "_on_fx_changed")):
			fx.disconnect("changed", Callable(self, "_on_fx_changed"))
		fx.connect("changed", Callable(self, "_on_fx_changed").bind(rect, fx), CONNECT_DEFERRED)

func _on_fx_changed(rect: ColorRect, fx: FXBase) -> void:
	if not is_instance_valid(rect):
		return
	
	rect.visible = fx.enabled
	print(str(rect.visible) + " RECT")
	print(str(fx.enabled) + " FX")
	
	fx._update_shader()
	var mat := rect.material
	if mat is ShaderMaterial:
		for key in fx.properties.keys():
			mat.set_shader_parameter(key, fx.properties[key])
