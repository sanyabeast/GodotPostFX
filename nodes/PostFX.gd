@tool
extends Control
class_name PostFX

@export var effects: Array[FXBase] = []:
	set(value):
		if effects != value:
			effects = value
			_schedule_effects_update()

@export var always_update: bool = false
@export var debug_mode: bool = false

var _color_rects: Array[ColorRect] = []
var _fx_rects: Dictionary = {}
var _fx_map: Dictionary = {}
var _material_cache: Dictionary = {}
var _update_scheduled: bool = false
var _connected_signals: Array[Callable] = []

func _ready() -> void:
	_initialize_node_properties()
	_schedule_effects_update()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and always_update:
		_schedule_effects_update()
	
	if _update_scheduled:
		_update_scheduled = false
		_update_effects_internal()

func _exit_tree() -> void:
	_cleanup_resources()

func _initialize_node_properties() -> void:
	z_index = -1
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _schedule_effects_update() -> void:
	if not _update_scheduled:
		_update_scheduled = true

func _update_effects_internal() -> void:
	if debug_mode:
		print("[PostFX] Updating %d effects" % effects.size())
	
	_cleanup_existing_effects()
	_create_effect_nodes()

func _cleanup_existing_effects() -> void:
	_disconnect_all_signals()
	
	for child in get_children():
		child.queue_free()
	
	_color_rects.clear()
	_fx_rects.clear()
	_fx_map.clear()

func _create_effect_nodes() -> void:
	for i in range(effects.size()):
		var fx := effects[i]
		if _is_valid_effect(fx):
			_create_effect_node(fx, i)

func _is_valid_effect(fx: FXBase) -> bool:
	if fx == null:
		if debug_mode:
			push_warning("[PostFX] Null effect found in effects array")
		return false
	
	if fx._get_name().is_empty():
		if debug_mode:
			push_warning("[PostFX] Effect has empty name: %s" % fx)
		return false
	
	return true

func _create_effect_node(fx: FXBase, index: int) -> void:
	var effect_name := fx._get_name()
	
	var rect := _create_effect_rect(effect_name, index)
	var material := _create_or_get_cached_material(fx)
	rect.material = material
	
	rect.visible = fx.enabled
	_update_effect_properties(rect, fx)
	
	_color_rects.append(rect)
	_fx_rects[effect_name] = rect
	_fx_map[effect_name] = fx
	
	_connect_effect_signals(fx, rect)
	
	if debug_mode:
		print("[PostFX] Created effect node: %s (enabled: %s)" % [effect_name, fx.enabled])

func _create_effect_rect(effect_name: String, index: int) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = "FX_%s_%d" % [effect_name, index]
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "Layer_%s" % effect_name
	canvas_layer.layer = 0
	
	add_child(canvas_layer)
	canvas_layer.add_child(rect)
	
	return rect

func _create_or_get_cached_material(fx: FXBase) -> ShaderMaterial:
	var effect_name := fx._get_name()
	
	if _material_cache.has(effect_name):
		var cached_material := _material_cache[effect_name] as ShaderMaterial
		if cached_material != null and cached_material.shader != null:
			return cached_material.duplicate()
	
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	
	var shader_code := fx._get_shader_code()
	if shader_code.is_empty():
		push_error("[PostFX] Effect '%s' returned empty shader code" % effect_name)
		return material
	
	shader.code = shader_code
	material.shader = shader
	
	_material_cache[effect_name] = material
	
	return material

func _update_effect_properties(rect: ColorRect, fx: FXBase) -> void:
	fx._update_shader()
	
	var material := rect.material as ShaderMaterial
	if material == null:
		return
	
	for property_name in fx.properties.keys():
		var property_value = fx.properties[property_name]
		material.set_shader_parameter(property_name, property_value)

func _connect_effect_signals(fx: FXBase, rect: ColorRect) -> void:
	var callable := Callable(self, "_on_fx_changed").bind(rect, fx)
	
	if fx.is_connected("changed", callable):
		fx.disconnect("changed", callable)
	
	fx.connect("changed", callable, CONNECT_DEFERRED)
	_connected_signals.append(callable)

func _disconnect_all_signals() -> void:
	_connected_signals.clear()

func _on_fx_changed(rect: ColorRect, fx: FXBase) -> void:
	if not is_instance_valid(rect) or not is_instance_valid(fx):
		return
	
	rect.visible = fx.enabled
	_update_effect_properties(rect, fx)
	
	if debug_mode:
		print("[PostFX] Effect changed: %s (enabled: %s)" % [fx._get_name(), fx.enabled])

func get_fx(type: StringName) -> FXBase:
	if not _fx_map.has(type):
		if debug_mode:
			push_warning("[PostFX] Effect '%s' not found in active effects" % type)
		return null
	return _fx_map[type]

func set_fx_property(type: StringName, property: StringName, value) -> void:
	var fx := get_fx(type)
	if fx == null:
		push_warning("[PostFX] Cannot set property '%s' - effect '%s' not found" % [property, type])
		return
	
	if not fx.has_method("set") and not (property in fx):
		push_warning("[PostFX] Property '%s' not found in effect '%s'" % [property, type])
		return
	
	fx.set(property, value)
	
	if debug_mode:
		print("[PostFX] Set property %s.%s = %s" % [type, property, value])

func toggle_fx(type: StringName, enable: bool) -> void:
	var fx := get_fx(type)
	if fx == null:
		push_warning("[PostFX] Cannot toggle - effect '%s' not found" % type)
		return
	
	fx.enabled = enable
	
	if _fx_rects.has(type):
		var rect := _fx_rects[type] as ColorRect
		if is_instance_valid(rect):
			rect.visible = enable
	
	if debug_mode:
		print("[PostFX] Toggled effect '%s' to %s" % [type, enable])

func add_effect(fx: FXBase) -> void:
	if fx == null:
		push_warning("[PostFX] Cannot add null effect")
		return
	
	if fx in effects:
		if debug_mode:
			print("[PostFX] Effect '%s' already exists" % fx._get_name())
		return
	
	effects.append(fx)
	_schedule_effects_update()
	
	if debug_mode:
		print("[PostFX] Added effect: %s" % fx._get_name())

func remove_effect(type: StringName) -> bool:
	var fx := get_fx(type)
	if fx == null:
		return false
	
	var index := effects.find(fx)
	if index >= 0:
		effects.remove_at(index)
		_schedule_effects_update()
		
		if debug_mode:
			print("[PostFX] Removed effect: %s" % type)
		return true
	
	return false

func get_active_effects() -> Array[StringName]:
	var active_effects: Array[StringName] = []
	for effect_name in _fx_map.keys():
		var fx := _fx_map[effect_name] as FXBase
		if fx != null and fx.enabled:
			active_effects.append(effect_name)
	return active_effects

func force_update() -> void:
	_update_effects_internal()
	
	if debug_mode:
		print("[PostFX] Forced effects update")

func _cleanup_resources() -> void:
	_disconnect_all_signals()
	_material_cache.clear()
	_fx_rects.clear()
	_fx_map.clear()
	_color_rects.clear()
