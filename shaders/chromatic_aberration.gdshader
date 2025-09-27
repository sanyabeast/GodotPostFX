shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float offset = 1;
uniform float vignette_size : hint_range(0.0, 1.0) = 0.5;

void fragment(){
	// Calculate distance from center for vignette effect
	vec2 center_offset = SCREEN_UV - vec2(0.5);
	float distance_from_center = length(center_offset) * 2.0; // Normalize to 0-1 range
	
	// Create vignette mask - higher vignette_size means effect applies closer to center
	float vignette_mask = smoothstep(vignette_size, 1.0, distance_from_center);
	
	// Calculate final offset based on vignette mask
	float final_offset = offset * vignette_mask;
	
	// Sample channels with offset
	vec4 green_channel = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 red_channel = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + (final_offset * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
	vec4 blue_channel = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - (final_offset * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
	
	// Mix between original and aberrated based on vignette mask
	vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 aberrated_color = vec4(red_channel.r, green_channel.g, blue_channel.b, 1.0);
	
	COLOR = mix(original_color, aberrated_color, vignette_mask);
}