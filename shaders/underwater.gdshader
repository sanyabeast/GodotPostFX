shader_type canvas_item;

// Textures
uniform sampler2D noise_texture : hint_default_black;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Distortion controls
uniform float distortion_strength : hint_range(0.0, 0.5) = 0.02;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.3;
uniform float wave_frequency : hint_range(0.1, 10.0) = 2.0;
uniform float noise_scale : hint_range(0.1, 5.0) = 1.0;

// Color/lighting effects
uniform vec3 underwater_tint : source_color = vec3(0.4, 0.7, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.3;
uniform float brightness : hint_range(0.0, 2.0) = 0.8;
uniform float contrast : hint_range(0.0, 2.0) = 1.1;

// Caustics effect
uniform bool enable_caustics = true;
uniform float caustic_strength : hint_range(0.0, 1.0) = 0.15;
uniform float caustic_scale : hint_range(0.1, 5.0) = 3.0;
uniform float caustic_speed : hint_range(0.0, 2.0) = 0.4;

// Depth-based effects
uniform bool enable_depth_fade = true;
uniform float depth_fade_distance : hint_range(0.0, 2.0) = 1.0;

// Zoom factor to avoid edge sampling issues
uniform float zoom_factor : hint_range(1.0, 1.2) = 1.05;

// High-frequency distortion
uniform float micro_distortion_strength : hint_range(0.0, 0.05) = 0.005;
uniform float micro_frequency : hint_range(10.0, 100.0) = 40.0;
uniform float micro_speed : hint_range(0.0, 5.0) = 2.0;

// Simple noise function for procedural distortion
vec2 random2(vec2 st) {
    st = vec2(dot(st, vec2(127.1, 311.7)), dot(st, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123);
}

// Smooth noise
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(random2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(random2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(random2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal noise for more complex patterns
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(st * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    
    // Create layered distortion using multiple noise octaves
    vec2 distortion = vec2(0.0);
    
    // Primary wave distortion
    float time_offset = TIME * wave_speed;
    vec2 wave_uv = UV * wave_frequency + time_offset;
    
    // Use texture if available, otherwise use procedural noise
    if (textureSize(noise_texture, 0).x > 1) {
        // Animated noise texture sampling
        vec4 noise1 = texture(noise_texture, wave_uv * noise_scale + vec2(time_offset * 0.3, 0.0));
        vec4 noise2 = texture(noise_texture, wave_uv * noise_scale * 0.7 + vec2(0.0, time_offset * 0.2));
        distortion = (noise1.xy + noise2.xy - 1.0) * distortion_strength;
    } else {
        // Procedural noise distortion - properly centered around 0
        float noise1 = fbm(wave_uv * noise_scale + vec2(time_offset, 0.0)) - 0.5;
        float noise2 = fbm(wave_uv * noise_scale * 1.3 + vec2(0.0, time_offset * 0.8)) - 0.5;
        distortion = vec2(noise1, noise2) * distortion_strength * 2.0;
    }
    
    // Add subtle wave motion
    distortion.x += sin(UV.y * 10.0 + TIME * 2.0) * distortion_strength * 0.3;
    distortion.y += cos(UV.x * 8.0 + TIME * 1.5) * distortion_strength * 0.2;
    
    // Add high-frequency micro distortions for fine detail (smoother pattern)
    vec2 micro_uv1 = UV * micro_frequency + TIME * micro_speed * vec2(0.3, 0.7);
    vec2 micro_uv2 = UV * micro_frequency * 0.8 + TIME * micro_speed * vec2(-0.5, 0.4);
    
    float micro_x = (sin(micro_uv1.x) * cos(micro_uv1.y * 1.3) + 
                     sin(micro_uv2.x * 1.1) * cos(micro_uv2.y * 0.9)) * 0.5;
    float micro_y = (cos(micro_uv1.y) * sin(micro_uv1.x * 0.7) + 
                     cos(micro_uv2.y * 1.2) * sin(micro_uv2.x * 0.8)) * 0.5;
    
    distortion += vec2(micro_x, micro_y) * micro_distortion_strength;
    
    // Apply zoom and center the UV coordinates
    vec2 centered_uv = (screen_uv - 0.5) / zoom_factor + 0.5;
    
    // Sample the screen with distortion
    vec2 final_uv = centered_uv + distortion;
    vec4 screen_color = texture(SCREEN_TEXTURE, final_uv);
    
    // Apply underwater color grading
    screen_color.rgb = mix(screen_color.rgb, screen_color.rgb * underwater_tint, tint_strength);
    screen_color.rgb = ((screen_color.rgb - 0.5) * contrast + 0.5) * brightness;
    
    // Add caustics effect
    if (enable_caustics) {
        vec2 caustic_uv = UV * caustic_scale + TIME * caustic_speed * vec2(0.3, 0.1);
        float caustic_noise1 = fbm(caustic_uv);
        float caustic_noise2 = fbm(caustic_uv * 1.7 + vec2(0.3, 0.2));
        float caustics = max(0.0, caustic_noise1 * caustic_noise2);
        caustics = pow(caustics, 2.0) * caustic_strength;
        screen_color.rgb += vec3(caustics * 0.8, caustics, caustics * 0.6);
    }
    
    // Depth-based fade effect
    if (enable_depth_fade) {
        float depth_factor = smoothstep(0.0, depth_fade_distance, UV.y);
        screen_color.rgb = mix(screen_color.rgb, screen_color.rgb * underwater_tint, depth_factor * 0.4);
        screen_color.rgb *= mix(1.0, 0.6, depth_factor);
    }
    
    COLOR = screen_color;
}