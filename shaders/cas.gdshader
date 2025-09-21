shader_type canvas_item;

uniform float intensity : hint_range(0.0, 4.0) = 0.5;
uniform float threshold : hint_range(0.0, 1.0) = 0.1;
uniform float sharpness : hint_range(0.1, 3.0) = 1.0;
uniform float edge_boost : hint_range(1.0, 5.0) = 1.5;
uniform bool use_diagonal_sampling = false;
uniform sampler2D screen_vec : hint_screen_texture;

// Convert RGB to luminance for edge detection
float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// CAS sharpening function with enhanced controls
vec3 cas_sharpen(sampler2D tex, vec2 uv, vec2 texel_size) {
    // Sample the center pixel
    vec3 center = texture(tex, uv).rgb;
    
    // Sample surrounding pixels in a cross pattern
    vec3 top = texture(tex, uv + vec2(0.0, -texel_size.y)).rgb;
    vec3 bottom = texture(tex, uv + vec2(0.0, texel_size.y)).rgb;
    vec3 left = texture(tex, uv + vec2(-texel_size.x, 0.0)).rgb;
    vec3 right = texture(tex, uv + vec2(texel_size.x, 0.0)).rgb;
    
    // Optional diagonal sampling for stronger edge detection
    vec3 diag_samples = vec3(0.0);
    if (use_diagonal_sampling) {
        vec3 top_left = texture(tex, uv + vec2(-texel_size.x, -texel_size.y)).rgb;
        vec3 top_right = texture(tex, uv + vec2(texel_size.x, -texel_size.y)).rgb;
        vec3 bottom_left = texture(tex, uv + vec2(-texel_size.x, texel_size.y)).rgb;
        vec3 bottom_right = texture(tex, uv + vec2(texel_size.x, texel_size.y)).rgb;
        diag_samples = (top_left + top_right + bottom_left + bottom_right) * 0.25;
    }
    
    // Calculate local contrast using luminance
    float center_lum = luminance(center);
    float top_lum = luminance(top);
    float bottom_lum = luminance(bottom);
    float left_lum = luminance(left);
    float right_lum = luminance(right);
    
    // Find min and max luminance in the neighborhood
    float min_lum = min(center_lum, min(min(top_lum, bottom_lum), min(left_lum, right_lum)));
    float max_lum = max(center_lum, max(max(top_lum, bottom_lum), max(left_lum, right_lum)));
    
    // Calculate contrast with edge boost
    float contrast = (max_lum - min_lum) * edge_boost;
    
    // Only apply sharpening if contrast exceeds threshold
    if (contrast < threshold) {
        return center;
    }
    
    // Calculate sharpening weight with enhanced controls
    float weight = min(contrast, 1.0) * intensity;
    
    // Apply sharpening using unsharp mask technique
    vec3 blur = (top + bottom + left + right) * 0.25;
    if (use_diagonal_sampling) {
        blur = mix(blur, diag_samples, 0.3);
    }
    
    // Enhanced sharpening calculation
    vec3 detail = (center - blur) * sharpness;
    vec3 sharp = center + detail * weight;
    
    // Prevent oversharpening by clamping to reasonable bounds
    return clamp(sharp, vec3(0.0), vec3(1.0));
}

void fragment() {
    vec4 screen_color = texture(screen_vec, SCREEN_UV);
    vec4 text = texture(TEXTURE, UV);
    
    // Get texel size for sampling neighbors
    vec2 texel_size = 1.0 / vec2(textureSize(screen_vec, 0));
    
    // Apply CAS sharpening to screen texture
    vec3 sharpened = cas_sharpen(screen_vec, SCREEN_UV, texel_size);
    
    // Combine with original effect structure
    COLOR = vec4(text.rgb * sharpened, text.a);
}